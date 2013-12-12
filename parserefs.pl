#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $filename = @ARGV[0];
open (fileIN, "$filename") or die "no file named $filename";
my $result;
my @inputs = <fileIN>;
if ($inputs[1] eq "") {
	@inputs = split (/[\n|\r]/, $inputs[0]);
}

if ($filename=~m/\.tab/) {
	print "tab\n";
	$result = "\*Journal Article\nAuthor\tYear\tTitle\tJournal\tVolume\tPages\tKeywords\n";
	foreach my $entry (@inputs) {
		$entry =~ m/^(.*)\t(.*)/;
		my $temp = $1;
		$temp =~ s/;/\/\//g;
		$temp =~ s/\/\/ /\/\//g;
		$entry =~ s/^(.*)\t/$temp\t/;
		$result .= "$entry\n";
	}
} else {
	print "txt\n";
	foreach my $entry (@inputs) {
		$entry =~ s/[\n|\r]+/AAA/g;
		$result .= "$entry\n";
	}
}
	open (fileOUT, ">$filename") or die "$filename bah\n";
	truncate fileOUT, 0;
	print fileOUT "$result";
	close fileOUT;
