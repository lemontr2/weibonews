#!/usr/bin/perl

use strict;
use warnings;

my %age_to_score = ();
#my %date_to_id = ();

sub calc_score($$)
{
  my ($reposts_count,$comments_count) = @_;
  return $reposts_count + $comments_count * 2;
}

sub process($)
{
  my ($line) = @_;
  my ($id,$reposts_count,$comments_count,$datetime,$epoch,$age) = split /,/, $line;

  # Calculate average score
  push @{ $age_to_score{$age} }, calc_score($reposts_count, $comments_count);

#  # Calculate post count per day
#  my $date = substr $datetime, 0, 10;
#  push @{ $date_to_id{$date} }, $id;
}

sub sum(@)
{
  my $sum = 0;
  $sum += $_ for @_;
  return $sum;
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

#sub uniq_count(@)
#{
#  my %uniq = ();
#  $uniq{$_} = 1 for @_;
#  return (scalar keys %uniq);
#}

sub print_summary()
{
  my @keys = sort {$a <=> $b} (keys %age_to_score);
  my @avgs = map { avg(@{ $age_to_score{$_} }) } @keys;
  print join(',', @avgs), "\n";

#  print "POSTS PER DAY: ", avg(map { uniq_count(@{ $_ }) } values %date_to_id), "\n";
}

sub main(@)
{
  my ($dirname) = @_;
  if (-d $dirname)
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
