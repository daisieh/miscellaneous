#!/usr/bin/perl 
use strict;
use File::Basename;

my $usage = "perl " . basename($0);
$usage .=	" <indexfile.txt> <doubleSNPs.txt>\n\n";
$usage .= 	"Reads an indexed list of scaffold locations from indexfile.txt, \n";
$usage .=	"reads a list of double SNPs from doubleSNPs.txt, and calculates \n";
$usage .= 	"how many times a random 200bp fragment will contain a double SNP, \n";
$usage .=	"for 50,000 random fragments.\n\n";

my $indexfile = shift or die "$usage";
my $doublesnpsfile = shift or die "$usage";

open my $log, ">log.txt" or die "no log";
truncate $log, 0;


#read in all of the indices
open my $F, "<$indexfile" or die "bah";
my $fs = readline $F;
$fs =~ /.+\t(\d+)/;
my $total = $1;
$fs = readline $F;
my @scaffolds, my @offsets;
my $total_scaffolds = 0;
while ($fs ne "") {
	$fs =~ /(.+)\t(\d+)/;
	my $name = $1;
	my $offset = $2;
	push @scaffolds, $name;
	push @offsets, $offset;
	$total_scaffolds++;
	$fs = readline $F;
}
close $F;

#read in all of the double SNPs
open $F, "<$doublesnpsfile" or die "bah";
my %snps = ();

my $fs = readline $F;
$fs =~ /(.+)\t(\d+)-(\d+)\t/;
my $currname = $1;
my $name = "";
my $end1 = $2;
my $end2 = $3;
my @curr_scaf_list;

while ($fs ne "") {
	#scaffold_1	1873-1902	0.00140625
	$fs =~ /(.+)\t(\d+)\-(\d+)\t/;
	$name = $1;
	$end1 = $2;
	$end2 = $3;

	if ($name ne $currname) { #we're on the next scaffold
		$snps {$currname} = [ @curr_scaf_list ];
		$currname = "$name";
		#print $log "moving to $name\n";
		@curr_scaf_list = ();
	} else {
		#print $log "still on $name\n";
		push @curr_scaf_list, "$end1-$end2";
	}

	$fs = readline $F;
}
$snps {$currname} = [ @curr_scaf_list ];


my $key, my $value;
# while (($key, $value) = each %snps) {
# 	my @list = @{$value};
# 	print $log "$key\n";
# 	foreach my $x (@list) {
# 		print $log "\t$x\n";
# 	}
# }
close $F;

my %cuts = ();

