#!/usr/bin/perl 
use strict;

use LWP::Simple;

my $args = @ARGV[0];
open (fileIN, $args);
my @seqs = <fileIN>;
close (fileIN);

my $arg2 = @ARGV[1];
open (fileIN, $arg2);
my @taxa = <fileIN>;
close (fileIN);



my $data = "";
my $x = 0;
foreach my $curr (@seqs) {
	my $taxon = @taxa[$x++];
	$taxon =~ s/(\[.*\])+//g;
	$taxon =~ s/>//;
	$taxon =~ s/\s//g;
	chomp $taxon;
	chomp $curr;
	(my $first, my $sec, my $third) = split( /\*/, $curr);
	my $first_pos = length ($first);
	my $second_pos = $first_pos + length($sec) ;
	print "$taxon\t";
#print "\{ data gene \{ locus \"psbJ\" \} , location int \{ from $first_pos , to $second_pos , strand plus , id local str \"$taxon\" \} \}\n";
print "\{ data gene \{ locus \"psbJ\" \} , partial TRUE , location int \{ from $first_pos , to $second_pos , strand minus , id local str \"$taxon\" , fuzz-from lim lt \} \}\n";
}

