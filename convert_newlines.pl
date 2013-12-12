#!/usr/bin/perl
use strict;
use File::Basename;
use File::Spec::Functions qw(canonpath rel2abs abs2rel);
use File::Find;
use File::Slurp;
use Cwd;


my $dir = shift;
my $currdir = getcwd;

my @dirs = ();
push @dirs, rel2abs($dir);
find(\&wanted, @dirs);


sub wanted {
	my $origfile = $File::Find::name;
	my $dir = $File::Find::dir;
	$dir = abs2rel($dir, $currdir);
	my $thispath = getcwd;
	if (-T $origfile) {
		my $wholefile = read_file($origfile);
		if ($wholefile =~ /\r/) {
			print "$origfile has non-Unix returns\n";
			$wholefile =~ s/\r\n/\n/g;
			$wholefile =~ s/\r/\n/g;
			open FH, ">", "$origfile" or die "$! : couldn't open $origfile\n";
			print FH "$wholefile\n";
			close FH;
		} else {
			print "leaving $origfile alone\n";

		}
		chdir $thispath;
	}
}