print $log "iterations\n";
my $total_snps_within_200 = 0;
my $iterations_that_count = 0;
for (my $i=0; $i<50000; $i++) {
	my $r = int (rand ($total));
	my $curr_scaf = "";
	my $curr_offset = 0;
	my $curr_index = int ($total_scaffolds / 2);
	my $curr_interval = int ($curr_index / 2);
	while ($curr_offset == 0) {
		if ($curr_index >= $total_scaffolds - 1) { # if we've reached the top index, $r must be in the last scaffold
			$curr_scaf = "$scaffolds[$curr_index]";
			$curr_offset = $r - $offsets[$curr_index];
#			print $log "found it! $curr_scaf $curr_offset\n";			
			last;
		} elsif ($curr_index == 0) { # if we've reached the bottom index, $r must be in the first scaffold
			$curr_scaf = "$scaffolds[$curr_index]";
			$curr_offset = $r;
#			print $log "found it! $curr_scaf $curr_offset\n";
			last;
		} elsif (($offsets[$curr_index] <= $r) && ($r <= $offsets[$curr_index+1])) {
			$curr_scaf = "$scaffolds[$curr_index]";
			$curr_offset = $r - $offsets[$curr_index];
#			print $log "found it! $curr_scaf $curr_offset\n";
			last;
		} elsif ($r < $offsets[$curr_index]) {
			#print $log "$r < $offsets[$curr_index], going down $curr_interval from $curr_index\n";
			$curr_index -= $curr_interval;
			
		} elsif ($r > $offsets[$curr_index]) {
			#print $log "$r > $offsets[$curr_index], going up $curr_interval from $curr_index\n";
			$curr_index += $curr_interval;
		}
		$curr_interval = int ($curr_interval / 2);
		if ($curr_interval == 0) {$curr_interval = 1;}
	}
	# at this point, we're looking to see if there is a double snp within 200bp of $curr_offset on $curr_scaffold
	#print $log "$curr_scaf\t$curr_offset\n";
	
	# let's get the list of SNPs on this scaffold
	my $curr_scaf_list = $snps{$curr_scaf};

	# the if statement shouldn't be necessary if we have a complete genome-wide list of snps on all scaffolds
	if ($curr_scaf_list ne "") {
		$iterations_that_count++;
		#print $log "$curr_scaf\t$curr_scaf_list\n";
		my @scaf_snps = @{$curr_scaf_list};
		my $total_snps = @scaf_snps;
		
		# look through the array of snps on this scaffold to see if any ends are within 200bp of $curr_offset
		my $curr_snp = 0;
		$curr_index = int ($total_snps / 2);
		$curr_interval = int ($curr_index / 2);
		my $currend1 = $curr_offset;
		my $currend2 = $curr_offset + 200;
		my $lastend1 = 0;
		my $lastend2 = 0;
		
		#print $log "$i\t";
		while ($curr_snp == 0) {
			@scaf_snps[$curr_index] =~ /(\d+)-(\d+)/;
			my $snpend1 = $1;
			my $snpend2 = $2;
			
			if ($curr_index >= $total_snps) {
				#print $log "$currend1-$currend2 is above $lastend1-$lastend2\n";
				last;
			}
			if ($curr_index == 0) {
				#print $log "$currend1-$currend2 is below $lastend1-$lastend2\n";
				last;
			}
			if ((($snpend1 < $currend2) && ($snpend2 > $currend2)) || (($snpend1 < $currend1) && ($snpend2 > $currend1))) {
				#print $log "$currend1-$currend2 straddles $snpend1-$snpend2\n";
				last;
			} 
			
			if (($snpend1 >= $currend1) && ($snpend2 > $currend1) && ($snpend1 < $currend2) && ($snpend2 <= $currend2)) {
				# FOUND ONE
				$total_snps_within_200++;
				$curr_snp = $snpend1;
				print $log "$i\tFOUND ONE on $curr_scaf: $snpend1-$snpend2 is within $currend1-$currend2\n";
				last;
			} elsif ($currend2 <= $snpend1) {
				#look down
				if (($curr_interval == 1) && ($currend1 >= $lastend2)) {
					#print $log "$currend1-$currend2 fell between $lastend1-$lastend2 and $snpend1-$snpend2\n";
					last;
				}
				#print $log "($curr_offset + 200) <= $snpend1-$snpend2, going down $curr_interval from $curr_index\n";
				$lastend1 = $snpend1;
				$lastend2 = $snpend2;
				$curr_index -= $curr_interval;
			} elsif ($currend1 >= $snpend2) {
				#look up
				if (($curr_interval == 1) && ($currend2 <= $lastend1)) {
					#print $log "$currend1-$currend2 fell between $lastend1-$lastend2 and $snpend1-$snpend2\n";
					last;
				}
				#print $log "$curr_offset >= $snpend1-$snpend2, going up $curr_interval from $curr_index\n";
				$lastend1 = $snpend1;
				$lastend2 = $snpend2;
				$curr_index += $curr_interval;
			} else {
				print $log "ERROR: $currend1-$currend2 does not contain $snpend1-$snpend2\n";
				last;
			}
			
			my $last_interval = $curr_interval;
			$curr_interval = int ($curr_interval / 2);
			if ($curr_interval == 0) {$curr_interval = 1;}
			#print $log ">";
		}

	}
}

print "DONE! Total snps in the $iterations_that_count fragments: $total_snps_within_200\n";

close $log;
