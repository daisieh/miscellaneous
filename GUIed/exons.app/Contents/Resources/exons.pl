#!/usr/bin/perl 
use strict;

my $genbank = @ARGV[0];

my $newfile = @ARGV[1];
if ($newfile eq "") {
	if ($genbank =~ /\./) {
		$genbank =~ /(^.*)\.(.*$)/;
		$newfile = "$1" . "_exons.nex";
	}
	else {
		$newfile = "$genbank" . "_exons";
	}
	print "outputting to $newfile\n";
}

open (fileIN, $genbank);
my @input = <fileIN>;
close (fileIN);

my $line = $input[0];
if ($input[1] ne "") {
	foreach my $i (@input) {
		$line .= $i;
	}
}
$line =~ s/[\n|\r]//g;
#print "$line";

#find nucleotide sequence
$line =~ /ORIGIN(.*)\/\//;
my $seq = $1;
$seq =~ s/\s*\d*\s//g;

#find CDS fragments
$line =~ /CDS(.*)\/((gene)|(translation))/;
my $join = $1;
$join =~ s/.*join\(//;
$join =~ s/\).*//;
$join =~ s/ //g;
$join =~ s/[\<|\>]//g;
my @exons = split (/\,/, $join);

#concat exons only, adding spacer between exons
my $result;
my $spacer = "------";
foreach my $exon (@exons) {
	(my $start, my $end) = split (/\.\./, $exon);
	my $temp = "";
	$start = $start - 1;
	my $size = $end - $start;
	$seq =~ /^(.{\Q$start\E}?)(.{\Q$size\E}?)/;
	$temp = $2;
	$result .= $spacer . $temp;
}

$result =~ s/^\Q$spacer\E//;
my $result_length = length($result);
my $nexus_result = "#NEXUS\n\nBegin DATA\;\nDimensions ntax=1 nchar=$result_length\;\nFormat datatype=NUCLEOTIDE gap=-\;\n\nMatrix\nCDS  " . $result . "\n\;\nEnd\;";

open (fileOUT, ">$newfile") or die "$newfile couldn't be opened\n";
truncate fileOUT, 0;
print fileOUT "$nexus_result";
close fileOUT;