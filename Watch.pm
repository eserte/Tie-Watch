$Tie::Watch::VERSION = '0.98';

package Tie::Watch;

=head1 NAME

 Tie::Watch - place watchpoints on Perl variables.

=head1 SYNOPSIS

 use Tie::Watch;

 $watch = Tie::Watch->new(
     -variable => \$frog,
     -debug    => 1,
     -shadow   => 0,			  
     -fetch    => [\&fetch, 'arg1', 'arg2', ..., 'argn'],
     -store    => \&store,
     -destroy  => sub {print "Final value=$frog.\n"},
 }
 %vinfo = $watch->Info;
 $args  = $watch->Args(-fetch);
 $val   = $watch->Fetch;
 print "val=", $watch->Say($val), ".\n";
 $watch->Store('Hello');
 $watch->Delete;

=head1 DESCRIPTION

This class module binds one or more  subroutines of your devising to a
Perl  variable.  All   variables  can  have   B<FETCH>, B<STORE>   and
B<DESTROY>  callbacks.   Additionally,  hashes   can define  B<CLEAR>,
B<DELETE>,  B<EXISTS>,  B<FIRSTKEY>  and B<NEXTKEY>   callbacks.  With
Tie::Watch you can:

 . alter a variable's value
 . prevent a variable's value from being changed
 . invoke a Perl/Tk callback when a variable changes
 . trace references to a variable

Callback format is patterned after the Perl/Tk scheme: supply either a
code reference, or, supply an array reference and pass the callback
code reference in the first element of the array, followed by callback
arguments.  (See examples in the Synopsis, above.)

Tie::Watch provides default callbacks for any that you fail to
specify.  Other than negatively impacting performance, they perform
the standard action that you'd expect, so the variable behaves
"normally".

Here are two callbacks for a scalar. The B<FETCH> (read) callback does
nothing other than illustrate the fact that it returns the value to
assign the variable.  The B<STORE> (write) callback uppercases the
variable.  In all cases the callback I<must> return the correct read
or write value.

 my $fetch_scalar = sub {
     my($self) = @ARG;
     $self->Fetch;
 };

 my $store_scalar = sub {
     my($self, $new_val) = @ARG;
     $self->Store(uc $new_val);
 };

Here are B<FETCH> and B<STORE> callbacks for either an array or hash.
They do essentially the same thing as the scalar callbacks, but
provide a little more information.

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

In all cases, the first parameter is a reference to the Watch object.
You can use this to invoke useful class methods.

=head1 METHODS

=over 4

=item $watch = Tie::Watch->new(-options => values);

The watchpoint constructor method that accepts option/value pairs to
create and configure the Watch object.  The only required option is
B<-variable>.

B<-variable> is a I<reference> to a scalar, array or hash variable.

B<-debug> (default 0) is 1 to activate debug print statements internal
to Tie::Watch.

B<-shadow> (default 1) is 0 to disable array and hash shadowing.  To
prevent infinite recursion Tie::Watch maintains parallel variables for
arrays and hashes.  When the watchpoint is created the parallel shadow
variable is initialized with the watched variable's contents, and when
the watchpoint is deleted the shadow variable is copied to the original
variable.  Thus, changes made during the watch process are not lost.
Shadowing is on my default.  If you disable shadowing any changes made
to an array or hash are lost when the watchpoint is deleted.

Specify any of the following relevant callback parameters, in the
format described above: B<-fetch>, B<-store>, B<-destroy>, B<-clear>,
B<-delete>, B<-exists>, B<-firstkey>, and/or B<-nextkey>.

=item $args = $watch->Args(-fetch);

Return a reference to a list of arguments for the specified callback,
or undefined if none.

=item $watch->Delete();

Stop watching the variable.

=item $watch->Fetch();  $watch->Fetch($key);

Return a variable's current value.  $key is required for an array or
hash.

=item %vinfo = $watch->Info();

Returns a hash detailing the internals of the Watch object, with these
keys:

 %vinfo = {
     -variable =>  SCALAR(0x200737f8)
     -fetch    =>  ARRAY(0x200f8558)
     -store    =>  ARRAY(0x200f85a0)
     -destroy  =>  ARRAY(0x200f86cc)
     -debug    =>  '0'
     -shadow   =>  '1'
     -value    =>  'HELLO SCALAR'
     -legible  =>  above data formatted as a list of string, for printing
 }

For array and hash Watch objects, the B<-value> key is replaced with a
B<-ptr> key which is a reference to the parallel array or hash.
Additionally, for hashes, there are key/value pairs for the
hash-specific callback options.

=item $watch->Say($val);

Used mainly for debugging, it returns $val in quotes if required, or
the string "undefined" for undefined values.

