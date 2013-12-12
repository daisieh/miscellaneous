#!/usr/bin/perl 
use strict;

my $inputfile = @ARGV[0];
my $outputfile = @ARGV[1];

if ($inputfile eq "") {
} else {
	my $result = "";
	open (fileIN, "$inputfile") or die "no file named $inputfile";
	my @inputs = <fileIN>;
	if ($inputs[1] eq "") {
		@inputs = split (/[\n|\r]/, $inputs[0]);
	}
	close (fileIN);
	foreach my $line (@inputs) {
		$line =~ s/^(.+?)\t(.+)/>$1\n$2\n\n/;
		$result .= "$line";
	}
	
	open (fileOUT, ">$outputfile") or die "$outputfile bah\n";
	truncate fileOUT, 0;
	print fileOUT "$result\n";
	close fileOUT;

	print "Wrote to $outputfile\n";
}