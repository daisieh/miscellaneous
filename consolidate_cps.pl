#!/usr/bin/perl 
use strict;
use File::Basename;

my @filelist = @ARGV;

foreach my $t (@filelist) {
	print $t;
}
#open my $PE1, "<$PE1file" or die "couldn't open $PE1file";

#while ($pe1line ne "") {
#	$pe1line = readline $PE1;

