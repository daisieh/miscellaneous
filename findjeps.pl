#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $keyword = @ARGV[0];
my $keynum = @ARGV[1];
my ($speciescounter, $species, $subsp, $lastsp, $data, $info);

open (fileIN, "Jepson/jepslist.txt");
my @list = <fileIN>;
close (fileIN);

foreach my $lup (@list)
{
	chomp $lup;
	open (fileIN2, "Jepson/$lup.txt") or die "wah";
	my @chars = <fileIN2>;
	my $temp = <fileIN2>;
	close (fileIN2);
	(my $num, $temp) = split (/:/, @chars[0]);
	foreach my $char (@chars)
	{
		chomp $char;
		if ($char =~ m/^$keyword(.*)/i) {
			if ($keynum eq "") {
				print "$num $lup:\t\t$char\n";
			}
			elsif (($keynum ne "") && ($char =~ m/(.*)$keynum(.*)/i)) {
				print "$num $lup:\t\t$char\n";
			}
		} 
	}
}