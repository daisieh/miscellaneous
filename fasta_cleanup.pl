#!/usr/bin/perl
use strict;

my $search_fasta = shift @ARGV;

open SEARCH_FH, "<", $search_fasta;
my $name = "";
my $seq = "";
while (my $line = readline SEARCH_FH) {
	chomp $line;
	if ($line =~ />(.*)/) {
		if ($name ne "") {
			print ">$name#$seq\n";
		}
		$name = $1;
		$seq = "";
	} else {
		$seq .= $line;
	}
}
print ">$name#$seq\n";
close SEARCH_FH;
