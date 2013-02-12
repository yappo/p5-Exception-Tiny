use strict;
use warnings;
use Test::More;
use t::lib::MyExceptions;

my $ok = 0;

$ok++  unless MyException1->caught;
$ok++  unless MyException2->caught;
$ok++  unless MyException3->caught;
$ok++  unless MyException4->caught;

eval {
    MyException1->throw;
};
$ok++  if     MyException1->caught;
$ok++  unless MyException2->caught;
$ok++  unless MyException3->caught;
$ok++  unless MyException4->caught;

eval {
    MyException2->throw;
};
$ok++  if     MyException1->caught;
$ok++  if     MyException2->caught;
$ok++  unless MyException3->caught;
$ok++  unless MyException4->caught;

eval {
    MyException3->throw;
};
$ok++  if     MyException1->caught;
$ok++  unless MyException2->caught;
$ok++  if     MyException3->caught;
$ok++  unless MyException4->caught;

eval {
    MyException4->throw;
};
$ok++  if     MyException1->caught;
$ok++  unless MyException2->caught;
$ok++  if     MyException3->caught;
$ok++  if     MyException4->caught;

is $ok, 20;

done_testing;
