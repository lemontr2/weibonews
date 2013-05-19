
# vim: set filetype=perl
use Test::More tests => 4;

require_ok('../functions.pl');


# Test 1
{
  my $data = {
    0 => [100],
    1 => [200],
    3 => [400], # '2' will be interpolated
        # and '4' will be the same as '3'
  };

  my @avgs = calc_avgs($data, 4);
  is_deeply(\@avgs, [100,200,300,400,400]);
}

# Test 2
{
  my $data = {
    1 => [100],  # missing '0'
  };
  my @avgs = calc_avgs($data, 1);
  is_deeply(\@avgs, [0,100]);
}

# Test 3
{
  my $data = {
    0 => [100],
    1 => [200,100],
    2 => [200],
    3 => [300],
  };
  my @avgs = calc_avgs($data, 4);
  is_deeply(\@avgs, [100,150,200,300,300]);
}
