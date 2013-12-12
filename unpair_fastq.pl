#!/usr/bin/perl 
use strict;
use File::Basename;


my $usage = "perl " . basename($0);
$usage .=	" <file.fastq> <result>\n\n";

my $fastafile = shift or die "$usage";
my $resultfile = shift or die "$usage";


open my $F, "<$fastafile" or die "couldn't open fasta file";
my $fs = readline $F;

open my $outfile1, ">$resultfile" . "_1.fastq" or die "couldn't create result file";
truncate $outfile1, 0;
open my $outfile2, ">$resultfile" . "_2.fastq" or die "couldn't create result file";
truncate $outfile2, 0;


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
	print "1";
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
	print "2\n";
		if (eof($F)) {
			last;
		}
	}
	print $outfile1 "$first_header$sequence$second_header$quality";
	
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
		print "3";

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
		print "4";
	}
	print $outfile2 "$first_header$sequence$second_header$quality";

}

print "done\n";

close $F;
close $outfile1;
close $outfile2;
