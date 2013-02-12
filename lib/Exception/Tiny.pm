package Exception::Tiny;
use strict;
use warnings;
use 5.008005;
our $VERSION = '0.0.1';

use Data::Dumper ();
use Scalar::Util ();

use overload
    bool     => sub { 1 },
    q{""}    => 'as_string',
    fallback => 1;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/ message file line package /]
);


sub throw {
    my $class = shift;

    my %args;
    if (@_ == 1) {
        $args{message} = shift;
    } else {
        %args = @_;
    }

    ($args{package}, $args{file}, $args{line}) = caller(0);

    die $class->new(%args);
}

sub rethrow {
    my $self = shift;
    die $self;
}

sub as_string {
    my $self = shift;
    sprintf '%s at package:%s file:%s line:%s', $self->message, $self->package, $self->file, $self->line;
}

sub dump {
    local $Data::Dumper::Terse = 1;
    Data::Dumper::Dumper(shift);
}

sub caught {
    my($class, $e) = @_;
    return if ref $class;
    return unless Scalar::Util::blessed($e) && $e->isa($class);
    $e;
}

1;
__END__

=encoding utf8

=head1 NAME

Exception::Tiny - too tiny exception interface

=head1 SYNOPSIS

simple example:

  package MyException;
  use parent 'Exception::Tiny';
  
  package main;
  
  # try
  eval {
      MyException->throw( 'oops!' ); # same MyException->throw( message => 'oops!' );
  };
  
  # catch
  if (my $e = $@) {
      if (MyException->caught($e)) {
          say $e->message; # show 'oops!'
          say $e->package; # show 'main'
          say $e->file; # show 'foo.pl'
          say $e->line; # show '8'
          say $e->dump; # dump self
          say $e; # show 'oops! at package:main file:foo.pl line:8'
          $e->rethrow; # rethrow MyException exception.
      }
  }

can you accessor for exception class:

  package MyExceptionBase;
  use parent 'Exception::Tiny';
  use Class::Accessor::Lite (
      ro => [qw/ status_code /],
  );
  
  package MyException::Validator;
  use parent -norequire, 'MyExceptionBase';
  use Class::Accessor::Lite (
      ro => [qw/ dfv /],
  );
  
  package main;
  
  # try
  eval {
      MyException::Validator->throw(
          message     => 'oops',
          status_code => '500',
          dfv         => {
              missing => 'name field is missing.',
          },
      );
  };
  
  # catch
  if (my $e = $@) {
      if (MyException->caught($e)) {
          say $e->message; # show 'oops';
          say $e->status_code; # show '500';
          say $e->dfv->{missing}; # show 'name field is missing.'
          say $e; # show 'oops at package:main file:bar.pl line:17'
      }
  }

can you catche nested class:

  package BaseException;
  use parent 'Exception::Tiny';
  
  package MyException::Validator;
  use parent -norequire, 'BaseException';
  
  package main;
  
  eval { MyException::Validator->throw }
  
  my $e = $@;
  say 'BaseException' if BaseException->caught($e); # show 'BaseException'

=head1 DESCRIPTION

Exception::Tiny is too simple exception interface.
This is the implementation of the minimum required in order to implement exception handling.
So anyone can understand the implementation It.

=head1 CLASS METHODS

=head2 throw( ... )

throw the exception.

=head2 caught($e)

It returns an exception object if the argument is of the current class, or a subclass of that class. it simply returns $e.

=head1 INSTANCE METHODS

=head2 rethrow

re-throw the exception object.

=head2 message

It return the exception message.

=head2 package

It return the package name that exception has occurred.

=head2 file

It return the file name that exception has occurred.

=head2 line

It return the line number in file that exception has occurred.

=head2 as_string

It returned in the format the exception contents of a simple string.
You can Implementation overridden.

=head2 dump

It to dump the contents of the instance.
You can Implementation overridden.

=head1 HACKING IDEA

If you want L<Exception::Class::Base> style object, you can write like code of the under.

  package HackException;
  use parent 'Exception::Tiny';
  use Class::Accessor::Lite (
      ro => [qw/ time pid uid euid gid egid /],
  );
  
  sub new {
      my($class, %args) = @_;
      %args = (
          %args,
          time => CORE::time,
          pid  => $$,
          uid  => $<,
          euid => $>,
          gid  => $(,
          egid => $),
      );
      $class->SUPER::new(%args);
  }
  
  eval {
      HackException->throw;
  };
  my $e = $@;
  say $e->time;
  say $e->pid;
  say $e->uid;
  say $e->euid;
  say $e->gid;
  say $e->egid;

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {@} shibuya {dot} plE<gt>

=head1 SEE ALSO

L<Class::Accessor::Lite>

=head1 LICENSE

Copyright (C) Kazuhiro Osawa

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