=item $watch->Store($new_val);  $watch->Store($key, $new_val);

Store a variable's new value.  $key is required for an array or hash.

=back

=head1 EFFICIENCY CONSIDERATIONS

If you can live using the class methods provided, please do so.  You
can meddle with the object hash directly and improved watch
performance, at the risk of your code breaking in the future.

=head1 BUGS

Perl's implementation of tied arrays is incomplete, hence Tie::Watch
operations on arrays cannot be fully supported.

=head1 AUTHOR

Stephen.O.Lidie@Lehigh.EDU

=head1 HISTORY

 lusol@Lehigh.EDU, LUCC, 96/05/30
 . Original version 0.92 release, based on the Trace module from Hans Mulder,
   and ideas from Tim Bunce.

 lusol@Lehigh.EDU, LUCC, 96/12/25
 . Version 0.96, release two inner references detected by Perl 5.004.

 lusol@Lehigh.EDU, LUCC, 97/01/11
 . Version 0.97, fix Makefile.PL and MANIFEST (thanks Andreas Koenig).
   Make sure test.pl doesn't fail if Tk isn't installed.

 Stephen.O.Lidie@Lehigh.EDU, Lehigh University Computing Center, 97/10/03
 . Version 0.98, implement -shadow option for arrays and hashes.

=head1 COPYRIGHT

Copyright (C) 1996 - 1997 Stephen O. Lidie. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

use Carp;
use English;
use strict;
use subs qw(normalize_callbacks);

sub new {

    # Watch constructor.  The *real* constructor is Tie::Watch->base_watch(),
    # invoked by methods in other Watch packages, depending upon the variable's
    # type.  Here we supply defaulted parameter values and then verify them,
    # normalize all callbacks and bind the variable to the appropriate package.

    my($class, %args) = @ARG;
    my $version = $Tie::Watch::VERSION;
    my (%arg_defaults) = (
	-fetch    => [],
	-store    => [],
	-destroy  => [sub {my($self) = @ARG; undef %$self}, undef],
        -debug    => 0,
	-shadow   => 1,
	-clear    => [sub {shift->{ptr} = ()}, undef],
	'-delete' => [sub {my($self, $key) = @ARG;
			   delete $self->{-ptr}->{$key}}, undef],
	'-exists' => [sub {my($self, $key) = @ARG;
			   exists $self->{-ptr}->{$key}}, undef],
        -firstkey => [sub {my($self) = @ARG; my $a = keys %{$self->{-ptr}};
			   return each %{$self->{-ptr}}}, undef],
	-nextkey  => [sub {my($self) = @ARG; 
			   return each %{$self->{-ptr}}}, undef],
    );
    my $variable = $args{-variable};
    croak "Tie::Watch: -variable is required." if not defined $variable;
    my($type, $watch_obj) = (ref $variable, undef);
    if ($type =~ /SCALAR/) {
	$arg_defaults{-fetch} = [\&Tie::Watch::Scalar::Fetch, undef];
	$arg_defaults{-store} = [\&Tie::Watch::Scalar::Store, undef];
    } elsif ($type =~ /ARRAY/) {
	$arg_defaults{-fetch} = [\&Tie::Watch::Array::Fetch, undef];
	$arg_defaults{-store} = [\&Tie::Watch::Array::Store, undef];
    } elsif ($type =~ /HASH/) {
	$arg_defaults{-fetch} = [\&Tie::Watch::Hash::Fetch, undef];
	$arg_defaults{-store} = [\&Tie::Watch::Hash::Store, undef];
    } else {
	croak "Tie::Watch - not a variable reference.";
    }
    my(@margs, %ahsh, $args, @args);
    @margs = grep ! defined $args{$ARG}, keys %arg_defaults;
    %ahsh = %args;
    @ahsh{@margs} = @arg_defaults{@margs};
    my($fetch, $store, $destroy, $debug, $shadow) =
      @ahsh{-fetch, -store, -destroy, -debug, -shadow};
    normalize_callbacks($fetch, $store, $destroy);

    if ($type =~ /SCALAR/) {
        $watch_obj = tie $$variable, 'Tie::Watch::Scalar', $variable, $fetch,
	$store, $destroy, $debug, $shadow;
    } elsif ($type =~ /ARRAY/) {
        $watch_obj = tie @$variable, 'Tie::Watch::Array',  $variable, $fetch,
	$store, $destroy, $debug, $shadow;
    } elsif ($type =~ /HASH/) {
        my($clear, $delete, $exists, $firstkey, $nextkey) =
	  @ahsh{-clear, '-delete', '-exists', -firstkey, -nextkey};
	normalize_callbacks($clear, $delete, $exists, $firstkey, $nextkey);
        $watch_obj = tie %$variable, 'Tie::Watch::Hash',   $variable, $fetch,
	  $store, $destroy, $debug, $shadow, $clear, $delete, $exists,
	  $firstkey, $nextkey;
    }
    $watch_obj;

} # end new, Watch constructor

