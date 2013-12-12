#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $keyword = @ARGV[0];
open (fileIN, "$keyword");
my @counties = <fileIN>;
close (fileIN);

my $prevcounty = "";
my $countylist = "";
foreach my $county (@counties) {
	my $currcounty = $county;
	chomp $currcounty;
	if ($currcounty eq $prevcounty) {
	}
	elsif ($currcounty eq "Locality") {
	}
	else {
		$countylist = $countylist . $currcounty . "\n";
		$prevcounty = $currcounty;
	}
}

print $countylist;
