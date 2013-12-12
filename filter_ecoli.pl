#!/usr/bin/perl 
use strict;
use File::Basename;


my $usage = "perl " . basename($0);
$usage .=	" <fastafile> <resultfile>\n\n";

my $fastafile = shift or die "$usage";
my $resultfile = shift or die "$usage";
my $filterfile = "$fastafile.filtered";

print "blasting...";

my @blastargs = ("blastn", "-db", "/Volumes/Bay_2/Indexes/BLAST/DH10b.fsa", "-query", "$fastafile", "-outfmt", "6 qseqid bitscore", "-out", "$filterfile");
system (@blastargs);

print "done (results in $filterfile)\n";

open my $F, "<$fastafile" or die "couldn't open fasta file";
my $fs = readline $F;

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

while ($fs ne "") {	
	#first line:
	my $first_header = "$fs";
	$fs = readline $F;

	#second line:
	my $sequence = "$fs";
	$fs = readline $F;
	while (($fs !~ m/>.*/)) {
		chomp $sequence;
		$sequence .= "$fs";
		$fs = readline $F;
		if (eof($F)) {
			last;
		}
	}
	if ($filtering eq "%%%") {
		print $outfile "$first_header$sequence";
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
	#		print "skipping\n";
		} else {
			print $outfile "$first_header$sequence";
		}
	}
}

print "done\n";

close $this_file;
close $F;
close $outfile;
