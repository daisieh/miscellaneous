#!/usr/bin/perl 
use strict;
use File::Basename;


my $usage = "perl " . basename($0);
$usage .=	" <gene.tab> <genome.fasta>\n\n";

my $genefilename = shift @ARGV or die "$usage";
my $seqfilename = shift @ARGV or die "$usage";

open my $seq_file, "<$seqfilename" or die "couldn't open sequence file";
my $fs = readline $seq_file;
$fs = readline $seq_file;

my $sequence = "";
while ($fs ne "") {
	if ($fs !~ m/^>(.+?)\s/) {
		chomp $fs;
		$sequence .= "$fs";
	}
	$fs = readline $seq_file;
}

close $seq_file;

open my $gene_file, "<$genefilename" or die "couldn't open sequence file";
$fs = readline $gene_file;

#process the gene file
while ($fs ne "") {
	$fs =~ /(.+?)\t(.+?)\t(.+?)$/;
	my $gene_name = $1;
	my $gene_start = $2;
	my $gene_end = $3;
	my $gene_seq = substr $sequence, ($gene_start + 1) , ($gene_end - $gene_start);
	print ">$gene_name" . "_$gene_start" . "_$gene_end" . "\n$gene_seq\n";
	$fs = readline $gene_file;
}

close $gene_file;
