#!/usr/bin/perl 
use strict;

my $inputfile = @ARGV[0];

if ($inputfile eq "") {
	print "nameseq [alignfile] [species|county]\n";
} else {
	open (fileIN, "$inputfile") or die "no file named $inputfile";
	my @inputs = <fileIN>;
	my $input = "";
	if ($inputs[1] eq "") { 
		$input = $inputs[0]; 
	} else {
		foreach my $line (@inputs) {
			$input .= "$line";
		}
	}
	close (fileIN);
		
	#remove comment blocks
	$input =~ s/\[.*?\]//sg;

	#parse nexus block	
	$input =~ /Matrix(.*?)\;/isg;
	my $matrix = "$1";
	
	$matrix =~ /\s*?(\S+?)\s+/s;
	my $firsttaxon = "$1";
	my %taxa = ();
	
	my @sections = split /$firsttaxon/, $matrix;
	my $count = 1;
	my @taxonlabels;
	foreach my $section (@sections) {
		$section =~ s/\s+$//s;
		if ($section eq "") { next; }
		$section = "$firsttaxon$section";
		$section =~ s/\s+$/\n/s;
		$section =~ s/\t//sg;
		my $numtaxa = ($section =~ s/\n/\n/sg);
		
		@taxonlabels = split /\n/, $section;
	
		foreach my $taxonlabel (@taxonlabels) {
			$taxonlabel =~ s/\s+(.+?)$//;
			$taxa{ $taxonlabel } = $taxa{ $taxonlabel } . $1;

		}
		$count++;
	}
	
	my $length = length $taxa{ $taxonlabel[0] };
	$taxa{ "length" } = $length;
}
