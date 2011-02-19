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

while (my $row = $sth->fetchrow_hashref) {

	if ( ! $fh ) {
		$sitemap_nr++;
		my $path = "sitemap$sitemap_nr.xml";
		open($fh, '>', $path) || die "$path: $!";
		warn "# $path created";

		print $fh qq|<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|;
	}

	print $fh qq|<url><loc>http://koha.ffzg.hr/cgi-bin/koha/opac-detail.pl?biblionumber=$row->{biblionumber}</loc></url>\n|;

	if ( -s $fh > 8 * 1024 * 1024 ) {
		warn "# closing $sitemap_nr with ", -s $fh, " bytes";
		print $fh qq{</urlset>\n};
		close($fh);
		undef $fh;
	}

}

print $fh qq{</urlset>\n};
close($fh);
warn "# last $sitemap_nr with ", -s $fh, " bytes";

