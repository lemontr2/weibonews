#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use URI::URL;
use JSON;
use DateTime::Format::Strptime;

binmode(STDOUT, ":utf8");

sub err_msg($)
{
  my ($res) = @_;
  print "----request----\n", $res->request()->as_string, "\n";
  print "----response----\n", $res->as_string, "\n";
  warn "Failed to fetch " . $res->request()->uri . ": " . $res->status_line;
}

my $ua = LWP::UserAgent->new();

my $strp = DateTime::Format::Strptime->new(
  pattern => '%a %b %d %T %z %Y',
  on_error => 'croak',
);
my $now = time();

my $uid = 1618051664; # breakingnews
my $access_token = '2.00OfsMMCIXGqBB50b811f921jG1VJB';
my $count = 100;

my $url = url('https://api.weibo.com/2/statuses/user_timeline.json');

$url->query_form(
  access_token    => $access_token,
  uid       => $uid,
  count     => $count,
  page      => 1,
  trim_user => 1,
  feature   => 1,
);

my $response = $ua->get($url);
if ($response->is_success())
{
  my $json = $response->decoded_content();
  my $posts = decode_json( $json );
  for (@{ $posts->{statuses} })
  {
    # Parse datetime
    my $created_at = $_->{created_at};
    my $datetime = $strp->parse_datetime($created_at);
    my $epoch = $datetime->epoch;
    my $age = int( ( $now - $epoch ) / 3600 );

    print join(',', @{$_}{qw/id reposts_count comments_count/}, $datetime, $epoch, $age), "\n";
  }
}
else
{
  err_msg($response);
}
