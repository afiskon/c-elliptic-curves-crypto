#!/usr/bin/perl

# (c) Alexandr A Alexeev 2010 | http://eax.me/

use strict;

my $do = "./bignum-test";
my $a = "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC"; # -3
my $b = "5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b";
my $gx = "6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296";
my $gy = "4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5";
my $p = "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF";

my $x = shift; if($x eq "") { $x = $gx; }
my $y = shift; if($y eq "") { $y = $gy; }

if(($x eq "0") && ($y eq "0")) { exit 0; } # infinite point

my $t1 = `$do mmul $x $x $p`; $t1 =~ s/\n//; # x*x
print "x*x == $t1\n";

my $t2 = `$do mmul $t1 $x $p`; $t2 =~ s/\n//; # x*x*x
print "x*x*x == $t2\n";

$t1 = `$do mmul $a $x $p`; $t1 =~ s/\n//; # a * x
print "a * x == $t1\n";

$t2 = `$do madd $t2 $t1 $p`; $t2 =~ s/\n//; # x*x*x + a*x
print "x*x*x + a*x = $t2\n";

$t2 = `$do madd $t2 $b $p`; $t2 =~ s/\n//; # x*x*x + a*x + b
print "x*x*x - a*x + b = $t2\n";

$t1 = `$do mmul $y $y $p`; $t1 =~ s/\n//; # y*y

print "y*y == $t1\n";

exit ($t1 ne $t2); # 0 - valid point, 1 - invalid
