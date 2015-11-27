#!/usr/bin/perl

# (c) Alexandr A Alexeev 2010 | http://eax.me/

# тестируем модуль eccrypt.c
use strict;

my $ns = 32; # макс. размер числа в байтах
my $mul_tests = 1024; # сколько раз тесировать правило n * x = x + x + ... + x
my $prog_path = "./eccrypt-test";
my $hex_tbl = "0123456789ABCDEF"; # таблица символов
my $gx = "6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296";
my $gy = "4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5";

my $tests_number = shift;
if($tests_number < 100) {
  print "Usage: ./eccrypt-test.pl <testnum>\n".
        "minimum tests number is 100\n";
  exit 1;
}

for my $test_count(1..$tests_number) {
  my ($k, $n, $x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4);

  print "--- test $test_count ---\n";

  # 0 * inf = inf
  ($x1, $y1) = run("mul", "0", "0", "0");
  unless(($x1 eq "0") && ($y1 eq "0")) {
    print "test $test_count:\n  0 * inf = ($x1, $y1)\n";
    exit 1;
  }

  # 1 * inf = inf
  ($x1, $y1) = run("mul", "0", "0", "1");
  unless(($x1 eq "0") && ($y1 eq "0")) {
    print "test $test_count:\n  1 * inf = ($x1, $y1)\n";
    exit 2;
  }

  # n * inf = inf
  $k = gen_number($ns);
  ($x1, $y1) = run("mul", "0", "0", $k);
  unless(($x1 eq "0") && ($y1 eq "0")) {
    print "test $test_count:\n  $k * inf = ($x1, $y1)\n";
    exit 3;
  }

  # генерируем случайную точку k * G
  ($x1, $y1) = run("mul", $gx, $gy, $k);

  unless(check_point($x1, $y1)) {
    print "test $test_count:\n  x1 = $x1\n  y1 = $y1\n  check_point() failed\n";
    exit 4;
  }

  # inf + P = P
  ($x2, $y2) = run("add", "0", "0", $x1, $y1);
  unless(($x1 eq $x2) && ($y1 eq $y2)) {
    print "test $test_count:\n  inf + ($x1, $y1) = ($x2, $y2)\n";
    exit 5; 
  }

  # P + inf = P
  ($x2, $y2) = run("add", $x1, $y1, "0", "0");
  unless(($x1 eq $x2) && ($y1 eq $y2)) {
    print "test $test_count:\n  ($x1, $y1) + inf = ($x2, $y2)\n";
    exit 6;
  }

  # inf + inf = inf
  ($x2, $y2) = run("add", "0", "0", "0", "0");
  unless(($x2 eq "0") && ($y2 eq "0")) {
    print "test $test_count:\n  inf + inf = ($x2, $y2)\n";
    exit 7;
  }

  # 0 * P = inf
  ($x2, $y2) = run("mul", $x1, $y1, "0");
  unless(($x2 eq "0") && ($y2 eq "0")) {
    print "test $test_count:\n  0 * ($x1, $y1) = ($x2, $y2)\n";
    exit 8;
  }

  # 1 * P = P
  ($x2, $y2) = run("mul", $x1, $y1, "1");
  unless(($x1 eq $x2) && ($y1 eq $y2)) {
    print "test $test_count:\n  1 * ($x1, $y1) = ($x2, $y2)\n";
    exit 9;
  }

  # P + P
  ($x2, $y2) = run("add", $x1, $y1, $x1, $y1);
  if($y1 eq "0") { # что очень маловероятно
    # (x, 0) + (x, 0) = inf
    unless(($x2 eq "0") && ($y2 eq "0")) {
      print "test $test_count:\n  P = ($x1, 0)\n  P + P = ($x2, $y2)\n";
      exit 10;
    }
  } else {
    unless(check_point($x2, $y2)) {
      print "test $test_count:\n  x1 = $x1\n  y1 = $y1\n  P + P = (x2, y2)\n".
        "  x2 = $x2\n  y2 = $y2\n  check_point() failed\n";
      exit 11;
    }
  }

  # n * P = P + P + ... + P
  ($x3, $y3) = ("0", "0");
  for my $cnt (1..$mul_tests) {
    ($x3, $y3) = run("add", $x3, $y3, $x1, $y1);
    ($x2, $y2) = run("mul", $x1, $y1, sprintf("%X", $cnt));

    unless(($x2 eq $x3) && ($y2 eq $y3)) {
      print "test $test_count:\n  ".sprintf("%X", $cnt)." * ".
        "($x1, $y1) == ($x2, $y2), ($x3, $y3) expected\n";
      exit 12;
    }
  }

  # генерируем еще одну точку
  $n = gen_number($ns);
  ($x2, $y2) = run("mul", $gx, $gy, $n); # наша вторая точка

  unless(check_point($x2, $y2)) {
    print "test $test_count:\n  x2 = $x2\n  y2 = $y2\n  check_point() failed\n";
    exit 13;
  }

  # k*(n*P) = n*(k*P)
  ($x3, $y3) = run("mul", $x1, $y1, $n);
  ($x4, $y4) = run("mul", $x2, $y2, $k);

  unless(check_point($x3, $y3)) {
    print "test $test_count:\n  x1 = $x1\n  y1 = $y1\n  P * $n = ($x3, $y3)\n".
      "  check_point() failed\n";
    exit 14;
  }

  unless(($x3 eq $x4) && ($y3 eq $y4)) {
    print "test $test_count:\n";
    print "  x1 = $x1\n  y1 = $y1\n  x2 = $x2\n  y2 = $y2\n";
    print "  P * $n = ($x3, $y3)\n  Q * $k = ($x4, $y4)\n";
    exit 15;
  }

  # находим сумму точек
  ($x3, $y3) = run("add", $x1, $y1, $x2, $y2);
  if(!check_point($x3, $y3)) {
    print "test $test_count:\n  x1 = $x1\n  y1 = $y1\n  x2 = $x2\n".
      "  y2 = $y2\n  x3 = $x2\n  y3 = $y2\n  check_point() failed\n";
    exit 16;
  }
}

exit 0;

# запустить наш калькулятор
sub run() {
  my $args = join " ", @_;
  return split /\n/, `$prog_path $args`;
}

# принадлежит ли точка кривой?
sub check_point() {
  my $args = join " ", @_;
  `./curve-test.pl $args`;
  return ($? == 0);
}

# сгенерировать $_[0]-байтовое случайное число
sub gen_number() {
  my $s = $_[0];
  my $rslt = "";
  for my $i(1..$s*2) {
    $rslt .= substr($hex_tbl, int(rand()*(16 - int($i == 1)) + int($i == 1)), 1);
  }
  return $rslt;
}
