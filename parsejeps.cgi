#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $homeurl = "http://ucjeps.berkeley.edu/cgi-bin/get_JM_treatment.pl\?";

my $counter = 4024; #to 4135
my ($speciescounter, $species, $subsp, $lastsp, $data, $info);
my @chars;

while ($counter <= 4135)
{
	$data = get ("$homeurl$counter");
	
	$species = $data;
	$subsp = "";
	$species =~ s/(.*)<title>(\s*)//s;
	$species =~ s/<\/title>(.*)//s;
	$species =~ s/UC\/JEPS\: TJM treatment for \%20//;
	chomp $species;	
	if ($species eq "UC\/JEPS: TJM treatment for ")
	{
		$subsp = get ("$homeurl$speciescounter,$counter");
		$subsp =~ s/(.*)<title>(\s*)//s;
		$subsp =~ s/<\/title>(.*)//s;
		$subsp =~ s/(.*)var\.\%20//;
		chomp $subsp;
		$species = $lastsp;
		print "$speciescounter, $counter: $subsp\n";
	} else 
	{
		$speciescounter = $counter;
		$lastsp = $species;
		$subsp = "";
		print "$counter: $species\n";
	}
	$info = $data;
	$info =~ s/(.*)<blockquote>//s;
	$info =~ s/<\/blockquote>(.*)//s;
	$info =~ s/(.*)<font>(\s*)//s;
	$info =~ s/<\/font>(.*)//s;
	$info =~ s/<b>//sg;
	$info =~ s/<\/b>//sg;
	
	$info =~ s/\&\#150\;/-/gs;
	$info =~ s/\&\#150\;/-/gs;
	chomp $info;
	@chars = split ("<br>", $info);
	
	chdir "/Users/daisie/Documents/lupines/Jepson/";
	if ($subsp ne "") {
		mkdir "$lastsp\ vars";
		chdir "$lastsp\ vars";
		open(fileOUT, ">$subsp.txt");
	} else {
		open(fileOUT, ">$species.txt");
	}
	flock(fileOUT, 2);
	print fileOUT "$counter: $species\n";

	foreach my $char(@chars)
	{
		print fileOUT "$char\n";
	}
	close(fileOUT);
	$counter++;
}