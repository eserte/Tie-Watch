#!/usr/local/bin/bin/perl -w

use strict;
use Tie::Watch;
use vars qw/$watch/;

use Test::More tests => 36;

my $aa = 1;
$watch = new Tie::Watch(-variable => \$aa);
$aa = 3;
is $aa, 3, 'scalar STORE and FETCH';
$watch->Unwatch;
is $aa, 3, '-shadow';

my %aa = (1,11,2,22);
$watch = new Tie::Watch(-variable => \%aa);
$aa{3} = 33;
is $aa{3}, 33, 'hash STORE and FETCH';
$watch->Unwatch;
is $aa{3}, 33, '-shadow';
$watch = new Tie::Watch(-variable => \%aa);
ok exists $aa{3}, 'hash EXISTS';
my $d = delete $aa{3};
ok !exists $aa{3}, 'hash DELETE';
is $d, 33;
$aa{3} = 333; $aa{4} = 444; $aa{5} = 555;

my($key, $val, $last_val);
while ( ($key, $val) = each %aa) {
    last if $key == 3;
}
is $val, 333, 'HASH FIRSTKEY';
while ( ($key, $val) = each %aa) {
    $last_val = $val;
}
is $last_val, 555, 'hash NEXTKEY';
($key, $val) = each %aa;
# dumb test
is $val, $val;
is keys %aa, 5;
%aa=();
is keys %aa, 0, 'hash CLEAR';
is_deeply \%aa, {};

my @aa = (1,2);
$watch = new Tie::Watch(-variable => \@aa);
$aa[2] = 3;			# test array STORE
is @aa,    3, 'array FETCHSIZE';
is $#aa,   2, 'array FETCHSIZE';
is $aa[2], 3, 'array FETCH';
$watch->Unwatch;
is $aa[2], 3, '-shadow';
$watch = new Tie::Watch(-variable => \@aa);
push @aa, ('frog', 'cow');	# test array PUSH
$#aa = 5;			# extend, fill with 1 undef
my $pop = pop @aa;		# get undef
ok !defined($pop);
$pop = pop @aa;			# should be 'cow'
is $pop, 'cow', 'array POP';
unshift @aa, (-2, -1, 0);
is @aa, 7, 'array UNSHIFT';
my $shift = shift @aa;
is $shift, -2, 'array SHIFT';
my @splice = splice @aa, 1, 1, (-0.5, 0, +0.5);
is $splice[0], 0, 'array SPLICE';
my @should_be = (-1, -0.5, 0, 0.5, 1, 2, 3, 'frog');

my $ok = 1;
for my $i (0..$#aa) {
    next if $aa[$i] eq $should_be[$i];
    $ok = 0;
}
ok $ok;
my $delete = delete $aa[$#aa];
is $delete, 'frog', 'array delete()';
$aa[ $#aa + 1 ] = 'frog';
$delete = delete $aa[5];
is $delete, 2, 'array delete';
$aa[5] = $delete;
ok exists $aa[$#aa], 'array exists';
@splice = splice @aa, 2,2;
is $splice[0], 0;
is $splice[1], 0.5;
@splice = splice @aa, 4,1,(qw/a b c/);
is $aa[3], 2;
is join('',@aa[4..$#aa]), 'abcfrog';
is $splice[0], 3;
@splice = splice @aa, 5;
is join('',@splice), 'bcfrog';
%aa = ();
is keys %aa, 0, 'array CLEAR';
$watch->Unwatch;
ok !defined($watch);

$aa = \[1];
$watch = new Tie::Watch(-variable => \$aa);
$$aa->[0] = 3;			# test scalar STORE
is $$aa->[0], 3, 'scalar FETCH/STORE';
$watch->Unwatch;
is $$aa->[0], 3, 'shadow';
