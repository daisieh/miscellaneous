#!/usr/bin/perl 
use strict;

my $inputfile = @ARGV[0];
my $outputfile = @ARGV[1];

if ($inputfile eq "") {
} else {
	open (fileIN, "$inputfile") or die "no file named $inputfile";
	my @inputs = <fileIN>;
	if ($inputs[1] eq "") {
		@inputs = split (/[\n|\r]/, $inputs[0]);
	}
	close (fileIN);
	my $result = "";
	my $scaffold = 0;
	my $same_record = 0;
	my $identities = 0;
	my $expect = 0;
	my $score = 0;
	foreach my $line (@inputs) {
		#Query=  AqMyb12.E3.F3
		if ($line =~ m/.*Query=\s*(.*)/) {
			$line = $1;
			$scaffold = 0;
			$identities = 0;
			$expect = 0;
			$score = 0;
			$same_record = 0;
			$result .= "$line";
			next;
		}

		#Effective search space used (end of record)
		if ($line =~ m/Effective search space used/) {
			$same_record = 0;
			$result .= "\n";
			next;
		}
		
		#> scaffold_15
		if ($line =~ m/>.*scaffold_(.+)$/) {
			$scaffold = $1;
			next;
		}
		
		# Identities = 15/17 (88%), Gaps = 0/17 (0%)
		if ($line =~ m/Identities = (.+?),/) {
			$identities = $1;
			next;
		}
 		
 		#Score = 40.1 bits (20),  Expect = 0.001
		if ($line =~ m/Score = (.+) bits.*Expect = (.+)$/) {
			$score = $1;
			$expect = $2;
			next;
		}


		#Sbjct  599364  CCAGGCTTCAAGGAAGAACA  599345
		if ($line =~ m/Sbjct\s+(\d+).*?(\d+)/) {
			if ($score >= 30) {
#			print "$1\t$2\n";
				($same_record == 1) ? ($result .= "\x0b") : ($result .= "\t");
				$same_record = 1;
				($1 < $2) ? $line = $1 : $line = $2;
				$result .= "$scaffold:$line, $identities";
			}
			next;
		}

		
	}
	
	open (fileOUT, ">$outputfile") or die "$outputfile bah\n";
	truncate fileOUT, 0;
	print fileOUT "$result\n";
	close fileOUT;

	print "Wrote to $outputfile\n";

	
}

