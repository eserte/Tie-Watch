#!/usr/local/bin/perl -w
# Hmm, expose the incompleteness of tied arrays!
 
use lib '.';
use Tie::Watch;
use Data::Dumper;
use subs qw/aprint aprint2 hprint/;
use vars qw/$shadow $watch/;

$shadow = 1;
 
print "------------ SCALAR -----------\n";
my $aa = 1;
print "$aa\n";
 
print "Tie ...\n";
$watch = new Tie::Watch(-variable => \$aa, -shadow => $shadow);
 
$aa = 3;
print "new value = ", $aa, "!\n";
$watch->Delete;
print "Delete ...\n";
print "$aa\n";
 
print "------------ ARRAY -----------\n";
my @aa = (1,2);
aprint \@aa;
 
print "Tie ...\n";
$watch = new Tie::Watch(-variable => \@aa, -shadow => $shadow);
 
$aa[2] = 3;
print "subscript 2 = ", $aa[2], "!\n";
aprint \@aa;
print "Notice that the tied array knows nothing about array element #3!\n";
$watch->Delete;
print "Delete ...\n";
aprint \@aa;

sub aprint {
    my($hr) = @_;
    my $i = 0;
    foreach (@$hr) {
	print "$i=$_!\n";
	$i++;
    }
}
 
print "------------ HASH -----------\n";
my %aa = (1,11,2,22);
hprint \%aa;
 
print "Tie ...\n";
$watch = new Tie::Watch(-variable => \%aa, -shadow => $shadow);
 
$aa{3} = 33;
print "subscript 3 = ", $aa{3}, "!\n";
hprint \%aa;
$watch->Delete;
print "Delete ...\n";
hprint \%aa;

sub hprint {
    my($hr) = @_;
    foreach (keys %$hr) {
	print "$_=$hr->{$_}!\n";
    }
}
