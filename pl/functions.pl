
use strict;
use warnings;
use List::Util qw/sum/;

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

# posts = {
#   id => {
#     age1 => score1
#     age2 => score2
#     ...
#   }
# }
sub collect_scores($$)
{
  my ($posts, $max_age) = @_;
  my %age_to_score = ();

  for (values %$posts)
  {
    while (my($age,$score) = each %$_)
    {
      push @{ $age_to_score{$age} }, $score;
    }
  }

  return \%age_to_score;
}

sub collect_deltas($$)
{
  my ($posts, $max_age) = @_;
  my %age_to_delta = ();

  for (values %$posts)
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

  return \%age_to_delta;
}

# input is a hash of unaggregated data, indexed by age
sub calc_avgs($$)
{
  my ($data, $max_age) = @_;
  my @avgs = (0) x ($max_age + 1); # defaults

  # First pass aggregate the input (ignore missing points)
  for (0 .. $max_age)
  {
    if (exists $data->{$_})
    {
      my $avg = avg( @{ $data->{$_} });
      $avgs[$_] = $avg;
    }
  }

  # Second pass interpolate missing points but only
  # between 2 neighbouring points
  for (0 .. $max_age)
  {
    if ($avgs[$_] == 0)
    {
      if ($_ == 0)
      {
        $avgs[$_] = 0;
      }
      elsif ($_ == $max_age)
      {
        $avgs[$_] = $avgs[$_ - 1];
      }
      else
      {
        if ($avgs[$_ + 1] > 0) 
        {
          $avgs[$_] = int(($avgs[$_ - 1] + $avgs[$_ + 1]) / 2);
        }
        else
        {
          $avgs[$_] = $avgs[$_ - 1];
        }
      }
    }
  }

  return @avgs;
}

sub calc_deltas($$)
{
  my ($avgs, $max_age) = @_;
  my @deltas = (0);

  for (1 .. $max_age)
  {
    $deltas[$_] = $avgs->[$_] - $avgs->[$_ - 1];
  }
  return @deltas;
}


1;