sub Args {

    # Return a reference to a list of callback arguments.

    my($self, $callback) = @ARG;
    undef;
    [@{$self->{$callback}}[1 .. $#{$self->{$callback}}]] if
      defined $self->{$callback}->[1];
} # end Args

sub Delete {

    # Stop watching a variable by releasing the last reference and untieing it.
    # Update the original variable with its shadow, if appropriate.

    my $variable = $_[0]->{-variable};
    my $type = ref $variable;
    my $copy = $_[0]->{-ptr} if $type !~ /SCALAR/;
    my $shadow = $_[0]->{-shadow};
    undef $_[0];
    if ($type =~ /SCALAR/) {
	untie $$variable;
    } elsif ($type =~ /ARRAY/) {
	untie @$variable;
	@$variable = @$copy if $shadow;
    } elsif ($type =~ /HASH/) {
	untie %$variable;
	%$variable = %$copy if $shadow;
    } else {
	croak "Tie::Watch - not a variable reference.";
    }
} # end Delete

sub Info {

    # Info() method subclassed by other Watch modules.

    my($self) = @ARG;
    my(%vinfo, @results);
    push @results, "variable : " . $self->Say($self->{-variable});
    push @results, "fetch    : " . $self->Say($self->{-fetch});
    push @results, "store    : " . $self->Say($self->{-store});
    push @results, "destroy  : " . $self->Say($self->{-destroy});
    push @results, "debug    : " . $self->Say($self->{-debug});
    push @results, "shadow   : " . $self->Say($self->{-shadow});

    %vinfo = (
        -variable => $self->{-variable},
        -fetch    => $self->{-fetch},
        -store    => $self->{-store},
        -destroy  => $self->{-destroy},
        -debug    => $self->{-debug},
        -shadow   => $self->{-shadow},
        -legible  => [@results],
    );
    return %vinfo;
} # end Info

sub Say {

    # For debugging, mainly.

    my($self, $val) = @ARG;
    defined $val ? (ref($val) ne '' ? $val : "'$val'") : "undefined";
} # end Say

# Watch private methods.

sub base_watch {

    # Watch base class constructor invoked by other Watch modules.

    my($class, $variable, $fetch, $store, $destroy, $debug, $shadow) = @ARG;
    my $watch_obj = {
        -variable => $variable,
	-fetch    => $fetch,
	-store    => $store,
	-destroy  => $destroy,
	-debug    => $debug,
	-shadow   => $shadow,
    }; 
    bless $watch_obj, $class;
} # end base_watch

sub callback {
    
    # Execute a Watch callback, either the default or user specified.

    my($self, $callback, @args) = @ARG;
    print "Watch callback $callback:  ARG = ", join(',', @ARG), ".\n" if
      $self->{-debug};
    &{$self->{$callback}->[0]} ($self, @args);
} # end callback

sub normalize_callbacks {

    # Ensure all callbacks are normalized in [\&code, @args] format.

    my($cb, $ref);
    foreach $cb (@ARG) {
	$ref = ref $cb;
	if ($ref =~ /CODE/) {
	    $cb = [$cb, undef];
	} elsif ($ref !~ /ARRAY/) {
	    croak "Tie::Watch:  malformed callback.";
	}
    }
} # end normalize_callbacks

###############################################################################

package Tie::Watch::Scalar;

use Carp;
use English;
@Tie::Watch::Scalar::ISA = qw(Tie::Watch);

sub TIESCALAR {
    my($class, $variable, $fetch, $store, $destroy, $debug, $shadow) = @ARG;
    my $watch_obj = Tie::Watch->base_watch($variable, $fetch, $store, $destroy,
					   $debug, $shadow);
    $watch_obj->{-value} = $$variable;
    print "WatchScalar new: $variable created, \@ARG=", join(',', @ARG), "!\n"
      if $watch_obj->{-debug};
    bless $watch_obj, $class;
}

sub Fetch {shift->{-value}}

sub Info {
    my($self) = @ARG;
    my %vinfo = $self->SUPER::Info;
    push @{$vinfo{-legible}}, "value    : " . $self->Say($self->{-value});
    $vinfo{-value} = $self->{-value};
    return %vinfo;
}

sub Store {my($self, $new_val) = @ARG; $self->{-value} = $new_val}

sub DESTROY {
    my($self) = @ARG;
    $self->callback(-destroy);
}

sub FETCH {
    my($self) = @ARG;
    $self->callback(-fetch);
}

sub STORE {
    my($self, $new_val) = @ARG;
    $self->callback(-store, $new_val);
}

###############################################################################

package Tie::Watch::Array;

use Carp;
use English;
@Tie::Watch::Array::ISA = qw(Tie::Watch);

sub TIEARRAY {
    my($class, $variable, $fetch, $store, $destroy, $debug, $shadow) = @ARG;
    my @copy = @$variable if $shadow; # make a private copy of user's array
    my $watch_obj = Tie::Watch->base_watch($variable, $fetch, $store, $destroy,
					   $debug, $shadow);
    $watch_obj->{-ptr} = $shadow ? \@copy : [];
    print "WatchArray new: $variable created, \@ARG=", join(',', @ARG), "!\n"
      if $watch_obj->{-debug};
    bless $watch_obj, $class;
}

sub Fetch {shift->{-ptr}->[shift()]}

sub Info {
    my($self) = @ARG;
    my %vinfo = $self->SUPER::Info;
    push @{$vinfo{-legible}}, "ptr      : " . $self->Say($self->{-ptr});
    $vinfo{-ptr} = $self->{-ptr};
    return %vinfo;
}

sub Store {my($self, $key, $new_val) = @ARG; $self->{-ptr}->[$key] = $new_val}

sub DESTROY {
    my($self) = @ARG;
    $self->callback(-destroy);
}

sub FETCH {
    my($self, $key) = @ARG;
    $self->callback(-fetch, $key);
}

sub STORE {
    my($self, $key, $new_val) = @ARG;
    $self->callback(-store, $key, $new_val);
}

###############################################################################

package Tie::Watch::Hash;

use Carp;
use English;
@Tie::Watch::Hash::ISA = qw(Tie::Watch::Array);

sub TIEHASH {
    my($class, $variable, $fetch, $store, $destroy, $debug, $shadow,
       $clear, $delete, $exists, $firstkey, $nextkey) = @ARG;
    my %copy = %$variable if $shadow; # make a private copy of user's hash
    my $watch_obj = Tie::Watch->base_watch($variable, $fetch, $store, $destroy,
					   $debug, $shadow);
    $watch_obj->{-ptr}      = $shadow ? \%copy : {};
    $watch_obj->{-clear}    = $clear;
    $watch_obj->{'-delete'} = $delete;
    $watch_obj->{'-exists'} = $exists;
    $watch_obj->{-firstkey} = $firstkey;
    $watch_obj->{-nextkey}  = $nextkey;
    print "WatchHash new: $variable created, \@ARG=", join(',', @ARG), "!\n"
      if $watch_obj->{-debug};
    bless $watch_obj, $class;
}

sub Fetch {shift->{-ptr}->{shift()}}

sub Info {
    my($self) = @ARG;
    my %vinfo = $self->SUPER::Info;
    push @{$vinfo{-legible}}, "clear    : " . $self->Say($self->{-clear});
    push @{$vinfo{-legible}}, "delete   : " . $self->Say($self->{'-delete'});
    push @{$vinfo{-legible}}, "exists   : " . $self->Say($self->{'-exists'});
    push @{$vinfo{-legible}}, "firstkey : " . $self->Say($self->{-firstkey});
    push @{$vinfo{-legible}}, "nextkey  : " . $self->Say($self->{-nextkey});
    $vinfo{-clear}    = $self->{-clear};
    $vinfo{'-delete'} = $self->{'-delete'};
    $vinfo{'exists'}  = $self->{'-exists'};
    $vinfo{-firstkey} = $self->{-firstkey};
    $vinfo{-nextkey}  = $self->{-nextkey};
    return %vinfo;
}

sub Store {my($self, $key, $new_val) = @ARG; $self->{-ptr}->{$key} = $new_val}

sub CLEAR {
    my($self) = @ARG;
    $self->callback(-clear);
}

sub DELETE {
    my($self, $key) = @ARG;
    $self->callback('-delete', $key);
}

sub DESTROY {
    my($self) = @ARG;
    $self->callback(-destroy);
}

sub EXISTS {
    my($self, $key) = @ARG;
    $self->callback('-exists', $key);
}

sub FETCH {
    my($self, $key) = @ARG;
    $self->callback(-fetch, $key);
}

sub FIRSTKEY {
    my($self) = @ARG;
    $self->callback(-firstkey);
}

sub NEXTKEY {
    my($self) = @ARG;
    $self->callback(-nextkey);
}

sub STORE {
    my($self, $key, $new_val) = @ARG;
    $self->callback(-store, $key, $new_val);
}

1;
