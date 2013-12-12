#!/usr/bin/perl

use strict;
use Getopt::Long;
use File::Basename;

my $usage = "perl " . basename($0);
$usage .=	" <enzyme.tab> <sequences.fasta>\n\n";
$usage .=	"takes a tab-delimited list of recognition sequences and enzymes\n";
$usage .=	"and counts the number of times each enzyme will cut the sequences \n";
$usage .=	"of the fasta file.\n\n";

my $enzymefile = shift or die "$usage";
my $sequences = shift or die "$usage";

open my $F, "<$enzymefile" or die "$usage";

my $fs = readline $F;

my @enzymelist;
my @enzymecuts;

while ($fs ne "") {
	$fs =~ /(.+)\t(.+)/;
	push (@enzymelist, "$fs");
	push (@enzymecuts, 0);
	$fs = readline $F;
}

close $F;

open $F, "<$sequences" or die "$usage";

$fs = readline $F;
while ($fs ne "") {
	my $seq = "";
	if ($fs =~ />(.+)/) {
		print STDERR "\nprocessing $1\n";
		$seq = "";
	}
	
	$fs = readline $F;
	if ($fs eq "") {
		last;
	}
	while ($fs !~ />(.+)/) { # new sequence
		chomp $fs;
		$seq .= $fs;
		$fs = readline $F;
		if ($fs eq "") {
			last;
		}
	}
		
	# check this sequence for enzyme cuts:
	for (my $i = 0; $i < scalar (@enzymelist); $i++) {
		$enzymelist[$i] =~ /(.+)\t(.+)/;
		my $cutpattern = $1;		
		my $name = $2;
		my @cuts = split(/$cutpattern/, $seq);
		$enzymecuts[$i] += (scalar(@cuts) - 1);
		print STDERR "$i $name $enzymecuts[$i]...";
	}
}

print STDERR "Done, outputting final counts\n";

for (my $i = 0; $i < scalar (@enzymelist); $i++) {
	$enzymelist[$i] =~ /(.+)\t(.+)/;
	my $enzymename = $2;		
	print "$enzymename\t$enzymecuts[$i]\n";
}
