#!/usr/bin/perl 
use strict;
use File::Basename;

my $usage = "perl " . basename($0);
$usage .=	" <fastafile.txt> <doubleSNPs.txt>\n\n";

my $fastafile = shift or die "$usage";

my @barcodes = ( "ACACGT", "ACAGTT", "ACCAGT", "ACCTCT", "ACGCAT", "ACGTGT", "ACTGGT", "ACTAAT", "AGACTT", "AGAGAT", "AGCATT", "AGCTGT", "AGGCCT", "AGGTTT", "AGTGTT", "AGTACT", "ATACAT", "ATAGCT", "ATCAAT", "ATCTTT", "ATGCGT", "ATGTAT", "ATTGAT", "ATTAGT", "CAACGT", "CAAGTT", "CACAGT", "CACTCT", "CAGCAT", "CAGTGT", "CATGGT", "CATAAT", "CGACAT", "CGAGCT", "CGCAAT", "CGCTTT", "CGGCGT", "CGGTAT", "CGTGAT", "CGTAGT", "CTACCT", "CTAGGT", "CTCACT", "CTCTAT", "CTGCTT", "CTGTCT", "CTTGCT", "CTTATT", "GAACTT", "GAAGAT", "GACATT", "GACTGT", "GAGCCT", "GAGTTT", "GATGTT", "GATACT", "GCACAT", "GCAGCT", "GCCAAT", "GCCTTT", "GCGCGT", "GCGTAT", "GCTGAT", "GCTAGT", "GTACGT", "GTAGTT", "GTCAGT", "GTCTCT", "GTGCAT", "GTGTGT", "GTTGGT", "GTTAAT", "TAACAT", "TAAGCT", "TACAAT", "TACTTT", "TAGCGT", "TAGTAT", "TATGAT", "TATAGT", "TCACCT", "TCAGGT", "TCCACT", "TCCTAT", "TCGCTT", "TCGTCT", "TCTGCT", "TCTATT", "TGACGT", "TGAGTT", "TGCAGT", "TGCTCT", "TGGCAT", "TGGTGT", "TGTGGT", "TGTAAT" );
#construct hash using these barcodes as keys
#12 into each group.
open my $F, "<$fastafile" or die "bah";
my $fs = readline $F;

#my %barcode_hash;
my @barcode_buckets;
my @barcode_groups;
my $curr_barcodes = "";
my $non_barcoded = "";
for (my $j=0; $j<8; $j++) {
	for (my $i=0; $i<12; $i++) {
		#$barcode_hash{@barcodes[$i]} = "";
			#print "$i+(12*$j)\n";
		$curr_barcodes .= "@barcodes[$i+(12*$j)]" . " ";
	}
	push (@barcode_groups, $curr_barcodes);
	push (@barcode_buckets, "");
	print "$curr_barcodes\n";
	$curr_barcodes = "";
}

my $x = 0;
while ($fs ne "") {
	
	#(@SOLEXA1.+)\r(.+)\r(\+SOLEXA1.+)\r(.+)\r
	#first line:
	my $first_header = "$fs";
	$fs = readline $F;

	#second line:
	$fs =~ /(\w{6})(\w+)/;
	my $barcode = $1;
	my $sequence = $2;
	
	$fs = readline $F;

	#third line:
	my $second_header = "$fs";
	$fs = readline $F;
	
	#fourth line:
	$fs =~ /(.{6})(.+)/;
	my $qual1 = $1;
	my $qual2 = $2;
	$fs = readline $F;
	
	#determine which bucket this sequence is in:
	my $seq_bucket = 99;
	for (my $i=0; $i<8; $i++) {
		$curr_barcodes = $barcode_groups[$i];
		if ($curr_barcodes =~ m/$barcode/) {
			$seq_bucket = $i;
		}
	}

	#if the barcode is in a bucket, push it in:
	if ($seq_bucket < 9) {
		#$barcode_hash{$barcode} .= "$first_header$sequence\n$second_header$qual2\n";
		$barcode_buckets[$seq_bucket] .= "$first_header$sequence\n$second_header$qual2\n";
	} else {
		$non_barcoded .= "$first_header$barcode$sequence\n$second_header$qual1$qual2\n";
	}
	$seq_bucket = 99;

	$x++;
	if ($x%1000000 == 0) {
		print "$x\n";
	}
}

close $F;

#write out the files
for (my $i=0; $i<8; $i++) {
	my $filename = "$i" . "bucket";
	open my $this_file, ">$filename.txt" or die "no log";
	truncate $this_file, 0;
	print $this_file "$barcode_buckets[$i]";
	
	close $this_file;
}

open my $this_file, ">non_barcoded.txt" or die "no log";
truncate $this_file, 0;
print $this_file "$non_barcoded";
close $this_file;

