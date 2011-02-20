-- DBI:mysql:dbname=koha
-- user:sitemap

-- you need to grant priviledges to this user using something like:
-- mysql> grant select on koha.biblio to 'sitemap'@'localhost';

	select
		concat('http://koha.ffzg.hr/cgi-bin/koha/opac-detail.pl?biblionumber=',biblionumber) as loc,
		date(timestamp) as lastmod
	from biblio
	order by timestamp desc
