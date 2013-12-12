#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $keyword = @ARGV[0];
my $keynum = @ARGV[1];
my ($speciescounter, $species, $subsp, $lastsp, $data, $info);

open (fileIN, "shrub.tab") or die "woo";
my @lups = <fileIN>;
close (fileIN);

foreach my $lup (@lups)
{
	chomp $lup;
	(my $name, my $rest) = split (/\t/, $lup);
	print "$name\n";
	my @counties = split (/\|/, $rest);
	foreach my $county (@counties) {
		open (fileIN, ">>counties/$county.txt") or die "wah";
		seek(fileIN, 0, 2);
		print fileIN "$name\n";
		close (fileIN);
	}
}
