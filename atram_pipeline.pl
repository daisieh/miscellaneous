#!usr/bin/perl

use strict;
require "subfuncs.pl";

my $samplefile = shift @ARGV;
my $regionfile = shift @ARGV;

if ($regionfile eq "") {
	print "Usage: pipeline.pl samples regions\n";
	exit;
}
my $samples = {};
my @samplenames = ();
open FH, "<", "$samplefile" or die "couldn't open $samplefile";
foreach my $line (<FH>) {
	if ($line =~ /(.+?)\t(.+)/) {
		$samples->{$1} = $2;
		push @samplenames, $1;
	}
}
close FH;

my $regions = {};
my @regionnames = ();
open FH, "<", $regionfile;
foreach my $line (<FH>) {
	if ($line =~ /(.+?)\t(.+)/) {
		$regions->{$1} = $2;
		push @regionnames, $1;
	}
}
close FH;

open LOG_FH, ">", "result_log.txt";
my @regionfiles = ();
foreach my $region (@regionnames) {
	push @regionfiles, "$region.fasta";
	open FH, ">", "$region.fasta";
	truncate FH, 0;
	close FH;

	# for each sample:
	foreach my $sample (@samplenames) {
		my $outname = "$region.$sample";
		print "$outname\n";
		#system_call ("perl ~/TRAM/sTRAM.pl -reads $samples->{$sample} -target $regions->{$region} -iter 10 -ins_length 400 -frac 0.01 -assemble Velvet -out $outname");
		#system_call ("rm $outname.*.blast.fasta");
		#system_call ("rm -r $outname.Velvet");
		# run percentcoverage to get the contigs nicely aligned
		system_call ("perl ~/TRAM/test/PercentCoverage.pl $regions->{$region} $outname.best.fasta $region");

		# find the one best contig (one with fewest gaps)
		system_call ("blastn -task blastn -query $region.exons.fasta -subject $regions->{$region} -outfmt '6 qseqid bitscore' -out $region.$outname.blast");
		open FH, "<", "$region.$outname.blast";
		my $contig = "";
		my $score = 0;
		foreach my $line (<FH>) {
			if ($line =~ /(\S+)\s+(\S+)$/) {
				if ($1 =~ /$region/) {
					next;
				}
				if ($2 > $score) {
					$contig = $1;
					$score = $2;
				}
			}
		}
		close FH;
		$score =~ s/^(\d+\.\d{2}).*$/\1/;
		print LOG_FH "$region\t$sample\t$contig\t$score\n";
		if ($contig ne "") {
			# pick this contig from the fasta file
			my ($taxa, $taxanames) = parse_fasta ("$region.exons.fasta");
			# write this contig out to the region.fasta file, named by sample.
			open FH, ">>", "$region.exons.fasta";
			print "adding $contig to $region.exons.fasta\n";
			print FH ">$sample\n$taxa->{$contig}\n";
			close FH;
			($taxa, $taxanames) = parse_fasta ("$outname.best.fasta");
			# write this contig out to the region.fasta file, named by sample.
			open FH, ">>", "$region.full.fasta";
			print "adding $contig from $outname.best.fasta to $region.full.fasta\n";
			print FH ">$sample\n$taxa->{$contig}\n";
			close FH;
		}
	}
}

close LOG_FH;

