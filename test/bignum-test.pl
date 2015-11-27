#!/usr/bin/perl

# (c) Alexandr A Alexeev 2010 | http://eax.me/


# тестируем модуль bignum
# TODO: выполнять тесты test16, test32, test64
use strict;

my $ns = 32; # макс. размер числа в байтах
my $prog_path = "./bignum-test"; # путь к тестируемой программе
my $primefile = "prime-numbers.txt";
my $hex_tbl = "0123456789ABCDEF"; # таблица символов

my $tests_number = shift;
if($tests_number < 100) {
  print "Usage: ./bignum-test.pl <testnum> [gen-prime-numbers]\n".
        "minimum tests number is 100\n";
  exit 1;
}

my $gen = shift;

# таблица простых чисел до 2000
my @prime_tbl = (# "2",
  "3", "5", "7", "B", "D", "11", "13", "17", "1D", "1F",
  "25", "29", "2B", "2F", "35", "3B", "3D", "43", "47", "49", "4F", "53",
  "59", "61", "65", "67", "6B", "6D", "71", "7F", "83", "89", "8B", "95",
  "97", "9D", "A3", "A7", "AD", "B3", "B5", "BF", "C1", "C5", "C7", "D3",
  "DF", "E3", "E5", "E9", "EF", "F1", "FB", "101", "107", "10D", "10F", "115",
#  "119", "11B", "125", "133", "137", "139", "13D", "14B", "151", "15B", "15D",
#  "161", "167", "16F", "175", "17B", "17F", "185", "18D", "191", "199", "1A3",
#  "1A5", "1AF", "1B1", "1B7", "1BB", "1C1", "1C9", "1CD", "1CF", "1D3", "1DF",
#  "1E7", "1EB", "1F3", "1F7", "1FD", "209", "20B", "21D", "223", "22D", "233",
#  "239", "23B", "241", "24B", "251", "257", "259", "25F", "265", "269", "26B",
#  "277", "281", "283", "287", "28D", "293", "295", "2A1", "2A5", "2AB", "2B3",
#  "2BD", "2C5", "2CF", "2D7", "2DD", "2E3", "2E7", "2EF", "2F5", "2F9", "301",
#  "305", "313", "31D", "329", "32B", "335", "337", "33B", "33D", "347", "355",
#  "359", "35B", "35F", "36D", "371", "373", "377", "38B", "38F", "397", "3A1",
#  "3A9", "3AD", "3B3", "3B9", "3C7", "3CB", "3D1", "3D7", "3DF", "3E5", "3F1",
#  "3F5", "3FB", "3FD", "407", "409", "40F", "419", "41B", "425", "427", "42D",
#  "43F", "443", "445", "449", "44F", "455", "45D", "463", "469", "47F", "481",
#  "48B", "493", "49D", "4A3", "4A9", "4B1", "4BD", "4C1", "4C7", "4CD", "4CF",
#  "4D5", "4E1", "4EB", "4FD", "4FF", "503", "509", "50B", "511", "515", "517",
#  "51B", "527", "529", "52F", "551", "557", "55D", "565", "577", "581", "58F",
#  "593", "595", "599", "59F", "5A7", "5AB", "5AD", "5B3", "5BF", "5C9", "5CB",
#  "5CF", "5D1", "5D5", "5DB", "5E7", "5F3", "5FB", "607", "60D", "611", "617",
#  "61F", "623", "62B", "62F", "63D", "641", "647", "649", "64D", "653", "655",
#  "65B", "665", "679", "67F", "683", "685", "69D", "6A1", "6A3", "6AD", "6B9",
#  "6BB", "6C5", "6CD", "6D3", "6D9", "6DF", "6F1", "6F7", "6FB", "6FD", "709",
#  "713", "71F", "727", "737", "745", "74B", "74F", "751", "755", "757", "761",
#  "76D", "773", "779", "78B", "78D", "79D", "79F", "7B5", "7BB", "7C3", "7C9",
#  "7CD", "7CF"
);

# загружаем простые числа в массив
my @prime = ();
if($gen ne "gen-prime-numbers") {
  open PRIME, "$primefile" or die "Failed to open $primefile\n";
  while(my $line = <PRIME>) {
    $line =~ s/\n//;
    push @prime, $line;
  }
  close PRIME;
}

