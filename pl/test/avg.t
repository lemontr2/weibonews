
# vim: set filetype=perl
use Test::More tests => 3;

require_ok('../functions.pl');

is(avg(()), 0, 'empty list');
is(avg(1,2,5,4), 3, 'avg(1,2,5,4) == 3');
