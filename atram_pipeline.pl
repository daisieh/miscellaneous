#!usr/bin/perl

use strict;

my $samplefile = shift @ARGV;
my $regionfile = shift @ARGV;

if ($regionfile eq "") {
	print "Usage: pipeline.pl samples regions\n";
	exit;
}
$samplefile = "tram_samples.txt";
my $samples = {};
open FH, "<", "$samplefile" or die "boo $samplefile";
foreach my $line (<FH>) {
	if ($line =~ /(.+?)\t(.+)/) {
		$samples->{$1} = $2;
	}
}
close FH;

my $regions = {};
open FH, "<", $regionfile;
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
		system ("perl ~/TRAM/sTRAM.pl -reads $samples->{$sample} -target $regions->{$region} -iter 10 -ins_length 400 -frac 0.2 -assemble Velvet -out $outname");
		# run percentcoverage to get the contigs nicely aligned
		system ("perl ~/TRAM/test/PercentCoverage.pl $regions->{$region} $outname.all.fasta $region");

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
