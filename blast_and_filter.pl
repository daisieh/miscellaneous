#!/usr/bin/perl 
use strict;
use File::Basename;
use Getopt::Long;
my $subjectfile = "~/Documents/shaw_regions/cp_primers.fasta";
my $queryfile = "~/Documents/shaw_regions/F2_CAACCAG.fasta";
my @args;
my $noclean = '';

my $usage = "perl " . basename($0);
$usage .=	"[-query fastafile] [-subject inputfiles]\n\n";
my $max_seqs = 0;

GetOptions ('query=s' => \$queryfile, 'subject=s' => \$subjectfile);

my $command = "blastn -task blastn-short -subject $subjectfile -query $queryfile -outfmt \"6 qseqid pident nident evalue bitscore\" -evalue 1e-4 -max_target_seqs=1 > blast_results\n";

print "$command";

system ($command) == 0 or die "killed\n";

print "...done\n";

open my $awk_commands, ">awk_commands";
truncate $awk_commands, 0;
print $awk_commands "BEGIN {RS = \">\"; FS=\"\\n\"}\n";

open my $F, "<blast_results" or die "blast failed\n";
my $line = readline $F;
my $lastline = "";
my $i = 0;
while ($line ne "") {
	$line =~ /(.+?)\t.*/;
	$line = "$1";
	if ($line ne $lastline) {
		print $awk_commands "\$1 ~ \/$line\/ { print }\n";
	}
	$lastline = "$line";
	$line = readline $F;
	if ($i > 1000) {
		last;
	}
	$i++;
}


close $awk_commands;
close $F;

$command = "awk -f awk_commands $queryfile | sed 's\/\\\(.*\\\)\\\#.*\/\\\>\\1\/' > awk_results.fasta\n";

print "$command";

system ($command) == 0 or die "killed\n";

print "...done\n";

