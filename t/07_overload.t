use strict;
use warnings;
use Test::More;
use t::lib::MyExceptions;

my $ok = 0;

eval {
    MyException1->throw;
};

$ok++  if MyException1->caught;
$ok++  if MyException1->caught->package eq 'main';

is $ok, 2;

done_testing;
