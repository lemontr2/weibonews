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
  print STDERR "----request----\n", $res->request()->as_string, "\n";
  print STDERR "----response----\n", $res->as_string, "\n";
  warn "Failed to fetch " . $res->request()->uri . ": " . $res->status_line;
}

sub scrape($)
{
  my ($access_token) = @_;
  my $ua = LWP::UserAgent->new();
  
  my $strp = DateTime::Format::Strptime->new(
    pattern => '%a %b %d %T %z %Y',
    on_error => 'croak',
  );
  my $now = time();
  
  my $uid = 1618051664; # breakingnews
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
}

sub main
{
  my ($access_token) = @_;
  if ($access_token)
  {
    scrape($access_token);
  }
  else
  {
    print "Usage: $0 access_token\n";
    exit 0;
  }
}
main(@ARGV);
