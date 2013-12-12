#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $filename = @ARGV[0];
open (fileIN, "$filename") or die "no file named $filename";
my @inputs = <fileIN>;
if ($inputs[1] eq "") {
	@inputs = split (/[\n|\r]/, $inputs[0]);
}

foreach my $entry (@inputs) {	
	$entry =~ m/(.*) (.*)$/;
	my $last = $2;
	my $first = $1;
	chomp $first;
	print "$last, $first\n";
}

