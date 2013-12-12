#!/usr/bin/perl 
use strict;

use LWP::Simple;


open (fileIN, "Jepson/jepslist.txt");
my @species = <fileIN>;
close (fileIN);

my $data = "";
foreach my $curr (@species) {
	chomp $curr;
	open (fileIN, "Jepson/$curr.txt");
	my @appenddata = <fileIN>;
	close (fileIN);

	print "writing $curr...\n";
	foreach my $x (@appenddata) {
		$data = "$data$x";
	}
	$data .= "\n";
}

open (fileOUT, ">merged.txt");
print fileOUT "$data";
close (fileOUT);
