#!/usr/bin/perl 
use strict;
use File::Basename;

my $usage = "perl " . basename($0);
$usage .=	" <PE1.fastq> <PE2.fastq> <outputdir>\n";

my $PE1file = shift or die "$usage";
my $PE2file = shift or die "$usage";
my $outputdir = shift or die "$usage";

my @barcodes = ( "AGGCCT", "CGGCGT", "ACAGTT", "TCGTCT", "CACAGT", "GCTGAT", "TACAAT", "CGTAGT", "GTAGTT", "TAGTAT", "GTCTCT", "AGACTT" );
#construct hash using these barcodes as keys
#12 into each group.

#my %barcode_hash;
my (@barcode_buckets1, @barcode_buckets2);
my @barcode_groups;
my $curr_barcodes = "";
my $non_barcoded1 = "";
my $non_barcoded2 = "";

for (my $j=0; $j<12; $j++) {
# 	for (my $i=0; $i<12; $i++) {
# 		$curr_barcodes .= "@barcodes[$i+(12*$j)]" . " ";
# 	}
	$curr_barcodes = "@barcodes[$j]";
 	push (@barcode_groups, $curr_barcodes);
 	push (@barcode_buckets1, "");
 	push (@barcode_buckets2, "");
 #	print "$curr_barcodes\n";
 	$curr_barcodes = "";
}

open my $PE1, "<$PE1file" or die "couldn't open $PE1file";
my $pe1line = "boo";
open my $PE2, "<$PE2file" or die "couldn't open $PE2file";
my $pe2line = "boo";

my $x = 0;
while ($pe1line ne "") {
	#first line:
	$pe1line = readline $PE1;
	$pe2line = readline $PE2;
	my $first_header = "$pe1line";
	my $first_header2 = "$pe2line";

	#second line:
	$pe1line = readline $PE1;
	$pe2line = readline $PE2;
	$pe1line =~ /(\w{6})(\w+)/;
	my $barcode1 = $1;
	my $sequence1 = $2;
	$pe2line =~ /(\w{6})(\w+)/;
	my $barcode2 = $1;
	my $sequence2 = $2;

	#third line:
	$pe1line = readline $PE1;
	$pe2line = readline $PE2;
	my $second_header = "$pe1line";
	
	#fourth line:
	$pe1line = readline $PE1;
	$pe2line = readline $PE2;
	$pe1line =~ /(.{6})(.+)/;
	my $qualA1 = $1;
	my $qualB1 = $2;
	$pe2line =~ /(.{6})(.+)/;
	my $qualA2 = $1;
	my $qualB2 = $2;
	
	#determine which bucket this sequence is in:
	my $seq_bucket = 99;
	if ($barcode1 eq $barcode2) {
		for (my $i=0; $i<12; $i++) {
			$curr_barcodes = $barcode_groups[$i];
			if ($curr_barcodes =~ m/$barcode1/) {
				$seq_bucket = $i;
			}
		}
	}

	#if the barcode is in a bucket, push it in:
	if ($seq_bucket < 12) {
		$barcode_buckets1[$seq_bucket] .= "$first_header$sequence1\n$second_header$qualB1\n";
		$barcode_buckets2[$seq_bucket] .= "$first_header$sequence2\n$second_header$qualB2\n";
	} else {
		$non_barcoded1 .= "$first_header$barcode1$sequence1\n$second_header$qualA1$qualB1\n";
		$non_barcoded2 .= "$first_header$barcode2$sequence2\n$second_header$qualA2$qualB2\n";
	}
	$seq_bucket = 99;

	$x++;
	if ($x%1000000 == 0) {
		print "$x\n";
	}
}

close $PE1;
close $PE2;

#write out the files
for (my $i=0; $i<12; $i++) {
	my $filename1 = "$outputdir/BAC_$i"."_1.fastq";
	my $filename2 = "$outputdir/BAC_$i"."_2.fastq";
	open my $file, ">>$filename1" or die "couldn't open $filename1";
	print $file "$barcode_buckets1[$i]";
	close $file;

	open my $file, ">>$filename2" or die "couldn't open $filename2";
	print $file "$barcode_buckets2[$i]";
	close $file;
}

open my $this_file, ">>$outputdir/non_barcoded1.fastq" or die "couldn't open non_barcoded1";
print $this_file "$non_barcoded1";
close $this_file;

open $this_file, ">>$outputdir/non_barcoded2.fastq" or die "couldn't open non_barcoded2";
print $this_file "$non_barcoded2";
close $this_file;

