#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $filename = @ARGV[0];
open (fileIN, "$filename") or die "no file named $filename";
my @inputs = <fileIN>;
if ($inputs[1] eq "") {
	@inputs = split (/[\n|\r]/, $inputs[0]);
}

my $result = "\*Journal Article\nAuthor\tYear\tTitle\tJournal\tVolume\tPages\tPublisher\tKeywords\n";


foreach my $entry (@inputs) {	
	$result .= "$entry\n";
}

	open (fileOUT, ">$filename") or die "$filename bah\n";
	truncate fileOUT, 0;
	print fileOUT "$result";
	close fileOUT;
