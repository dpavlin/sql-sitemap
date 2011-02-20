#!/usr/bin/perl

use warnings;
use strict;

use DBI;
use Data::Dump qw(dump);

my $debug = 0;

die "usage: $0 sql/config.sql\n" unless @ARGV;

my $c;

while(<>) {
	if ( m/^--\s*(\w+):(\S+)/ ) {
		$c->{$1} = $2;
		warn "# config $1 = $2\n";
	} else {
		$c->{sql} .= $_;
	}
}

my $config = $1 if $c->{url} =~ s{/(\w+)\.xml}{} or
die "can't find /config.xml in url";

my $dbh = DBI->connect( 'DBI:' . $c->{DBI}, $c->{user},$c->{password}, { RaiseError => 1, AutoCommit => 0 }) || die $DBI::errstr;

my $sth = $dbh->prepare($c->{sql});

my $rows = $sth->execute();

warn "$config: $rows locs\n";

my $fh;
my $sitemap_nr = 0;
my $num_urls = 0;

open(my $index, '>', "out/$config.xml") || die "out/$config.xml: $!";
print $index qq|<?xml version="1.0" encoding="UTF-8"?>\n<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|;


while (my $row = $sth->fetchrow_hashref) {

	if ( ! $fh ) {
		$sitemap_nr++;
		my $path = "out/$config.$sitemap_nr.xml";
		open($fh, '>', $path) || die "$path: $!";
		warn "# $path created";

		print $fh qq|<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|;
		$num_urls = 0;

		print $index qq|<sitemap><loc>$c->{url}/$config.$sitemap_nr.xml</loc></sitemap>\n|;
	}

	print $fh qq|<url><loc>$row->{loc}</loc><lastmod>$row->{lastmod}</lastmod></url>\n|;
	$num_urls++;

	# standard limit to 10 mb uncompressed and 50000 urls
	if ( -s $fh > 8 * 1024 * 1024 || $num_urls == 32000 ) {
		warn "# closing $sitemap_nr with ", -s $fh, " bytes and $num_urls urls";
		print $fh qq{</urlset>\n};
		close($fh);
		undef $fh;
	}

}

warn "# closing $sitemap_nr with ", -s $fh, " bytes and $num_urls urls";
print $fh qq{</urlset>\n};
close($fh);

print $index qq|</sitemapindex>|;
print "# closing index with ", -s $index, " bytes\n";
close($index);

if ( $sitemap_nr == 1 ) {
	unlink "out/$config.xml" && rename "out/$config.1.xml", "out/$config.xml" || die $!;
	warn "# using single sitemap xml file out/$config.xml\n";
}


$dbh->rollback;
