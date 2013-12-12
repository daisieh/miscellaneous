#!/usr/bin/perl


use strict;
use Getopt::Long;

use File::Basename;

my $usage = "\nperl " . basename($0);
$usage .=	" <inputfile.vcf> [-f jointfrequency]\n\n";
$usage .=	"-f is optional, the default frequency is 0.01.\n";
$usage .=	"Creates a list of SNP pairs that are less than 200 bp apart\n";
$usage .=	"and have a combined frequency greater than jointfrequency.\n\n";
$usage .= 	"To generate an uncompressed .vcf file from bcftools, \n";
$usage .=	"call samtools mpileup to generate a raw .bcf file, then call \n";
$usage .= 	"bcftools view -u <raw.bcf> to generate a .vcf file.\n\n";

my $pileup = shift or die "$usage";

my $specified_freq = 0.01;
GetOptions ('f=s' => \$specified_freq);

open my $F, "<$pileup" or die "$usage";

my $fs = readline $F;
my $name = "";
my $result = "";
my $last_snp = "";
my $last_freq = "";

while ($fs ne "") {
	if ($fs =~ /#/) {
		#$result .= "$fs";
		$fs = readline $F;
		next;
	}
	#	   /  1    2   3    4    5    6      7      8
	#      /(chr)(pos)(id)(ref)(alt)(QUAL)(FILTER)(INFO).../
	$fs =~ /^(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t/;
	my $chr = "$1";
	my $pos = "$2";
	my $bp = "$4";
	my $alt = "$5";
	my $info = "$8";
	$info =~ /DP=(\d+);I16=(.+)/;
	my $reads = $1;
	my $i16 = "$2";
	if ($reads > 30) {
		if ($alt =~ /.*,.*/) {
			$i16 =~ s/I16=//;
			my @flags = split (/,/, $i16);
			my $freq = ($flags[2]+$flags[3])/$reads;
			if ($last_snp eq "") {
				$last_snp = "$pos";
				$last_freq = $freq;
			} else {
				if ($pos - $last_snp < 200) {
					my $joint_freq = $last_freq * $freq;
					if ($joint_freq > $specified_freq) {
						print "$chr\t$last_snp-$pos\t$joint_freq\n";
					}
				}
				$last_snp = "$pos";
				$last_freq = $freq;
			}
		}
	}
	$fs = readline $F;
}
