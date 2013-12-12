#!/usr/bin/perl 
use strict;
use File::Basename;
use Getopt::Long;
my $queryfile = "~/Documents/Aq_co_cp.fasta";
my @args;
my $noclean = '';

my $usage = "perl " . basename($0);
$usage .=	"[-query fastafile] -input [inputfiles]\n\n";

GetOptions ('query=s' => \$queryfile, 'input=s{,}' => \@args, 'noclean' => \$noclean);

print "checking for valid index files...";
open my $F, "<$queryfile" or die "$queryfile isn't present\n";
close $F;
open $F, "<$queryfile.bwt" or die "$queryfile hasn't been indexed by bwa\n";

close $F;
print "done\n";

foreach my $filename (@args) {
	$filename =~ /(.*)\.fastq/;
	my $current_file = "$1";
	
	my $command = "perl ~/Documents/scripts_link/unpair_fastq.pl $current_file.fastq $current_file\n";
	
	print "$command";
	
	system ($command) == 0 or die "killed\n";
	
	print "...done\n";
	
	$command = "bwa aln $queryfile $current_file"."_1.fastq 1>$current_file"."_1.sai\n";
	print "$command";
	
	system ($command) == 0 or die "killed\n";
	
	print "...done\n";
	
	$command = "bwa aln $queryfile $current_file"."_2.fastq 1>$current_file"."_2.sai\n";
	print "$command";
	
	system ($command) == 0 or die "killed\n";
	
	print "...done\n";
	
	$command = "bwa sampe $queryfile $current_file"."_1.sai $current_file"."_2.sai $current_file"."_1.fastq $current_file"."_2.fastq 1> $current_file.sam\n";
	print "$command";
	
	system ($command) == 0 or die "killed\n";
	
	print "...done\n";
	
	$command = "perl ~/Documents/scripts_link/filter_genome.pl -filter $queryfile $current_file.sam $current_file.fastq cp_$current_file.fastq\n";
	
	print "$command";
	
	system ($command) == 0 or die "killed\n";
	
	print "...done\n";
	
	if (!$noclean) {
		$command = "rm $current_file"."_1.* $current_file"."_2.* $current_file.sam";
		
		print "$command";
		
		system ($command) == 0 or die "killed\n";
		print "...done\n";
	}
}
