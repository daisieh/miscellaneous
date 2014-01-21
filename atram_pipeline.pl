#!usr/bin/perl

use strict;
use Getopt::Long;
use Pod::Usage;
require "subfuncs.pl";

if (@ARGV == 0) {
    pod2usage(-verbose => 1);
}

my $help = 0;
my $samplefile = "";
my $regionfile = "";
my $kmer = 31;
my $iter = 10;
my $frac = 0.01;

GetOptions ('samples=s' => \$samplefile,
            'regions=s' => \$regionfile,
            'kmer=i' => \$kmer,
            'iter=i' => \$iter,
			'frac=f' => \$frac,
            'help|?' => \$help) or pod2usage(-msg => "GetOptions failed.", -exitval => 2);

if ($help) {
    pod2usage(-verbose => 1);
}



if (($regionfile eq "") || ($samplefile eq "")) {
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
foreach my $region (@regionnames) {
	open FH, ">", "$region.exons.fasta";
	truncate FH, 0;
	close FH;
	open FH, ">", "$region.full.fasta";
	truncate FH, 0;
	close FH;

	# for each sample:
	foreach my $sample (@samplenames) {
		my $outname = "$region.$sample";
		print "$outname\n";
		system_call ("perl ~/TRAM/sTRAM.pl -reads $samples->{$sample} -target $regions->{$region} -iter $iter -ins_length 400 -frac $frac -assemble Velvet -out $outname -kmer $kmer -complete");
		system_call ("rm $outname.*.blast.fasta");
		system_call ("rm -r $outname.Velvet");
		# run percentcoverage to get the contigs nicely aligned
		system_call ("perl ~/TRAM/test/PercentCoverage.pl $regions->{$region} $outname.best.fasta $outname");

		# find the one best contig (one with fewest gaps)
		system_call ("blastn -task blastn -query $region.exons.fasta -subject $regions->{$region} -outfmt '6 qseqid bitscore' -out $outname.blast");
		open FH, "<", "$outname.blast";
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
		system_call ("rm $outname.blast");

		open FH, "<", "$outname.Table.txt";
		$contig = "";
		my $percent = 0;
		foreach my $line (<FH>) {
			if ($line =~ /(\S+)\t(\S+)\t(\S+)$/) {
				if ($1 =~ /$region/) {
					next;
				}
				if ($3 > $percent) {
					$contig = $1;
					$percent = $3;
				}
			}
		}
		close FH;

		$percent =~ s/^(\d+\.\d{2}).*$/\1/;
		print LOG_FH "$region\t$sample\t$contig\t$score\t$percent\n";
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

