#!/usr/bin/perl 
use strict;

sub uninterleave ;
my @inputfiles;
push @inputfiles, @ARGV;

my %matrices = ();
my %mastertaxa = ();
my %regiontable = ();
$regiontable{ "regions" } = "";
$regiontable{ "exclusion-sets" } = "";
my $currlength = 0;
my $outfolder = "";

#foreach my $inputfile (@inputfiles) {
for (my $i=0; $i< scalar(@inputfiles); $i++) {
	my $inputfile = @inputfiles[$i];
	if ($inputfile eq "-output") {
		$outfolder = @inputfiles[$i+1];
		$i++;
		next;
	}
	my $ref = uninterleave $inputfile;
	$matrices{ $inputfile } = $ref;
	while ( my ($key, $value) = each(%{$ref}) ) {
        $mastertaxa{ $key } = "";
    }
}

#for each matrix, make a mastertaxa matrix that has missing data for the taxa with no entries in this matrix.
#also, add another column to the regiontable hash
foreach my $key ( keys %matrices ) {
	my $ref = $matrices{$key};
	$regiontable{"regions"} = $regiontable{"regions"} . "$key\t";
	my %expandedmatrix = %mastertaxa;
	foreach my $k (keys %{$ref}) {
		#add entries from this matrix into expandedmatrix
		$expandedmatrix{ $k } = $ref->{ $k };
		$regiontable{$k} = $regiontable{$k} . "x\t";
	}
	my $total = $expandedmatrix{'length'};
	my $starts_at = $currlength + 1;
	$currlength = $currlength + $total;
	$regiontable{"exclusion-sets"} = $regiontable{"exclusion-sets"} . "$starts_at" . "-" . "$currlength\t";
	my $replacement = "-" x $total;
	foreach my $k (keys %expandedmatrix) {
		my $l = length($expandedmatrix{$k});
		if ($l == 0) {
			#if the entry in expandedmatrix is empty, fill it with blanks
			$expandedmatrix{ $k } = "$replacement";
			$regiontable{$k} = $regiontable{$k} . "\t";
		}
		$l = length($expandedmatrix{$k});
	}
	$matrices{$key} = \%expandedmatrix;
}

#now, for each matrix, concatenate them to the corresponding entry in mastertaxa
my $l = 0;
foreach my $key ( keys %matrices ) {
	my $ref = $matrices{$key};
	$l = $l + $ref->{"length"};
	foreach my $k (keys %{$ref}) {
		$mastertaxa{$k} = $mastertaxa{$k} . $ref->{$k};
	}
}

delete $mastertaxa{"length"};
delete $regiontable{"length"};
my $ntax = keys %mastertaxa;
my $nchar = $l;
	print "$l\n";

open (fileOUT, ">$outfolder/regions.tab") or die "couldn't make $outfolder/regions.tab\n";
truncate fileOUT, 0;
print fileOUT "regions\t$regiontable{'regions'}\n";
print fileOUT "exclusion_sets\t$regiontable{'exclusion-sets'}\n";
my $setlist = $regiontable{'exclusion-sets'};
my $regionlist = $regiontable{'regions'};
delete $regiontable{"regions"};
delete $regiontable{"exclusion-sets"};
foreach my $key (keys %regiontable) {
	print fileOUT "$key\t$regiontable{$key}\n";
}
close fileOUT;

#print melded matrix to melded.nex
open (fileOUT, ">$outfolder/melded.nex") or die "couldn't make melded.nex\n";
truncate fileOUT, 0;
print fileOUT "#NEXUS\nBegin DATA;\n";
print fileOUT "Dimensions ntax=$ntax nchar=$nchar;\n";
print fileOUT "Format datatype=NUCLEOTIDE gap=-;\nMatrix\n";
foreach my $key ( keys %mastertaxa ) {
	my $value = $mastertaxa{$key};
	print fileOUT "$key\t$value\n";
}
print fileOUT ";\nEnd;\n";

print fileOUT "\nBegin SETS;\n";
my @sets = split (/\t/, $setlist);
my @regions = split (/\t/, $regionlist);
my $x = 0;
foreach my $set (@sets) {
	my $region = @regions[$x];
	$region =~ s/.*\/(.+)\..*/$1/;
	print fileOUT "CHARSET $region = $set;\n";
	$x = $x + 1;
}
print fileOUT "End;";
close fileOUT;

print "Melded matrix is in melded.nex; summary of regions is in regions.tab\n";

sub uninterleave {
	my $inputfile = shift(@_);
	open (fileIN, "$inputfile") or die "no file named $inputfile";
	my @inputs = <fileIN>;
	
	#print "$inputfile\n";
	my $input = "";
	if ($inputs[1] eq "") { 
		$input = $inputs[0];
		$input =~ s/\r/\n/gs;
	} else {
		foreach my $line (@inputs) {
			$input .= "$line";
		}
	}
	close (fileIN);
		
	#remove comment blocks
	$input =~ s/\[.*?\]//sg;

	$input =~ /Format(.*?)\;/ig;
	my $format = "$1";
	$format =~ /gap=(.)/;
	my $gapchar = $1;

	#parse nexus block	
	$input =~ /Matrix(.*?)\;/isg;
	my $matrix = "$1";
	
	$matrix =~ /\s*?(\S+?)\s+/s;
	my $firsttaxon = "$1";
	my %taxa = ();
	
	my @sections = split /$firsttaxon/, $matrix;
	my @taxonlabels;
	my $x=0;
	foreach my $section (@sections) {
		$section =~ s/\s+$//s;
		if ($section eq "") { next; }
		$section = "$firsttaxon$section";
		$section =~ s/\s+$/\n/s;
		$section =~ s/\t//sg;
		my $numtaxa = ($section =~ s/\n/\n/sg);
		
		@taxonlabels = split /\n/, $section;
		if ($x == 0) {
			foreach my $taxonlabel (@taxonlabels) {
				my $currtaxonlabel = "$taxonlabel";
				$currtaxonlabel =~ s/\s+(.+?)$//;
				my $taxondata = $1;
				$taxondata =~ s/$gapchar/-/g;
				if ($taxa{ $currtaxonlabel } eq "") {
					$taxa{ $currtaxonlabel } = "g";
				} else {
					die "Taxon $currtaxonlabel is duplicated in file $inputfile. Please remove one of them.\n";
				}
			}
			$x++; 
		}
		foreach my $taxonlabel (@taxonlabels) {
			$taxonlabel =~ s/\s+(.+?)$//;
			my $taxondata = $1;
			$taxondata =~ s/$gapchar/-/g;
			if ($taxa{ $taxonlabel } eq "g") {
				$taxa{ $taxonlabel } = "";
			}
			$taxa{ $taxonlabel } = "$taxa{ $taxonlabel }" . "$taxondata";
		}
	}
	
	my $length = length $taxa{ $taxonlabels[0] };
	$taxa{ "length" } = $length;
	
	return \%taxa;
}

