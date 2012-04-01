#!/usr/bin/perl -w

use Test::More 'no_plan';

use_ok 'Tie::Watch';

{
    package Bar;
    
    sub method { 99 }
}

my %watcher;
my $obj = bless { foo => 23 }, 'Bar';
isa_ok $obj, 'Bar';

my $watch = Tie::Watch->new(
    -variable   => $obj,
    -store      => sub {
        my($self, $key, $val) = @_;
        $watcher{$key} = $val;
        $self->Store($key, $val);
    },
);

is_deeply $obj, { foo => 23 };

isa_ok $obj, 'Bar';
$obj->{foo} = 42;
is $obj->{foo}, 42;
is $watcher{foo}, 42;

is $obj->method, 99;
