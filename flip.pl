#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $filename = @ARGV[0];
open (fileIN, $filename);
my @input = <fileIN>;
close (fileIN);

if ($input[1] eq "") {
	@input = split (/[\n\r]/, $input[0]);
}

my $result = "";


foreach my $line (@input) {
	$result = "$line\n$result";
}

print $result;
