package Tie::Watch;

use Carp;
use English;

$DEBUG = 0;

=head1 NAME

 Tie::Watch() - place watchpoints on Perl variables.

=head1 SYNOPSIS

 use Tie::Watch;

 $watch = Tie::Watch->new(
     -variable  => \$frog,
     -operation => 'rw',
     -callback  => \&callback,
     -args      => \@args,
 );
 %vinfo = $watch->Info;
 $watch->Delete;

=head1 DESCRIPTION

 This class module binds a subroutine of your devising to a Perl variable; the
 callback is invoked when the variable is read, written, or both.  The callback
 code can pass the value of the variable through unchanged, or modify it on
 the fly.  You cannot have more than one callback per Perl variable, so it must
 be coded to handle read and write operations if 'rw' mode is selected.  It is
 passed at least three arguments:

 my $callback = sub {

     # Callback to uppercase write values.

     my($op, $val, $new_val, @args) = @ARG;
     print "op=$op, val=", ($val ? "'$val'" : 'undefined'),
         ", new_val=", ($new_val ? "'$new_val'" : 'undefined'),
         ", args=@args!\n";
     return ($op =~ /r/ ? $val : uc $new_val);
 };

 $op is either 'r' or 'w', $val is the variable's current value, $new_val is
 the variable's new value if the operation is a write (else it's the same as
 $val), and @args is a list of optional arguments you (may have) provided to 
 the Tie::Watch->new() method. The return value from the callback becomes the
 variable's new value.  

 This example simply uppercases $new_val on a write.  To implement a read-only
 variable simply return $val on a write.  Note that one callback works for
 scalar, array or hash variables.

=head1 METHODS

=head2 $watch = Tie::Watch->new(-options => values);

  -variable  = a *reference* to a scalar, array or hash variable.  If you
               specify a string, it's the name of a scalar variable.

  -operation = 'r' to watch reads, 'w' to watch writes, or 'rw' to watch
               both reads and writes.

  -callback  = a code reference pointing to the subroutine to handle the
               watch activity.

  -args      = an optional reference to a list of arguments to supply the
               callback code.

=head2 %vinfo = $watch->Info;

 Returns a hash detailing the internals of the Watch object, with these keys:

 %vinfo = {
     watch     =>  SCALAR(0x200737f8)
     operation =>  'rw'
     callback  =>  CODE(0x200b2778)
     arguments =>  \@args
     value     =>  'HELLO SCALAR'
     legible   =>  above data formatted as a list of string, for printing
 }

 For array and hash Watch objects, the 'value' key is replaced with a 'ptr'
 key which is a reference to the array or hash.

=head2 $watch->Delete;

 Stop watching the variable.  To delete the Watch object use undef($watch).

=head1 AUTHORS

 Stephen O. Lidie <lusol@Lehigh.EDU>
 Hans Mulder <hansm@wsinti07.win.tue.nl>

=head1 HISTORY

 lusol@Lehigh.EDU, LUCC, 96/05/30
  . Original version 1.0 release, based on the Trace module from Hans Mulder.

=head1 COPYRIGHT

 Copyright (C) 1996 - 1996 Stephen O. Lidie. All rights reserved.

 This program is free software; you can redistribute it and/or modify it under
 the same terms as Perl itself.

=cut

