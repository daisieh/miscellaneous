#!/usr/bin/perl 
use strict;

my $alignfile = @ARGV[0];

if ($alignfile eq "") {
	print "nameseq [alignfile] [species|county]\n";
} else {
	open (fileIN, "$alignfile") or die "no file named $alignfile";
	my @inputs = <fileIN>;
	close (fileIN);
	
	my $input = "";
	if ($inputs[1] eq "") { 
		$input = $inputs[0];
		$input =~ s/\r/\n/gs;
	} else {
		foreach my $line (@inputs) {
			$input .= "$line";
		}
	}
	my $result = "$input";
	#eat everything until you get to the <wpt> tags
	$result =~ s/^.*?<wpt/<wpt/s;
	
	#split the entries using the </wpt> tags
	my @entries = split (/<\/wpt>/, $result);
	
	$result = "";
	
	foreach my $entry (@entries) {
		if ($entry =~ m/<wpt/) {
			#eat the <extensions> tag
			$entry =~ s/<extensions>.*<\/extensions>//s;
			
			$entry =~ m/<name>(.*?)<\/name>/;
			my $name = $1;
			$entry =~ m/lat="(.*?)"/;
			my $lat = $1;
			$entry =~ m/lon="(.*?)"/;
			my $long = $1;
			
			my $ele = "0";
			if ($entry =~ m/<ele>(.*?)<\/ele>/) {
				$ele = $1;
			}
			
			$result .= "$name\t$lat\t$long\t$ele\n";
			

			
			print "$ele\n";
		}
	}

	my $filename = "$alignfile";
	$alignfile =~ s/\..*//;
	open (fileOUT, ">$filename.tab") or die "couldn't make $filename.tab\n";
	truncate fileOUT, 0;
	print fileOUT "$result";
	close fileOUT;

	print "Wrote to $filename.tab\n";
}
