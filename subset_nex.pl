#!/usr/bin/perl 
use strict;

my $alignfile = @ARGV[0];
my $num_char = @ARGV[1];
my $num_iterations = @ARGV[2];

if ($alignfile eq "") {
} else {
	open (fileIN, "$alignfile") or die "no file named $alignfile";
	my @inputs = <fileIN>;
	if ($inputs[1] eq "") {
		@inputs = split (/[\n|\r]/, $inputs[0]);
	}
	close (fileIN);
	
	(my $header, my $alignment, my $footer) = parse_nex(\@inputs);
	
	for (my $i=1; $i <=$num_iterations; $i++) {
		iterate ($header, $alignment, $footer, $i);
	}
}

sub parse_nex {
	my $var = shift (@_);
	my @inputs = @$var;
	#split nexus file into header, alignment, and footer
	my $header = "";
	my $alignment = "";
	my $footer = "";
	my $header_done = 0;
	my $alignment_done = 0;
	for (my $x=0; $x <= scalar(@inputs); $x++) {
		if ($header_done == 0) {
			$header .= "$inputs[$x]";
			if ($inputs[$x] =~ m/[\s^]+Matrix\s+/i) { 
				$header_done = 1;
			}
		} elsif ($alignment_done == 0) {
			if ($inputs[$x] =~ m/(.*)(;.*)/) {
				$alignment_done = 1;
				$alignment .= "$1";
				$footer .= "$2";
				next;
			}
			$alignment .= "$inputs[$x]";
		} else {
			$footer .= "$inputs[$x]";
		}
	}
	return $header, $alignment, $footer;
}

sub iterate {
	my $header = shift (@_);
	my $alignment = shift (@_);
	my $footer = shift (@_);
	my $curr_iter = shift (@_);
	#find nchar term
	$header =~ m/nchar=(.+);/im;
	my $total_char = $1;
	my @rand_list;
	for (my $i=0; $i < $total_char; $i++) {
		push @rand_list, $i;
	}

	#choose string of $num_char characters to pick from the alignment
	my @chars_list;
	for (my $i=0; $i < $num_char; $i++) {
		my $temp = splice (@rand_list, int(rand($total_char)), 1);
		push @chars_list, $temp;
	}
	
	#loop through alignment, picking out the $num_char characters from @chars_list
	my $new_align = "";
	my $ntax=0;
	foreach my $line (split (/[\n|\r]/, $alignment)) {
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		(my $name, my $seq) = split (/\s+/, $line);
		my $newseq = "";
		for (my $i=0; $i < $num_char; $i++) {
			$newseq .= substr ($seq, $chars_list[$i], 1);
		}
		$new_align .= "$name\ $newseq\n";
		$ntax++;
		#print "$newseq\n";
	}
	#construct output file name
	my $filename = "$alignfile";
	$filename =~ s/(.+)\.nex/$1\_$num_char\_$curr_iter\.nex/;
	
	open (fileOUT, ">$filename") or die "$filename bah\n";
	truncate fileOUT, 0;
	print fileOUT "#NEXUS\nBegin DATA;\nDimensions ntax=$ntax nchar=$num_char;\nFormat datatype=NUCLEOTIDE gap=-;\nMatrix\n";
	print fileOUT "$new_align";
	print fileOUT ";\n\nEnd;";
	close fileOUT;

	print "Wrote to $filename\n";
}