for my $test_count(1..$tests_number) {
  my ($a, $b, $c, $p, $r1, $r2, $r3);

  $a = gen_number(int(rand()*($ns-1)) + 1); # 1..$ns-1 байт
  $b = gen_number(int(rand()*($ns-1)) + 1);
  $c = gen_number(int(rand()*($ns-1)) + 1);
  
  if($gen eq "gen-prime-numbers") {
    $p = gen_prime($ns);
    # простые числа генерируются довольно долго, так что сохраняем их
    open PRIME, ">>$primefile";
    print PRIME "$p\n";
    close PRIME;
  } else {
    $p = $prime[int(rand() * scalar @prime)]; # берем случайное простое число
  }

  print "--- test $test_count ---\n  a = $a\n  b = $b\n  c = $c\n  p = $p\n";

  # сложение с нулем
  ($r1) = run("add", $a, "0");
  unless($r1 eq $a) {
    die "test $test_count: $a + 0 = $r1\n";
  }

  ($r1) = run("madd", $a, "0", $p);
  unless($r1 eq $a) {
    die "test $test_count: $a + 0 = $r1 (mod $p)\n";
  }

  ($r1) = run("add", "0", $b);
  unless($r1 eq $b) {
    die "test $test_count: 0 + $b = $r1\n";
  }

  ($r1) = run("madd", "0", $b, $p);
  unless($r1 eq $b) {
    die "test $test_count: 0 + $b = $r1 (mod $p)\n";
  }

  # вычитание нуля
  ($r1) = run("sub", $c, "0");
  unless($r1 eq $c) {
    die "test $test_count: $c - 0 = $r1\n";
  }

  ($r1) = run("msub", $c, "0", $p);
  unless($r1 eq $c) {
    die "test $test_count: $c - 0 = $r1 (mod $p)\n";
  }

  # умножение на 0
  ($r1) = run("mul", $a, "0");
  unless($r1 eq "0") {
    die "test $test_count: $a * 0 = $r1\n";
  }

  ($r1) = run("mmul", $a, "0", $p);
  unless($r1 eq "0") {
    die "test $test_count: $a * 0 = $r1 (mod $p)\n";
  }

  ($r1) = run("mul", "0", $b);
  unless($r1 eq "0") {
    die "test $test_count: 0 * $b = $r1\n";
  }

  ($r1) = run("mmul", "0", $b, $p);
  unless($r1 eq "0") {
    die "test $test_count: 0 * $b = $r1 (mod $p)\n";
  }

  # умножение на 1
  ($r1) = run("mul", $a, "1");
  unless($r1 eq $a) {
    die "test $test_count: $a * 1 = $r1\n";
  }

  ($r1) = run("mmul", $a, "1", $p);
  unless($r1 eq $a) {
    die "test $test_count: $a * 1 = $r1 (mod $p)\n";
  }

  ($r1) = run("mul", "1", $b);
  unless($r1 eq $b) {
    die "test $test_count: 1 * $b = $r1\n";
  }

  ($r1) = run("mmul", "1", $b, $p);
  unless($r1 eq $b) {
    die "test $test_count: 1 * $b = $r1 (mod $p)\n";
  }

  # деление нуля
  ($r1, $r2) = run("div", "0", $a);
  unless(($r1 eq "0") && ($r2 eq "0")) {
    die "test $test_count:\n  0 / $a = $r1\n  0 % $a = $r2\n";
  }

  # деление нуля в поле вычетов
  ($r1) = run("mdiv", "0", $a, $p);
  unless($r1 eq "0") {
    die "test $test_count:\n  0 / $a = $r1 (mod $p)\n";
  }

  # деление на 1
  ($r1, $r2) = run("div", $b, "1");
  unless(($r1 eq $b) && ($r2 eq "0")) {
    die "test $test_count:\n  $b / 1 = $r1\n$b % 1 = $r2\n";
  }

  # деление на 1 в поле вычетов
  ($r1) = run("mdiv", $b, "1", $p);
  unless($r1 eq $b) {
    die "test $test_count:\n  $b / 1 = $r1 (mod $p)\n";
  }

  # a - a = 0
  ($r1) = run("sub", $a, $a);
  unless($r1 eq "0") {
    die "test $test_count:\n  $a - $a = $r1\n";
  }

  # a - a = 0 (mod p)
  ($r1) = run("msub", $a, $a, $p);
  unless($r1 eq "0") {
    die "test $test_count:\n  $a - $a = $r1 (mod $p)\n";
  }

  # a / a = 1, a % a = 0
  ($r1, $r2) = run("div", $a, $a);
  unless(($r1 eq "1") && ($r2 eq "0")) {
    die "test $test_count:\n  $a / $a = $r1\n  $a % $a = $r2\n";
  }

  # a / a = 1 (mod p)
  ($r1) = run("mdiv", $a, $a, $p);
  unless($r1 eq "1") {
    die "test $test_count:\n  $a / $a = $r1 (mod $p)\n";
  }

  # операция вычитания обратна операции сложения
  ($r2) = run("add", $a, $c);
  ($r1) = run("sub", $r2, $c);
  ($r2) = run("sub", $r2, $a);
  unless(($r1 eq $a) && ($r2 eq $c)) {
    die "test $test_count:\n  $a + $c - $c = $r1\n  $a + $c - $a = $r2\n";
  }

  # операция вычитания обратна операции сложения в поле вычетов
  ($r2) = run("madd", $a, $c, $p);
  ($r1) = run("msub", $r2, $c, $p);
  ($r2) = run("msub", $r2, $a, $p);
  unless(($r1 eq $a) && ($r2 eq $c)) {
    die "test $test_count:\n  $a + $c - $c = $r1 (mod $p)\n".
      "  $a + $c - $a = $r2 (mod $p)\n";
  }

  # коммутативность сложения
  ($r1) = run("add", $a, $b);
  ($r2) = run("add", $b, $a);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a + $b = $r1\n  $b + $a = $r2\n";
  }

  # коммутативность сложения в поле вычетов
  ($r1) = run("madd", $a, $b, $p);
  ($r2) = run("madd", $b, $a, $p);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a + $b = $r1 (mod $p)\n".
      "  $b + $a = $r2 (mod $p)\n";
  }

  # ассоциативность сложения
  ($r1) = run("add", $a, $b);
  ($r1) = run("add", $r1, $c);
  ($r2) = run("add", $b, $c);
  ($r2) = run("add", $a, $r2);
  unless($r1 eq $r2) {
    die "test $test_count:\n  ($a + $b) + $c = $r1\n  $a + ($b + $c) = $r2\n";
  }

  # ассоциативность сложения в поле вычетов
  ($r1) = run("madd", $a, $b, $p);
  ($r1) = run("madd", $r1, $c, $p);
  ($r2) = run("madd", $b, $c, $p);
  ($r2) = run("madd", $a, $r2, $p);
  unless($r1 eq $r2) {
    die "test $test_count:\n  ($a + $b) + $c = $r1 (mod $p)\n".
      "  $a + ($b + $c) = $r2 (mod $p)\n";
  }

  # коммутативность умножения
  ($r1) = run("mul", $a, $b);
  ($r2) = run("mul", $b, $a);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a * $b = $r1\n  $b * $a = $r2\n";
  }

  # коммутативность умножения в поле вычетов
  ($r1) = run("mmul", $a, $b, $p);
  ($r2) = run("mmul", $b, $a, $p);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a * $b = $r1 (mod $p)\n".
      "  $b * $a = $r2 (mod $p)\n";
  }

  # ассоциативность умножения
  ($r1) = run("mul", $a, $b);
  ($r1) = run("mul", $r1, $c);
  ($r2) = run("mul", $b, $c);
  ($r2) = run("mul", $a, $r2);
  unless($r1 eq $r2) {
    die "test $test_count:\n  ($a * $b) * $c = $r1\n  $a * ($b * $c) = $r2\n";
  }

  # ассоциативность умножения в поле вычетов
  ($r1) = run("mmul", $a, $b, $p);
  ($r1) = run("mmul", $r1, $c, $p);
  ($r2) = run("mmul", $b, $c, $p);
  ($r2) = run("mmul", $a, $r2, $p);
  unless($r1 eq $r2) {
    die "test $test_count:\n  ($a * $b) * $c = $r1 (mod $p)\n".
      "  $a * ($b * $c) = $r2 (mod $p)\n";
  }

  # распределительный закон
  ($r1) = run("mul", $a, $c);
  ($r2) = run("mul", $b, $c);
  ($r1) = run("add", $r1, $r2);
  ($r2) = run("add", $a, $b);
  ($r2) = run("mul", $r2, $c);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a*$c + $b*$c = $r1\n  ($a + $b)*$c = $r2\n";
  }

  # распределительный закон в поле вычетов
  ($r1) = run("mmul", $a, $c, $p);
  ($r2) = run("mmul", $b, $c, $p);
  ($r1) = run("madd", $r1, $r2, $p);
  ($r2) = run("madd", $a, $b, $p);
  ($r2) = run("mmul", $r2, $c, $p);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a*$c + $b*$c = $r1 (mod $p)\n".
      "  ($a + $b)*$c = $r2 (mod $p)\n";
  }

  ($r1) = run("mul", $a, $c);
  ($r2) = run("mul", $b, $c);
  ($r1) = run("sub", $r1, $r2);
  ($r2) = run("sub", $a, $b);
  ($r2) = run("mul", $r2, $c);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a*$c - $b*$c = $r1\n  ($a - $b)*$c = $r2\n";
  }

  ($r1) = run("mmul", $a, $c, $p);
  ($r2) = run("mmul", $b, $c, $p);
  ($r1) = run("msub", $r1, $r2, $p);
  ($r2) = run("msub", $a, $b, $p);
  ($r2) = run("mmul", $r2, $c, $p);
  unless($r1 eq $r2) {
    die "test $test_count:\n  $a*$c - $b*$c = $r1 (mod $p)\n".
      "  ($a - $b)*$c = $r2 (mod $p)\n";
  }

  # операция деления обратна операции умножения в поле вычетов
  ($r1) = run("mmul", $b, $c, $p);
  ($r2) = run("mdiv", $r1, $b, $p);
  ($r3) = run("mdiv", $r1, $c, $p);
  unless(($r2 eq $c) && ($r3 eq $b)) {
    die "test $test_count:\n  $b * $c = $r1 (mod $p)\n".
      "  $r1 / $b = $r2 (mod $p)\n  $r1 / $c = $r3 (mod $p)\n";
  }

  # тестируем деление с остатком
  while(1) {
    $b = gen_number(int(rand()*($ns/4) + 1));
    unless($b eq "0") { last; }
  }
  ($r1, $r2) = run("div", $a, $b);
  ($r3) = run("mul", $r1, $b);
  ($r3) = run("add", $r3, $r2);
  unless($r3 eq $a) {
    die "test $test_count:\n  $a/$b = $r1\n  $a%$b = $r2\n  $r1*$b+$r2 = $r3\n";
  }
}

