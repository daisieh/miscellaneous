#!/usr/bin/perl 
use strict;
use File::Basename;

for (my $i=0; $i<12; $i++) {
	my $command = "perl /Volumes/Bay_2/Scripts/Shared/fastq_to_fasta.pl /Volumes/Bay_4/cpDNA_BACs/demuxed/032_to_039/BAC_" . "$i"."_1.fastq\n";
	print "$command";
	
	system ($command) == 0 or die "killed\n";
	my $command = "perl /Volumes/Bay_2/Scripts/Shared/fastq_to_fasta.pl /Volumes/Bay_4/cpDNA_BACs/demuxed/032_to_039/BAC_" . "$i"."_2.fastq\n";
	print "$command";
	
	system ($command) == 0 or die "killed\n";
}