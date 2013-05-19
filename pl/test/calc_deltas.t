# vim: set filetype=perl
use Test::More tests => 2;

require_ok('../functions.pl');

{
  my @avgs = (100,200,300,400,450);
  my @deltas = calc_deltas(\@avgs, 4);
  
  is_deeply(\@deltas, [0,100,100,100,50]);
}
