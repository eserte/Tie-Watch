#!/usr/local/bin/perl -w

use English;
use strict;
use lib '.';
use Tie::Watch;

# Complete documentation on Watch is a pod in the module file.  Watch works on
# plain scalars, arrays, or hashes.  Do *NOT* Watch Tk widgets!  But Watch does
# work OK with Tk otherwise.  First, sample Watch runs are demonstrated, then, 
# if you remove the __END__ statement, a Tk window appears where you can type
# values for a Watched scalar, $foo.

my $foo;			# Watch variables
my @foo;
my %foo;

my %vinfo;			# variable Watch information
my $date;			# a changing time

my $w_scalar;			# Watch objects
my $w_array;
my $w_hash;

my $callback = sub {

    # Callback to uppercase write values.

    my($watch, $op, $val, $new_val, $key, @args) = @ARG;
    print "'$op' on $watch:\n",
        "  val    =", (defined $val     ? "'$val'" :     'undefined'), "\n",
        "  new_val=", (defined $new_val ? "'$new_val'" : 'undefined'), "\n",
        "  key    =", (defined $key     ? "'$key'" :     'undefined'), "\n",
        "  args   =@args\n";
    return ($op =~ /r/ ? $val : uc $new_val);
};

# Watch Scalar ****************************************************************

print "\n********** Test Watch Scalar:\n";
chomp($date = `date`);
$foo='frog';
$w_scalar = Tie::Watch->new(
    -variable  => \$foo,
    -operation => 'rw',
    -callback  => $callback,
    -args      => [$date],
);
$foo = "hello scalar";
print $foo, "\n";
%vinfo = $w_scalar->Info;
print "vinfo:\n", join("\n", @{$vinfo{legible}}), "\n";
#$w_scalar->Delete;
sleep 1;

# Watch Array *****************************************************************

print "\n********** Test Watch Array:\n";
chomp($date = `date`);
$w_array = Tie::Watch->new(
    -variable  => \@foo,
    -operation => 'wr',
    -callback  => $callback,
    -args      => [$date],
);
@foo = ("hello", 'array');
my($a, $b) = ($foo[0], $foo[1]);
print $a, ' ', $b, "\n";
%vinfo = $w_array->Info;
print "vinfo:\n", join("\n", @{$vinfo{legible}}), "\n";
sleep 1;

# Watch Hash ******************************************************************

print "\n********** Test Watch Hash:\n";
chomp($date = `date`);
$w_hash = Tie::Watch->new(
    -variable  => \%foo,
    -operation => 'wr',
    -callback  => $callback,
    -args      => [$date],
);
%foo = ('k1' => "hello", 'k2' => 'hash ');
my($a, $b) = ($foo{k1}, $foo{k2});
print $a, ' ', $b, "\n";
%vinfo = $w_hash->Info;
print "vinfo:\n", join("\n", @{$vinfo{legible}}), "\n";
foreach (keys %foo) {
    print "key=$ARG, value=$foo{$ARG}.\n";
}
if (exists $foo{k2}) {
    print "k2 does exist\n";
} else {
    print "k2 does not exists\n";
}
delete $foo{k2};
if (exists $foo{k2}) {
    print "k2 does exist\n";
} else {
    print "k2 does not exist\n";
}
print "keys=", join(', ', keys %foo), ".\n";
print "\n";
__END__

use Tk;
my $MW = MainWindow->new;
my $e = $MW->Entry->pack;
$e->bind('<Return>' => sub {$foo = $e->get});
$e->focus;
my $d = $MW->Button(-text => 'Debug', -command => sub {$Tie::Watch::DEBUG = 1});
$d->pack;
my $u = $MW->Button(-text => 'UnWatch $foo', -command => sub {
    $w_scalar->Delete;
})->pack;
my $l = $MW->Button(-text => 'Quit', -command => \&exit)->pack;
MainLoop;
