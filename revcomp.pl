#!/usr/bin/perl

use strict;

my $input = shift @ARGV;

if ($input =~ /\.fa/) {
	#input is a fasta file
	my ($taxa, $taxnames) = parse_fasta($input);
	foreach my $taxon (@$taxnames) {
		print ">$taxon\n";
		print reverse_complement($taxa->{$taxon}) . "\n";
	}
} else {
	print reverse_complement($input) . "\n";
}

sub reverse_complement {
	my $charstr = shift;

	# reverse the DNA sequence
	my $revcomp = reverse($charstr);

	# complement the reversed DNA sequence
	$revcomp =~ tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
	return $revcomp;
}

sub parse_fasta {
	my $inputfile = shift;

	my $taxa = {};
	my @taxanames = ();
	open (fileIN, "$inputfile") or die "no file named $inputfile";

	my $input = readline fileIN;
	my $length = 0;
	my $taxonlabel = "";
	my $sequence = "";
	while ($input ne "") {
		if ($input =~ /^>(.+)\s*$/) {
			$taxonlabel = $1;
			push @taxanames, $taxonlabel;
			if ($length > 0) {
				# we are at the next taxon; push the last one onto the taxon array.
				$taxa->{"length"} = $length;
				$length = 0;
			}
		} else {
			$input =~ /^\s*(.+)\s*$/;
			$taxa->{$taxonlabel} .= $1;
			$length += length($1);
		}
		$input = readline fileIN;
	}

	close (fileIN);
	return $taxa, \@taxanames;
}
