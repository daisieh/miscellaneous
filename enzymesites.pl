#!/usr/bin/perl 
use strict;

#take in enzyme table
my $inputfile = "enzymes.tab";
open (fileIN, "$inputfile") or die "no file named $inputfile";
my @inputs = <fileIN>;
close (fileIN);

my $input = "";
if ($inputs[1] eq "") { 
	$input = $inputs[0];
	$input =~ s/\r/\n/gs;
	@inputs = split(/\n/, $input);
} 

my $lastpattern = "";
my %enzymes = ();	#hash of enzymes, keyed by patterns
foreach my $line (@inputs) {
	(my $pattern, my $enzyme) = split (/\t/, $line);
	$pattern =~ s/(\w+).*$/$1/;
	if ($pattern ne $lastpattern) {
		chomp $enzyme;
		chomp $pattern;
		$enzymes{ $pattern } = $enzyme;
	}
	$lastpattern = $pattern;
}

#take in sequences
my $inputfile = @ARGV[0];
open (fileIN, "$inputfile") or die "no file named $inputfile";
my @inputs = <fileIN>;
close (fileIN);

$input = "";
if ($inputs[1] eq "") { 
	$input = $inputs[0];
	$input =~ s/\r/\n/gs;
} else {
	foreach my $line (@inputs) {
		$input .= "$line";
	}
}

$input =~ s/.*Matrix(.*?)\;.*/$1/gs;

@inputs = split(/\n/, $input);

my %workingenzymes = %enzymes;
my %seqresults = ();
foreach my $seq (@inputs) {
    for my $key ( keys %workingenzymes ) {
        my $value = $workingenzymes{$key};
		if ($seq =~ m/$key/g) {
			my $offset = pos($seq);
			print "$value\t$offset\n";
		}
    }
}

#open (fileOUT, ">enzymes.tab") or die "couldn't make melded.nex\n";
#truncate fileOUT, 0;
#print fileOUT "$result\n";
#close fileOUT;

