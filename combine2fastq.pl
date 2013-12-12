#!/usr/bin/perl

# AUTHOR: Joseph Fass
# LAST REVISED: August 2009
# 
# The Bioinformatics Core at UC Davis Genome Center
# http://bioinformatics.ucdavis.edu
# Copyright (c) 2008 The Regents of University of California, Davis Campus.
# All rights reserved.

use strict;
use Getopt::Long;

my $usage = "\nusage: $0 <reads (fasta format)> <qualities (fasta format)> [-o <outputfile>] [-p sanger/solexa/illumina]\n\n".
            "Merges fasta and qual files into a single Sanger fastq file (STDOUT).\n\n".
            "-o specifies an output file instead of STDOUT.\n\n".
            "-p specifies a phred encoding: default is Sanger, but can specify \"solexa\" for ".
            "Solexa/Illumina 1.0 or \"illumina\" for Illumina 1.3+.\n\n";

my $seqfile = shift or die $usage;
my $qualfile = shift or die $usage;

my $outputfile = "";	# option for specifying output file
my $format = "sanger";	# option variable with default value
GetOptions ('o=s' => \$outputfile, 'p=s' => \$format);

open my $F, "<$seqfile" or die $usage;
open my $Q, "<$qualfile" or die $usage;

my $fs = readline $F;
my $qs = readline $Q;
my $name = "";
my $result = "";

if ($outputfile ne "") {
	print "starting process...\n";
}

while ($fs ne "") {
	if ($fs =~ m/>(.+)/) { 
		#if we're looking at a new entry, set the name and move on to the next lines
		$name = "$1";
		chomp $name;
		$fs = readline $F;
		$qs = readline $Q;
	} else {
		#we're processing the rest of the entry
		my $seq = "";
		my $qual = "";
		while (($name ne "")) {
			#as long as we're not at the end of the entry...
			if ($fs !~ m/>.+/) {
				#this line is part of the sequence, so concat it and move to the next line
				chomp $fs;
				$seq .= "$fs";
				$fs = readline $F;
			}
			if ($qs !~ m/>.+/) {
				#this line is part of the quality, so concat it and move to the next line
				chomp $qs;
				$qual .= " $qs";
				$qs = readline $Q;
			}
			if ((($fs eq "") || ($fs =~ m/>.+/)) && (($qs eq "") || ($qs =~ m/>.+/))) {
				#if, for either file, we're at the next name or at the end of the file,
				#we should print out the result for this entry.
				
				#parse the quality line
				my @quals = split(/\s+/,$qual);
				my $fastq = "";
				my $qv;
				for (my $i=1; $i<=$#quals; $i++) {
					if ($format eq "solexa") {
						$qv = $quals[$i] + 59;
					} elsif ($format eq "illumina") {
						$qv = $quals[$i] + 64;
					} else {
						$qv = $quals[$i] + 33;
					}
					$fastq .= chr($qv);
				}
				
				#print the entry and then break to loop again
				if ($outputfile ne "") {
					print "$name...\n";
					$result .= ">$name\n$seq\n+\n$fastq\n";
				} else {
					print ">$name\n$seq\n+\n$fastq\n";
				}
				$name = "";
				last;
			} 
		}
		
	}
}

if ($outputfile ne "") {
	open OUT, ">$outputfile" or die "Couldn't open output file.\n";
	truncate OUT, 0;
	print OUT "$result\n";
	print "Wrote to $outputfile\n";
	close OUT;
}

close F; close Q;