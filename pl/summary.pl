#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw/sum/;

# Values are hashes keyed by "age"
my %posts = ();

sub calc_score($$)
{
  my ($reposts_count,$comments_count) = @_;
  return $reposts_count + $comments_count * 2;
}

sub process($)
{
  my ($line) = @_;
  my ($id,$reposts_count,$comments_count,$datetime,$epoch,$age) = split /,/, $line;

  $posts{$id}->{$age} = calc_score($reposts_count, $comments_count);
}

sub avg(@)
{
  if (@_)
  {
    my $n = @_;
    my $sum = sum(@_);
    return int($sum / $n);
  }
  else
  {
    return 0;
  }
}

sub calc_avgs($)
{
  my ($href) = @_;
  my @keys = sort {$a <=> $b} (keys %$href);
  my @avgs = map { avg(@{ $href->{$_} }) } @keys;

  return \@avgs;
}

sub print_score()
{
  my %age_to_score = ();
  for (values %posts)
  {
    while (my($age,$score) = each %$_)
    {
      push @{ $age_to_score{$age} }, $score;
    }
  }

  my @avgs = @{ calc_avgs(\%age_to_score) };
  print 'AVG SCORE = ', join(',', @avgs), "\n";
}

sub print_delta()
{
  my %age_to_delta = (0, [0]);
  for (values %posts)
  {
    for my $age (keys %$_)
    {
      if ($age > 0 && exists $_->{($age - 1)} )
      {
        my $prev = $_->{($age - 1)};
        my $curr = $_->{$age};
        my $delta = $curr - $prev;
        if ($delta < 0)
        {
          $delta = 0;
        }
        push @{ $age_to_delta{$age} }, $delta;
      }
    }
  }
  my @avgs = @{ calc_avgs(\%age_to_delta) };
  print 'AVG DELTA = ', join(',', @avgs), "\n";
}

sub print_summary()
{
  print_score();
  print_delta();
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
