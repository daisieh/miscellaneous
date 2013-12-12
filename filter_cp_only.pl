#!/usr/bin/perl 
use strict;
use File::Basename;


my $usage = "perl " . basename($0);
$usage .=	" <file.sam> <file.fastq> <result>\n\n";


my $samfilename = shift or die "$usage";
my $fastafilename = shift or die "$usage";
my $resultfilename = shift or die "$usage";


open my $samfile, "<$samfilename" or die "couldn't open sam file";
my $fs = readline $samfile;

open my $outfile1, ">$resultfilename" or die "couldn't create result file";
truncate $outfile1, 0;

my $seq_hash = {};

#eat the header
while ($fs =~ m/^@/) {
	$fs = readline $samfile;
}

#hash all of the cp seqs
my $last_seq = "";
while ($fs ne "") {
	$fs =~ /^(.+?)\t(.+?)\t(.+?)\t.*/;
	my $seqid = $1;
	my $locus = $3;
	
	if ($locus =~ m/chloroplast/) {
		if ($last_seq ne $seqid) {
			$seq_hash->{"$seqid"} = "0";
			$last_seq = $seqid;
		}
	}

	$fs = readline $samfile;
}

close $samfile;

# for my $seq ( keys %$seq_hash ) {
#  	print $outfile1 "$seq\n";
# }

open my $F, "<$fastafilename" or die "couldn't open fasta file";
$fs = readline $F;

#process the fastq file
while ($fs ne "") {
	#seq id:
	my $first_header = "$fs";
	$fs = readline $F;

	#sequence:
	my $sequence = "$fs";
	$fs = readline $F;
	while (($fs !~ m/^\+/)) {
		chomp $sequence;
		$sequence .= "$fs";
		$fs = readline $F;
	}
	#quality header:
	my $second_header = "$fs";
	$fs = readline $F;

	#quality:
	my $quality = "$fs";
	$fs = readline $F;
	while (($fs !~ m/^@.*/)) {
		chomp $quality;
		$quality .= "$fs";
		$fs = readline $F;
		if (eof($F)) {
			last;
		}
	}
	
	#check to see if this sequence maps to the cp seqs:
	#  1836:4:2102:15959:193993#AACTACG
	# @1836:4:1101:1915:1895#AACTACG/1 Q=__aeeec
	$first_header =~ /@(.+?)\/.*/;
	my $seqid = $1;
	if (exists  $seq_hash->{ $seqid }) {
		print $outfile1 "$first_header$sequence$second_header$quality";
	}

}



print "done\n";

close $F;
close $outfile1;