sub new {

    # Watch constructor.  The *real* constructor is Tie::Watch->BaseWatch(),
    # invoked by methods in other Watch packages, depending  upon the
    # variable's type.

    my($class, %args) = @ARG;

    # Supply defaulted parameter values and then verify them.

    my (%arg_defaults) = (
        -operation => 'rw',
    );
    my(@margs, %ahsh, $watch, $op, $cb, $args, @args);
    @margs = grep ! defined $args{$ARG}, keys %arg_defaults;
    %ahsh = %args;
    @ahsh{@margs} = @arg_defaults{@margs};
    ($watch, $op, $cb, $args) = @ahsh{-variable, -operation, -callback, -args};
    @args = @$args;
    croak "Tie::Watch: -variable is required." if not defined $watch;
    croak "Tie::Watch: -operation must be 'r', 'w' or 'rw'." if $op =~ /[^rw]/;
    croak "Tie::Watch: -callback is required." if not defined $cb;

    # Create and return the actual watchpoint binding.

    $watch = (caller) . "::$watch" unless ($watch =~ /::|'/ or ref $watch);
    my($type, $watch_obj) = (ref $watch, undef);
    if ($type =~ /SCALAR/) {
        $watch_obj = tie $$watch, Tie::Watch::Scalar, $watch, $op, $cb, @args;
    } elsif ($type =~ /ARRAY/) {
        $watch_obj = tie @$watch, Tie::Watch::Array,  $watch, $op, $cb, @args;
    } elsif ($type =~ /HASH/) {
        $watch_obj = tie %$watch, Tie::Watch::Hash,   $watch, $op, $cb, @args;
    } else { # assume symbolic reference
        $watch_obj = tie $$watch, Tie::Watch::Scalar, $watch, $op, $cb, @args;
    }
    return $watch_obj;

} # end new, Watch constructor

sub Delete {

    # Stop watching a variable by untie()-ing it.

    my($self) = @ARG;

    my $watch = $self->{watch};
    $watch = (caller) . "::$watch" unless ($watch =~ /::|'/ or ref $watch);
    my $type = ref $watch;
    if ($type =~ /SCALAR/) {
	untie $$watch;
    } elsif ($type =~ /ARRAY/) {
	untie @$watch;
    } elsif ($type =~ /HASH/) {
	untie %$watch;
    } else { # assume symbolic reference
	untie $$watch;
    }
}

sub Info {

    # Info() method subclassed by other Watch modules.

    my($self) = @ARG;
    my(%vinfo, @results);
    push @results, "watch    : " . $self->{watch};
    push @results, "operation: " . $self->{op};
    push @results, "callback : " . $self->{cb};
    push @results, "arguments: " . join( ' ', @{$self->{args}});
    %vinfo = (
        'watch'     => $self->{watch},
        'operation' => $self->{op},
        'callback'  => $self->{cb},
        'arguments' => $self->{args},
        'legible'   => [@results],
    );
    return %vinfo;
}

# Watch private methods.

sub BaseWatch {

    # Watch base class constructor invoked by other Watch modules.

    my($class, $watch, $op, $cb, @args) = @ARG;
    my $watch_obj = {
        'watch' => $watch,
        'op'    => $op,
	'cb'    => $cb,
	'args'  => [@args],
    }; 
    return bless $watch_obj, $class;
}

sub Say {

    # For debugging.

    my($self, $val) = @ARG;
    defined $val ? "'$val'" : "undefined";
}

###############################################################################

package Tie::Watch::Scalar;

use English;
@ISA = qw(Tie::Watch);

sub TIESCALAR {
    my($class, $watch, $op, $cb, @args) = @ARG;
    print "WatchScalar: $watch created, \@ARG=@ARG!\n" if $Tie::Watch::DEBUG;
    my $watch_obj = Tie::Watch->BaseWatch($watch, $op, $cb, @args);
    $watch_obj->{value} = $$watch;
    return bless $watch_obj, $class;
}

sub Info {
    my($self) = @ARG;
    my %vinfo = $self->SUPER::Info;
    push @{$vinfo{legible}}, "value    : " . $self->{value};
    $vinfo{value} = $self->{value};
    return %vinfo;
}

sub DESTROY {
    my($self) = @ARG;
    print "WatchScalar: $self->{watch} destructor, final value was ",
	        $self->Say($self->{value}), ".\n" if $Tie::Watch::DEBUG;
    undef %$self;
}

sub FETCH {
    my($self) = @ARG;
    my $val = $self->{value};
    my $new_val = $val;
    print "WatchScalar: $self->{watch} returned ",
	        $self->Say($val), ".\n" if $Tie::Watch::DEBUG;
    if ($self->{'op'} =~ /r/) {
	$new_val = &{$self->{cb}} ('r', $val, $new_val, @{$self->{args}});
    }
    return $self->{value} = $new_val;
}

sub STORE {
    my($self, $new_val) = @ARG;
    my $val = $self->{value};
    print "WatchScalar: $self->{watch} changed from ",
	        $self->Say($val), " to ",
	        $self->Say($new_val), ".\n" if $Tie::Watch::DEBUG;
    if ($self->{'op'} =~ /w/) {
	$new_val = &{$self->{cb}} ('w', $val, $new_val, @{$self->{args}});
    }
    return $self->{value} = $new_val;
}

###############################################################################

package Tie::Watch::Array;

use English;
@ISA = qw(Tie::Watch);

sub TIEARRAY {
    my($class, $watch, $op, $cb, @args) = @ARG;
    print "WatchArray: $watch created, \@ARG=@ARG!\n" if $Tie::Watch::DEBUG;
    my $watch_obj = Tie::Watch->BaseWatch($watch, $op, $cb, @args);
    $watch_obj->{ptr} = [];
    return bless $watch_obj, $class;
}

sub Info {
    my($self) = @ARG;
    my %vinfo = $self->SUPER::Info;
    push @{$vinfo{legible}}, "ptr      : " . $self->{ptr};
    $vinfo{ptr} = $self->{ptr};
    return %vinfo;
}

sub DESTROY {
    my($self) = @ARG;
    print "WatchArray: $self->{watch} destructor.\n" if $Tie::Watch::DEBUG;
    undef %$self;
}

sub FETCH {
    my($self, $key) = @ARG;
    my $val = $self->{ptr}->[$key];
    my $new_val = $val;
    print "WatchArray: $self->{watch}", "[$key] returned ",
	        $self->Say($val), ".\n" if $Tie::Watch::DEBUG;
    if ($self->{'op'} =~ /r/) {
	$new_val = &{$self->{cb}} ('r', $val, $new_val, @{$self->{args}});
    }
    return $self->{ptr}->[$key] = $new_val;
}

sub STORE {
    my($self, $key, $new_val) = @ARG;
    my $val = $self->{ptr}->[$key];
    print "WatchArray: $self->{watch}", "[$key] changed from ",
	        $self->Say($val), " to ",
	        $self->Say($new_val), ".\n" if $Tie::Watch::DEBUG;
    if ($self->{'op'} =~ /w/) {
	$new_val = &{$self->{cb}} ('w', $val, $new_val, @{$self->{args}});
    }
    return $self->{ptr}->[$key] = $new_val;
}

###############################################################################

package Tie::Watch::Hash;

use English;
@ISA = qw(Tie::Watch::Array);

sub TIEHASH {
    my($class, $watch, $op, $cb, @args) = @ARG;
    print "WatchHash: $watch created, \@ARG=@ARG!\n" if $Tie::Watch::DEBUG;
    my $watch_obj = Tie::Watch->BaseWatch($watch, $op, $cb, @args);
    $watch_obj->{ptr} = {};
    return bless $watch_obj, $class;
}

sub CLEAR {
    my($self) = @ARG;
    $self->{ptr} = ();
}

sub DELETE {
    my($self, $key) = @ARG;
    delete $self->{ptr}->{$key};
}

sub DESTROY {
    my($self) = @ARG;
    print "WatchHash: $self->{watch} destructor.\n" if $Tie::Watch::DEBUG;
    undef %$self;
}

sub EXISTS {
    my($self, $key) = @ARG;
    return exists $self->{ptr}->{$key};
}

sub FETCH {
    my($self, $key) = @ARG;
    my $val = $self->{ptr}->{$key};
    my $new_val = $val;
    print "WatchHash: $self->{watch}", "{$key} returned ",
	        $self->Say($val), ".\n" if $Tie::Watch::DEBUG;
    if ($self->{'op'} =~ /r/) {
	$new_val = &{$self->{cb}} ('r', $val, $new_val, @{$self->{args}});
    }
    return $self->{ptr}->{$key} = $new_val;
}

sub FIRSTKEY {
    my($self) = @ARG;
    return each %{$self->{ptr}};
}

sub NEXTKEY {
    my($self) = @ARG;
    return each %{$self->{ptr}};
}

sub STORE {
    my($self, $key, $new_val) = @ARG;
    my $val = $self->{ptr}->{$key};
    print "WatchHash: $self->{watch}", "{$key} changed from ",
	        $self->Say($val), " to ",
	        $self->Say($new_val), ".\n" if $Tie::Watch::DEBUG;
    if ($self->{'op'} =~ /w/) {
	$new_val = &{$self->{cb}} ('w', $val, $new_val, @{$self->{args}});
    }
    return $self->{ptr}->{$key} = $new_val;
}

1;
