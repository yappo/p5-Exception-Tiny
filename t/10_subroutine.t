use strict;
use warnings;
use Test::More;
use t::lib::MyExceptions;

sub one {
    MyException1->throw('oops');
}

eval { one() };
is $@->subroutine, 'main::one';
like $@, qr/oops from main#one at .+10_subroutine\.t line 7./;

eval {
    MyException1->throw('oops');
};
is $@->subroutine, '(eval)';
like $@, qr/oops from main#\(eval\) at .+10_subroutine\.t line 15./;

eval {
    sub {
        MyException1->throw('oops');
    }->();
};
is $@->subroutine, 'main::__ANON__';
like $@, qr/oops from main#__ANON__ at .+10_subroutine\.t line 22./;

{
    local $SIG{__DIE__} = sub {
        my $e = shift;
        is $e->subroutine, undef;
        like $e, qr/oops from main# at .+10_subroutine\.t line 36./;
        done_testing;
        exit;
    };
    MyException1->throw('oops');
};

