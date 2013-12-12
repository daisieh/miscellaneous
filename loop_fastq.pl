#!/usr/bin/perl 
use strict;
use File::Basename;

my $filenum = "";

my $prefix = "BAC_Pool_NoIndex_L008_R";

for (my $i=33; $i<39; $i++) {
	if ($i<10) { $filenum = "00" . $i; }
	else { $filenum = "0" . $i; }
	
	my $command = "perl /Volumes/Bay_2/Scripts/Daisie/demux_barcodes.pl /Volumes/Bay_4/cpDNA_BACs/R1/$prefix" . "1_$filenum.fastq /Volumes/Bay_4/cpDNA_BACs/R3/$prefix" . "3_$filenum.fastq /Volumes/Bay_4/cpDNA_BACs/demuxed\n";
	
	print "$command";
	
	system ($command) == 0 or die "killed\n";
}