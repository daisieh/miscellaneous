#!/usr/bin/perl 
use strict;


# sequences.tab must be in the format "$sample\t$region\t$sequence", 
# sorted by region, then sample number.
open (fileIN, "/Users/daisie/Documents/School/lupinus/molecular/sequences.tab");
my @inputs = <fileIN>;
if ($inputs[1] eq "") {
	@inputs = split (/[\n|\r]/, $inputs[0]);
}
close (fileIN);

my $exportfile = @ARGV[0];

my $region_count = 1;

my @samples; 
my @lengths;
my @sequences;
my @regionlength;
my @regions;
my $x = 0;
my $curr_region = "";
my $curr_length = 0;

foreach my $entry (@inputs) {
	(my $sample, my $region, my $sequence) = split (/\t/, $entry, 3);
	$sequence =~ s/-//g;
	my $length = length($sequence);
	($region, undef) = split(/\R/, $region, 2);
	
	push @lengths, $length;
	push @sequences, $sequence;
	push @samples, "$sample\_$region";
	
	if ($length > $curr_length) {
		$curr_length = $length;
	}

	if ($curr_region ne $region) {
		push @regions, $region;
		push @regionlength, $curr_length;
		$curr_region = $region;
	}	
}

#okay! now we will make the nexus file.
my $result = "\#NEXUS\n\nBegin DATA\;\n";

my $ntax = scalar(@samples);
my $nchar = $curr_length;

$result .= "     Dimensions ntax=$ntax nchar=$nchar\;\n";
$result .= "     Format datatype=NUCLEOTIDE gap=-\;\n";
$result .= "     Matrix\n";

my $line;
for ($x = 0; $x < $ntax; $x++) {
	$line = "$sequences[$x]";
	chomp $line;
	my $filler = "-";
	$filler =~ s/-/$& x ($nchar-length($sequences[$x]))/e;
	$line = $line . $filler;
	print length($line) . "\n";
	$result .= "\t\t" . $samples[$x] . "\t" . $line . "\n";
}


$result .= "\n\;\nEnd\;\n";
chdir "/Users/daisie/Documents/School/lupinus/molecular/analyses";

open (fileOUT, ">$exportfile.nex");
flock(fileOUT, 2);
print fileOUT "$result";
close (fileOUT);