exit 0;

# генерируем простое число средствами тестируемой программы
sub gen_prime() {
  my $s = $_[0];

  my ($test, $t);
  while(1) {
    $test = substr($hex_tbl, int(rand()*15) + 1, 1);
    $test .= gen_number($s - 1);

    # младший бит должен быть равен единице
    $t = int(rand()*16); # 0..15
    $t += !($t & 1); # 1, 3, 5, ... 15
    $test .= substr($hex_tbl, $t, 1);

    for my $x (@prime_tbl) {
       (undef, $t) = run("div", $test, $x);
       if($t eq "0") { last; }
    }
    if($t eq "0") { next; }
    for my $i (1..5) {
      $t = rm_test($test);
      if($t == 0) { last };
    }

    if($t > 0) { last; }
  }

  return $test;
}

# тест Рабина-Миллера
sub rm_test() {
  my ($p) = @_;
  # находим b - число делителей p-1 на 2 и m: p = 1 + 2^b * m
  my ($tmp) = run("sub", $p, "1");
  my ($b, $pow2, $m, $new_m, $r) = (0, "1", "0", "0", "0");
  while(1) {
    ($pow2) = run("mul", $pow2, "2");
    ($new_m, $r) = run("div", $tmp, $pow2);
    if($r ne "0") { last; }
    $b++;
    $m = $new_m;
  }

  # if($b == 0) { return 0; } # p - вообще четное

  my $a = gen_number(4); # генерируем случайное небольшое a, явно меньшее p
  my ($z) = mpow($a, $m, $p);
  if($z eq "1") {
    return 1; # p может быть простым
  }

  for my $j (0 .. $b-1) {
    if(($j > 0) && ($z eq "1")) {
      return 0; # p - составное
    }

    if($z eq $tmp) {
      return 1;
    }

    ($z) = mpow($z, $z, $p);
  }

  return 0; # p составное
}

# возведение $_[0] в степень $_[1] по модулю $_[2]
sub mpow() {
  my ($a, $b, $c) = @_;
  my $rslt = "1";
  while($b ne "0") {
    my $tmp; # остаток от деления, младший разряд
    ($b, $tmp) = run("div", $b, "2");
    if($tmp eq "1") {
      ($rslt) = run("mmul", $rslt, $a, $c);
    }
    ($a) = run("mmul", $a, $a, $c);
  }
  return $rslt;
}

# запустить наш калькулятор
sub run() {
  my $args = join " ", @_;
  return split /\n/, `$prog_path $args`;
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
