#!/usr/bin/perl 
use strict;

use LWP::Simple;

open (fileIN, "counties.txt");
my @counties = <fileIN>;
close (fileIN);

foreach my $county (@counties)
{
	chomp $county;
	open (fileIN2, "counties/$county.txt") or die "wah";
	my @species = <fileIN2>;
	close (fileIN2);
	my $count = scalar @species;
	print "$county\t\t$count\n";
}
