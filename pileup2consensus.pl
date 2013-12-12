#!/usr/bin/perl


use strict;
use Getopt::Long;

my $usage = "\n$0 <input file>\n\n$0 takes in a .vcf file from bcftools.\n";
$usage .= 	"To generate an uncompressed .vcf file from bcftools, \n";
$usage .=	"call samtools mpileup to generate a raw .bcf file, then call \n";
$usage .= 	"bcftools view -u <raw.bcf> to generate a .vcf file.\n\n";

my $pileup = shift or die "$usage";

#my $outputfile = "";	# option for specifying output file
#my $format = "sanger";	# option variable with default value
#GetOptions ('o=s' => \$outputfile, 'p=s' => \$format);

open my $F, "<$pileup" or die "$usage";

my $fs = readline $F;
my $name = "";
my $result = "";

while ($fs ne "") {
	if ($fs =~ /#/) {
		$fs = readline $F;
		next;
	}
	#      /(chr)(pos)(id)(ref)(alt).../
	$fs =~ /^(.+?)\t(.+?)\t(.+?)\t(.+?)\t(.+?)\t/;
	my $bp = "$4";
	my $alt = "$5";
	if ($fs =~ /INDEL/) {
		$alt =~ /(.+?),*.*\t/;
		$bp = "$alt";
		$bp =~ s/\,(.*)//;
		$result = substr ("$result", 0, -1);
	}
	elsif ($alt =~ /.*,X.*/) {
		$alt =~ /(.+?),/;
		$bp = "$1";
	}
	$result .= "$bp";
	$fs = readline $F;
}
print "$result\n";
