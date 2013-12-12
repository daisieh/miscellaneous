#!/usr/bin/perl
use strict;

if ($ARGV[0] eq "") {
	die "make_kml [icons_file] [localities_file]\n";
}

my $inputfile = $ARGV[0];
open (fileIN, "$inputfile") or die "no file named $inputfile";
my @inputs = <fileIN>;

my $input = "";
if ($inputs[1] eq "") {
	$input = $inputs[0];
	$input =~ s/\r/\n/gs;
} else {
	foreach my $line (@inputs) {
		$input .= "$line";
	}
}
close (fileIN);

my %colors = ();
my @inputs = split (/\n/, $input);

foreach my $color (@inputs) {
	(my $name, my $label) = split (/\s*\t/, $color);
	$colors{"$name"} = "$label";
}

$inputfile = $ARGV[1];
open (fileIN, "$inputfile") or die "no file named $inputfile";
@inputs = <fileIN>;

$input = "";
if ($inputs[1] eq "") {
	$input = $inputs[0];
	$input =~ s/\r/\n/gs;
} else {
	foreach my $line (@inputs) {
		$input .= "$line";
	}
}
close (fileIN);

my @inputs = split (/\n/, $input);
my $result = "";

#print headers
$result .= "<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>\n<kml xmlns=\"http://earth.google.com/kml/2.2\">\n<Document>
\t<name>localities.kml</name>\n\n";

foreach my $key ( keys %colors ) {
	my $label = $colors{$key};
	if ($label eq "") {
		$label = "brown";
	}
	$result .= "\t<StyleMap id=\"$label\">\n\t\t<Pair>\n\t\t\t<key>normal</key>\n\t\t\t<styleUrl>#$label</styleUrl>\n\t\t</Pair>\r";
	$result .= "\t\t<Pair>\n\t\t\t<key>highlight</key>\n\t\t\t<styleUrl>#$label</styleUrl>\n\t\t</Pair>\n\t</StyleMap>\n";
	$result .= "\t<Style id=\"$label\">\n\t\t<IconStyle>\n\t\t\t<Icon>\n\t\t\t\t<href>http://www.mutantdaisies.com/images/icons/$label.png</href>\n\t\t\t</Icon>\n\t\t</IconStyle>\n\t</Style>\n";
}

$result .= "\t<Folder>\n<name>localities</name>\n";
foreach my $line (@inputs) {
	(my $number, my $name, my $lat, my $long) = split (/\t/, $line);
	my $label = $colors{$name};
	if ($label eq "") {
		$label = "alb_alb";
	}
	if ($lat ne "") {
		$result .= "\t\t<Placemark>\n\t\t\t<name>$number</name>\n\t\t\t<styleUrl>#$label</styleUrl>\n";
		$result .= "\t\t\t<Point>\n\t\t\t\t<coordinates>$long,$lat</coordinates>\n\t\t\t</Point>\n\t\t</Placemark>\n";
	}
}

$result .= "\t</Folder>\n</Document>\n</kml>";

open (fileOUT, ">$inputfile.kml") or die "couldn't make results.kml\n";
truncate fileOUT, 0;
print fileOUT "$result\n";
close fileOUT;
