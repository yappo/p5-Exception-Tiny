use strict;
use warnings;
use Test::More;
use t::lib::MyException;

eval {
    t::lib::MyException->throwf("message:%s\tcode:%02d", 'error!', 1);
};

my $E = $@;
isa_ok($E, 'Exception::Tiny');
like $E->file, qr/12_throwf\.t$/;
is $E->package, 'main';
is $E->line, 7;
is $E->message, "message:error!\tcode:01";
like "$E", qr/message:error!\tcode:01 at .+12_throwf\.t line 7./;
like $E->dump, qr/'t::lib::MyException'/;

done_testing;
