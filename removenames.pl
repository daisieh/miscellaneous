#!/usr/bin/perl 
use strict;

my $alignfile = @ARGV[0];
my $type = @ARGV[1];
my $namefile = "/Users/daisie/Documents/School/lupinus/molecular/samplenames.tab";

if ($alignfile eq "") {
	print "nameseq [alignfile] [species|county]\n";
} else {
	open (fileIN, "$alignfile") or die "no file named $alignfile";
	my @inputs = <fileIN>;
	if ($inputs[1] eq "") {
		@inputs = split (/[\n|\r]/, $inputs[0]);
	}
	close (fileIN);

	my $header = "";
	my $alignment = "";
	for (my $x=0; $x <= scalar(@inputs); $x++) {
		my $temp = $inputs[$x];
		if ($temp =~ m/.*\S+.*/) {
			if ($x < 6) {
				$header .= "$temp\n";
			} else {
					$alignment .= "$temp\n";
			}
		}
	}
	
	$alignment =~ s/_\w+//g;

	open (fileOUT, ">$alignfile") or die "$alignfile bah\n";
	truncate fileOUT, 0;
	print fileOUT "$header$alignment";
	close fileOUT;

	print "Wrote to $alignfile\n";
}
