#!/usr/bin/perl 
use strict;
use File::Basename;


my $usage = "perl " . basename($0);
$usage .=	" <fastafile> <resultfile>\n\n";

my $fastafile = shift or die "$usage";
my $resultfile = shift or die "$usage";
my $filterfile = "$fastafile.filtered";

my $pe1file = "$fastafile" . "_1.fasta";
my $pe2file = "$fastafile" . "_2.fasta";

print "blasting...";

my $command = "blastn -db /Volumes/Bay_2/Indexes/BLAST/DH10b.fsa -query $pe1file -outfmt '6 qseqid bitscore' -out $filterfile\n";
system ($command) == 0 or die "killed\n";

print "done (results in $filterfile)\n";

open my $F1, "<$pe1file" or die "couldn't open $pe1file";
my $fs1 = readline $F1;
open my $F2, "<$pe2file" or die "couldn't open $pe2file";
my $fs2 = readline $F2;

open my $this_file, "<$filterfile" or die "error opening filtered seqs file";

my $filtering = readline $this_file;
if (eof($this_file)) {
	print "no sequences blasted to e. coli\n";
	$filtering = "%%%";
}

while ($filtering =~ m/^\s+$/) {
	$filtering = readline $this_file;
	if (eof($this_file)) {
		print "%%%";
		$filtering = "%%%";
		last;
	}
}

print "filtering...";

open my $outfile, ">$resultfile.fasta" or die "couldn't create result file";
truncate $outfile, 0;

while ($fs1 ne "") {	
	#first line:
	my $first_header = "$fs1";
	chomp $first_header;
	$fs1 = readline $F1;
	$fs2 = readline $F2;

	#second line:
	my $sequence1 = "$fs1";
	my $sequence2 = "$fs2";
	$fs1 = readline $F1;
	$fs2 = readline $F2;
	while (($fs1 !~ m/>.*/)) {
		chomp $sequence1;
		chomp $sequence2;
		$sequence1 .= "$fs1";
		$sequence2 .= "$fs2";
		$fs1 = readline $F1;
		$fs2 = readline $F2;
		if (eof($F1)) {
			last;
		}
	}
	if ($filtering eq "%%%") {
		print $outfile "$first_header\/1\n$sequence1$first_header\/2\n$sequence2";
	} else {
	#	print "checking $filtering...";
		$filtering =~ /(.+?)\t/;
		my $curr_seq = $1;

		if ($first_header =~ m/$curr_seq/) {
			$filtering = readline $this_file;
			while ($filtering =~ m/$curr_seq/) {
				$filtering = readline $this_file;
				if ($filtering eq "") {
					last;
				}
			}
		} else {
			print $outfile "$first_header\/1\n$sequence1$first_header\/2\n$sequence2";
		}
	}
}

print "done\n";

close $this_file;
close $F1;
close $F2;
close $outfile;
