#!/usr/bin/perl

use strict;
use warnings;
use constant { MAX_AGE => 80 };

require 'functions.pl';

# Values are hashes keyed by "age"
my %posts = ();

sub process($)
{
  my ($line) = @_;
  # 3578790913366671,42,60,2013-05-17T03:48:27,1368733707,0
  if ($line && $line =~ /(\d+),(\d+),(\d+),(\d\d\d\d-\d\d-\d\d.\d\d:\d\d:\d\d),(\d+),(\d+)/)
  {
    my ($id,$reposts_count,$comments_count,$datetime,$epoch,$age) = ($1,$2,$3,$4,$5,$6);
    $posts{$id}->{$age} = calc_score($reposts_count, $comments_count);
  }
  else
  {
    # skipped
    #warn "Invalid input: $line";
  }
}

sub calc_score($$)
{
  my ($reposts_count,$comments_count) = @_;
  return $reposts_count + $comments_count * 2;
}

sub _p($$)
{
  my ($func, $msg) = @_;
  my $data = $func->(\%posts, MAX_AGE);

  print $msg, ' = ', join(',', calc_avgs($data, MAX_AGE)), "\n";
}

sub print_summary()
{
  _p(\&collect_scores, 'AVG SCORE');
  _p(\&collect_deltas, 'AVG DELTA');
}

sub main(@)
{
  my ($dirname) = @_;
  if ($dirname && -d $dirname)
  {
    local @ARGV = glob "$dirname/*";
    while (<>)
    {
      chomp;
      process($_);
    }
    print_summary();
  }
  else
  {
    print "Usage: $0 dirname\n";
    exit 0;
  }
}


main(@ARGV);
