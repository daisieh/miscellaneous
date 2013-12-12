#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $filename = @ARGV[0];
my $newfile = @ARGV[1];
if ($newfile eq "") {
	$filename =~ s/\.nex//;
	my $newfile = "$filename" . "_sorted.nex";
}

open (fileIN, $filename);
my @input = <fileIN>;
close (fileIN);

if ($input[1] eq "") {
	@input = split (/[\n\r]/, $input[0]);
}

my @header;
my @data;
my @footer;
foreach my $line (@input) {
	if ($line =~ /^\t\d/) {
		push @data, $line;
	} else {
		if ($data[0] == 0) {
			push @header, $line;
		} else {
			push @footer, $line;
		}
	}
}
@data = sort @data;
my $x = scalar(@header);

my $result = join "\r", @header;
$result .= join "\r", @data;
$result .= join "\r", @footer;

open (fileOUT, ">$newfile") or die "$newfile couldn't be opened\n";
truncate fileOUT, 0;
print fileOUT "$result";
close fileOUT;

print "Wrote sorted data in $newfile\n";

