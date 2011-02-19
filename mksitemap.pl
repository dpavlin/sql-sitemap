#!/usr/bin/perl

use warnings;
use strict;

use DBI;
use Data::Dump qw(dump);

my $debug = 0;

our $user     = 'kohaadmin';
our $passwd   = '';

require 'config.pl';

our $dsn      = 'DBI:mysql:dbname=koha';

my $dbh = DBI->connect($dsn, $user,$passwd, { RaiseError => 1, AutoCommit => 0 }) || die $DBI::errstr;

my $sth = $dbh->prepare(q{
	select
		biblionumber,
		date(timestamp) as lastmod
	from biblio
	order by timestamp desc
});

my $rows = $sth->execute();

warn "got $rows biblio items\n";

my $fh;
my $sitemap_nr = 0;
my $num_urls = 0;

while (my $row = $sth->fetchrow_hashref) {

	if ( ! $fh ) {
		$sitemap_nr++;
		my $path = "out/sitemap$sitemap_nr.xml";
		open($fh, '>', $path) || die "$path: $!";
		warn "# $path created";

		print $fh qq|<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|;
		$num_urls = 0;
	}

	print $fh qq|<url><loc>http://koha.ffzg.hr/cgi-bin/koha/opac-detail.pl?biblionumber=$row->{biblionumber}</loc><lastmod>$row->{lastmod}</lastmod></url>\n|;
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

$dbh->rollback;
