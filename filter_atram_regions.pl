my $resultfile = shift;

my $regionhash = {};

open FH, "<", $resultfile;
foreach my $line (<FH>) {
	if ($line =~ /^(.+?)\t(.+?)\t(.+?)\t(.+)$/) {
		$regionhash->{$1}->{$2} = $4;
	}
}
close FH;

foreach my $region (keys $regionhash) {
	my $average = 0;

}
