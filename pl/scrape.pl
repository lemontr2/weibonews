#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use URI::URL;
use JSON;
use DateTime::Format::Strptime;
use Getopt::Long;
use constant { RETRY => 5 };

binmode(STDOUT, ":utf8");

sub err_msg($)
{
  my ($res) = @_;
  print STDERR "----request----\n", $res->request()->as_string, "\n";
  print STDERR "----response----\n", $res->as_string, "\n";
  warn "Failed to fetch " . $res->request()->uri . ": " . $res->status_line;
}

sub scrape($$$)
{
  my ($token,$uid,$count) = @_;
  my $ua = LWP::UserAgent->new();
  
  my $strp = DateTime::Format::Strptime->new(
    pattern => '%a %b %d %T %z %Y',
    on_error => 'croak',
  );
  my $now = time();
  
  my $url = url('https://api.weibo.com/2/statuses/user_timeline.json');
  
  $url->query_form(
    access_token => $token,
    uid       => $uid,
    count     => $count,
    page      => 1,
    trim_user => 1,
    feature   => 1,
  );
  
  LOOP: for (1 .. RETRY)
  {
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
      last LOOP;
    }
    else
    {
      err_msg($response);
      sleep 5;
    }
  }
}

sub main
{
  #my $uid = 1618051664; # breakingnews
  #my $count = 50;

  my ($token, $uid, $count) = ('','',0);
  GetOptions(
        "token=s" => \$token,
        "uid=s"   => \$uid,
        "count=i" => \$count);

  if ($token && $uid && $count)
  {
    scrape($token, $uid, $count);
  }
  else
  {
    print "$0: Argument required.\n";
    exit 1;
  }
                
}
main(@ARGV);
