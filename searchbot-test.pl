#!/usr/bin/perl
use warnings;
use strict;

require LWP::UserAgent;

my $ua = LWP::UserAgent->new;
#$ua->timeout(10);
#$ua->env_proxy;

my $url = 'http://koha.ffzg.hr/sitemap/sitemap.xml';

while(<DATA>) {
	chomp;
	warn "# $_\n";

	$ua->agent( $_ );

	my $response = $ua->get( $url );

	if ($response->is_success) {
	    print "$url\n", $response->content;  # or whatever
	}
	else {
	    die "$url ",$response->status_line;
	}
}

# generated with
# grep bot /var/log/apache2/*.log.1 | cut -d\" -f6 | sort -u

__DATA__
DoCoMo/2.0 N905i(c100;TB;W24H16) (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)
DoCoMo/2.0 P901i(c100;TB;W24H11) (compatible; ichiro/mobile goo; +http://help.goo.ne.jp/door/crawler.html)
Googlebot/2.1 (+http://www.googlebawt.com/bot.html)
Googlebot/2.1 (+http://www.googlebot.com/bot.html)
Googlebot-Image/1.0
ia_archiver (+http://www.alexa.com/site/help/webmasters; crawler@alexa.com)
Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)
msnbot/2.0b (+http://search.msn.com/msnbot.htm)._
SAMSUNG-SGH-E250/1.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 UP.Browser/6.2.3.3.c.1.101 (GUI) MMP/2.0 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)
