#!/usr/local/bin/perl -w

use English;
use strict;
use lib '.';
use Tie::Watch;

# Complete documentation on Watch is a pod in the module file.  Watch works on
# plain scalars, arrays, or hashes.  Do *NOT* Watch Tk widgets!  But Watch does
# work OK with Tk otherwise.
#
# This program demonstrates scalar, array and hash tracing.  Supply a single
# parameter, "all", to also see a short Tk demonstration.

my $demos = 'sah';
$demos = $ARGV[0] if $ARGV[0];
$demos = 'saht' if $demos eq 'all';

my $foo;			# Watch variables
my @foo;
my %foo;

my %vinfo;			# variable Watch information
my $date;			# a changing time

my $w_scalar;			# Watch objects
my $w_array;
my $w_hash;

my $fetch_scalar = sub {
    my($self) = @ARG;
    $self->Fetch;
};

my $store_scalar = sub {
    my($self, $new_val) = @ARG;
    $self->Store(uc $new_val);
};

my $fetch = sub {
    my($self, $key) = @ARG;
    my $val = $self->Fetch($key);
    print "In fetch callback, key=$key, val=", $self->Say($val);
    my $args = $self->Args(-fetch);
    print ", args=('", join("', '",  @$args), "')" if $args;
    print ".\n";
    $val;
};

my $store = sub {
    my($self, $key, $new_val) = @ARG;
    my $val = $self->Fetch($key);
    $new_val = uc $new_val;
    $self->Store($key, $new_val);
    print "In store callback, key=$key, val=", $self->Say($val), 
      ", new_val=", $self->Say($new_val);
    my $args = $self->Args(-store);
    print ", args=('", join("', '",  @$args), "')" if $args;
    print ".\n";
    $new_val;
};

if ($demos =~ /s/) {
    print "\n********** Test Watch Scalar **********\n";
    chomp($date = `date`); $date = substr $date, 11, 8;
    $foo='frog';
    $w_scalar = Tie::Watch->new(
        -variable => \$foo,
	-fetch    => $fetch_scalar,
	-store    => $store_scalar,
	-destroy  => sub {print "Final value of \$foo=$foo.\n"},
	-debug    => 1,
    );
    $foo = "hello scalar";
    print "Final value: $foo\n";
    %vinfo = $w_scalar->Info;
    print "Watch info :\n  ", join("\n  ", @{$vinfo{-legible}}), "\n";
    $w_scalar->Delete if $demos !~ /t/;
    sleep 1;
}

if ($demos =~ /a/) {
    print "\n********** Test Watch Array **********\n";
    chomp($date = `date`); $date = substr $date, 11, 8;
    $w_array = Tie::Watch->new(
        -variable => \@foo,
	-fetch    => $fetch,
	-store    => [$store, 'array write', $date],
    );
    @foo = ("hello", 'array');
    my($a, $b) = ($foo[0], $foo[1]);
    print "Final value: $a $b\n";
    %vinfo = $w_array->Info;
    print "Watch info :\n  ", join("\n  ", @{$vinfo{-legible}}), "\n";
    sleep 1;
}

if ($demos =~ /h/) {
    print "\n********** Test Watch Hash **********\n";
    chomp($date = `date`); $date = substr $date, 11, 8;
    $w_hash = Tie::Watch->new(
        -variable => \%foo,
	-fetch    => [$fetch, 'hash read', $date],
	-store    => $store,			  
    );
    %foo = ('k1' => "hello", 'k2' => 'hash ');
    my($a, $b) = ($foo{k1}, $foo{k2});
    print "Final value: $a $b\n";
    %vinfo = $w_hash->Info;
    print "Watch info :\n  ", join("\n  ", @{$vinfo{-legible}}), "\n";
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
}
__END__

if ($demos =~ /t/) {
    die "Cannot run Tk demo without running scalar demo too." if not 
      defined $w_scalar;
    use Tk;
    my $MW = MainWindow->new;
    my $e = $MW->Entry->pack;
    $e->insert(0, $foo);
    $e->bind('<Return>' => sub {$foo = $e->get});
    $e->focus;
    my $u = $MW->Button(-text => 'UnWatch $foo', -command => sub {
	$w_scalar->Delete;
    })->pack;
    my $l = $MW->Button(-text => 'Quit', -command => \&exit)->pack;
    MainLoop;
}
