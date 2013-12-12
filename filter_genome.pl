#!/usr/bin/perl 
use strict;
use File::Basename;
use Getopt::Long;



my $usage = "perl " . basename($0);
$usage .=	" <file.sam> <file.fastq> <result>\n\n";

my $filterfile = '';

GetOptions ('filter=s' => \$filterfile);

my @scaffold_names;

if ($filterfile) {
	print "opening $filterfile\n";
	open my $F, "<$filterfile" or die "couldn't open genome fasta file";
	my $fs = readline $F;
	while ($fs ne "") {
		if ($fs =~ m/^>(.+?)\s/) {
			#print "pushing scaffold $1\n";
			push @scaffold_names, $1;
		}
		$fs = readline $F;
	}
}

if (@scaffold_names[0] eq "") {
	#print "no scaffold provided\n";
	push @scaffold_names, "chloroplast";
} 

my $samfilename = shift @ARGV or die "$usage";
my $fastafilename = shift @ARGV or die "$usage";
my $resultfilename = shift @ARGV or die "$usage";

open my $samfile, "<$samfilename" or die "couldn't open sam file";
my $fs = readline $samfile;

open my $outfile1, ">$resultfilename" or die "couldn't create result file";
truncate $outfile1, 0;

my $seq_hash = {};

#eat the header
while ($fs =~ m/^@/) {
	$fs = readline $samfile;
}

#hash all of the cp seqs
my $last_seq = "";
while ($fs ne "") {
	$fs =~ /^(.+?)\t(.+?)\t(.+?)\t.*/;
	my $seqid = $1;
	my $locus = $3;
	
	foreach my $comp_locus (@scaffold_names) {
		if ($locus =~ m/$comp_locus/) {
			if ($last_seq ne $seqid) {
				$seq_hash->{"$seqid"} = "0";
				$last_seq = $seqid;
			}
		}
	}
	$fs = readline $samfile;
}

close $samfile;


open my $F, "<$fastafilename" or die "couldn't open fasta file";
$fs = readline $F;

#process the fastq file
while ($fs ne "") {
	#seq id:
	my $first_header = "$fs";
	$fs = readline $F;

	#sequence:
	my $sequence = "$fs";
	$fs = readline $F;
	while (($fs !~ m/^\+/)) {
		chomp $sequence;
		$sequence .= "$fs";
		$fs = readline $F;
	}
	#quality header:
	my $second_header = "$fs";
	$fs = readline $F;

	#quality:
	my $quality = "$fs";
	$fs = readline $F;
	while (($fs !~ m/^@.*/)) {
		chomp $quality;
		$quality .= "$fs";
		$fs = readline $F;
		if (eof($F)) {
			last;
		}
	}
	
	#check to see if this sequence maps to the cp seqs:
	$first_header =~ /@(.+?)\/.*/;
	my $seqid = $1;
	if (exists  $seq_hash->{ $seqid }) {
		print $outfile1 "$first_header$sequence$second_header$quality";
	}

}



print "done\n";

close $F;
close $outfile1;
