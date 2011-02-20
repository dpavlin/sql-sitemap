-- Movable Type blog example

-- DBI:Pg:dbname=blogs

-- url:http://blog.rot13.org/sitemap/blog.xml

select
	'http://blog.rot13.org/'
	|| substr(date(entry_authored_on)::text,1,4) || '/'
	|| substr(date(entry_authored_on)::text,6,2) || '/'
	|| entry_basename || '.html'
	as loc,
	date(entry_modified_on) as lastmod
from mt_entry
where 
	entry_blog_id = 1	-- correct blog
	and entry_status = 2	-- published
order by entry_modified_on desc

