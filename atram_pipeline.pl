#!usr/bin/perl

use strict;

my $samples = shift @ARGV;
my $regions = shift @ARGV;

if ($regions eq "") {
	print "Usage: pipeline.pl samples regions\n";
	exit;
}
print "opening $samples\n";
my $samples = {};
open FH, "<", "$samples" or die "boo";
foreach my $line (<FH>) {
	print "$line\n";
	if ($line =~ /(.+?)\t(.+)/) {
	print "hello\n";
		$samples->{$1} = $2;
	}
}
close FH;

print "opening $regions\n";

my $regions = {};
open FH, "<", $regions;
foreach my $line (<FH>) {
	if ($line =~ /(.+?)\t(.+)/) {
		$regions->{$1} = $2;
	}
}
close FH;

foreach my $region (keys $regions) {
	# for each sample:
	foreach my $sample (keys $samples) {
		my $outname = "$region.$sample";
		print "$outname\n";
		system ("~/TRAM/sTRAM.pl -reads $samples->{$sample} -target $regions->{$region} -iter 10 -ins_length 400 -frac 0.2 -assemble Velvet -out $outname");
		# run percentcoverage to get the contigs nicely aligned
		system ("~/TRAM/test/PercentCoverage.pl $regions->{$region} $outname.all.fasta $region");

		# find the one best contig (one with fewest gaps)
		open FH, "<", "$region.Table.txt";
		my $contig = "";
		my $percent = 0;
		foreach my $line (<FH>) {
			if ($line =~ /(.+?)\t(\d+?)\t(.+)/) {
				if ($3 > $percent) {
					$contig = $1;
				}
			}
		}
		close FH;
		print "$region $sample $contig\n";
		if ($contig ne "") {
			# pick this contig from the fasta file
			my ($taxa, $taxanames) = parsefasta ("$outname.all.fasta");
			# write this contig out to the region.fasta file, named by sample.
			open FH, ">>", "$region.fasta";
			print FH ">$sample\n$taxa->{$contig}\n";
			close FH;
		}
	}
}

sub parsefasta {
	my $fastafile = shift;

	my $taxa = {};
	my @taxanames = ();
	open fileIN, "<", "$fastafile";
	my $input = readline fileIN;
	my $taxonlabel = "";
	my $sequence = "";
	while ($input !~ /^\s*$/) {
		if ($input =~ /^>(.+)\s*$/) {
			$taxonlabel = $1;
			push @taxanames, $taxonlabel;
		} else {
			$input =~ /^\s*(.+)\s*$/;
			$taxa->{$taxonlabel} .= $1;
		}
		$input = readline fileIN;
	}

	close (fileIN);
	return $taxa, \@taxanames;
}
