#!/usr/bin/perl 
use strict;
use File::Basename;

my $usage = "perl " . basename($0);
$usage .=	" <fastafile.txt> <doubleSNPs.txt>\n\n";

my $fastafile = shift or die "$usage";

my @barcodes = ( "ACACGT", "AGGCCT", "CAACGT", "CGGCGT", "GAACTT", "GCGCGT", "TAACAT", "TCGCTT", "ACAGTT", "AGGTTT", "CAAGTT", "CGGTAT", "GAAGAT", "GCGTAT", "TAAGCT", "TCGTCT", "ACCAGT", "AGTGTT", "CACAGT", "CGTGAT", "GACATT", "GCTGAT", "TACAAT", "TCTGCT", "ACCTCT", "AGTACT", "CACTCT", "CGTAGT", "GACTGT", "GCTAGT", "TACTTT", "TCTATT", "ACGCAT", "ATACAT", "CAGCAT", "CTACCT", "GAGCCT", "GTACGT", "TAGCGT", "TGACGT", "ACGTGT", "ATAGCT", "CAGTGT", "CTAGGT", "GAGTTT", "GTAGTT", "TAGTAT", "TGAGTT", "ACTGGT", "ATCAAT", "CATGGT", "CTCACT", "GATGTT", "GTCAGT", "TATGAT", "TGCAGT", "ACTAAT", "ATCTTT", "CATAAT", "CTCTAT", "GATACT", "GTCTCT", "TATAGT", "TGCTCT", "AGACTT", "ATGCGT", "CGACAT", "CTGCTT", "GCACAT", "GTGCAT", "TCACCT", "TGGCAT", "AGAGAT", "ATGTAT", "CGAGCT", "CTGTCT", "GCAGCT", "GTGTGT", "TCAGGT", "TGGTGT", "AGCATT", "ATTGAT", "CGCAAT", "CTTGCT", "GCCAAT", "GTTGGT", "TCCACT", "TGTGGT", "AGCTGT", "ATTAGT", "CGCTTT", "CTTATT", "GCCTTT", "GTTAAT", "TCCTAT", "TGTAAT" );
#construct hash using these barcodes as keys
#12 at a time.
open my $F, "<$fastafile" or die "bah";
my $fs = readline $F;

my %barcode_hash;
my $curr_barcodes = "";
my $non_barcoded = "";

for (my $i=0; $i<96; $i++) {
	$barcode_hash{@barcodes[$i]} = "";
	$curr_barcodes .= "@barcodes[$i]" . " ";
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

	#if the barcode is in this set, hash it:
	if ($curr_barcodes =~ m/$barcode/) {
		$barcode_hash{$barcode} .= "$first_header$sequence\n$second_header$qual2\n";
	} else {
		$non_barcoded .= "$first_header$barcode$sequence\n$second_header$qual1$qual2\n";
	}

	$x++;
	if ($x%1000000 == 0) {
		print "$x\n";
	}
}

close $F;
my $i = 0;
while ((my $key, my $value) = each %barcode_hash) {
	my $filename = "$i" . "_" . "$key";
	open my $this_file, ">$filename.txt" or die "no log";
	truncate $this_file, 0;
	print $this_file "$value";
	
	$i++;
	close $this_file;
}

open my $this_file, ">non_barcoded.txt" or die "no log";
truncate $this_file, 0;
print $this_file "$non_barcoded";
close $this_file;

