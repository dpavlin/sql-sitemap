-- DBI:mysql:dbname=koha
-- user:sitemap

	select
		concat('http://koha.ffzg.hr/cgi-bin/koha/opac-detail.pl?biblionumber=',biblionumber) as loc,
		date(timestamp) as lastmod
	from biblio
	order by timestamp desc
