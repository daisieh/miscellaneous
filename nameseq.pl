#!/usr/bin/perl 
use strict;

#use LWP::Simple;

my $alignfile = @ARGV[0];
my $type = @ARGV[1];
my $namefile = "/Users/daisie/Documents/School/lupinus/molecular/samplenames.tab";
my $result = "";

if ($alignfile eq "") {
	print "nameseq [alignfile] [species|county|elev]\n";
} elsif ($type eq "") {
	print "nameseq [alignfile] [species|county|elev]\n";
} else {
	open (fileIN, "$alignfile") or die "no file named $alignfile";
	my @inputs = <fileIN>;
	if ($inputs[1] eq "") {
		@inputs = split (/[\n|\r]/, $inputs[0]);
	}
	close (fileIN);

	my $header = "";
	my $alignment = "";
	for (my $x=0; $x <= scalar(@inputs); $x++) {
		my $temp = $inputs[$x];
		if ($temp =~ m/.*\S+.*/) {
			if ($alignment eq "") {
				if ($temp =~ m/Matrix/) {
					$alignment = "Matrix\r";
				} else {
					$header .= "$temp\r";
				}
			} else {
					$alignment .= "$temp\r";
			}
		}
	}
	$alignment =~ s/\[.*?\]//g; #eat the comments; they're not relevant anymore
	$header =~ s/datatype\s*=\s*nucleotide/datatype=dna/i;
	
	open (fileIN2, "$namefile") or die "no names";
	my @names = <fileIN2>;
	if ($names[1] eq "") {
		@names = split (/[\n|\r]/, $names[0]);
	}
	close (fileIN2);
	
	foreach my $name (@names) {
		(my $sample, my $county, my $species, my $elev) = split (/\t/, $name);
		chomp $sample;
		chomp $species;
		chomp $county;
		chomp $elev;
	
		if (length($sample) > 1) {
			my $newname = "$county";
			
			if ($type eq "species") {
				$newname = "$species";
			}
			elsif ($type eq "county") {
				$newname = "$county";
			}
			elsif ($type eq "elev") {
				$newname = "$elev";
			}
		
				$alignment =~ s/$sample([_\s]+)/$sample\Q_\E$newname$1/gs;
		}
	}
	open (fileOUT, ">$alignfile") or die "$alignfile bah\n";
	truncate fileOUT, 0;
	print fileOUT "$header$alignment";
	close fileOUT;

	print "Wrote to $alignfile\n";
}
