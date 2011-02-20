#!/usr/bin/perl
use warnings;
use strict;

require LWP::UserAgent;

my $ua = LWP::UserAgent->new;
#$ua->timeout(10);
#$ua->env_proxy;
$ua->agent("Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)");

my $url = 'http://koha.ffzg.hr/sitemap/sitemap.xml';

my $response = $ua->get( $url );

if ($response->is_success) {
    print $response->content;  # or whatever
}
else {
    die "$url ",$response->status_line;
}
