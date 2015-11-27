/*
 *  (c) Alexandr A Alexeev 2010 | http://eax.me/
 */

#include <stdio.h>
#include <string.h>
#include "../eccrypt.h"
#include "eccrypt-test-conf.h"

int usage(char* progname) {
  printf("Usage: %s add x1 y1 x2 y2\n"
         "       %s mul x  y  k\n", progname, progname);
  return 1;
}

int main(int argc, char ** argv) {
  struct eccrypt_curve_t curve;
  struct eccrypt_point_t p1, p2, rslt;
  bignum_digit_t k[ECCRYPT_BIGNUM_DIGITS];
  char buff[256];

  if((argc < 5) || (argc > 6))
    return usage(argv[0]);

  /* инициализируем параметры кривой */
  bignum_fromhex(curve.a, a, ECCRYPT_BIGNUM_DIGITS);
  bignum_fromhex(curve.b, b, ECCRYPT_BIGNUM_DIGITS);
  bignum_fromhex(curve.m, p, ECCRYPT_BIGNUM_DIGITS);
  bignum_fromhex(curve.g.x, gx, ECCRYPT_BIGNUM_DIGITS);
  bignum_fromhex(curve.g.y, gy, ECCRYPT_BIGNUM_DIGITS);
  curve.g.is_inf = 0;

  bignum_fromhex(p1.x, argv[2], ECCRYPT_BIGNUM_DIGITS);
  bignum_fromhex(p1.y, argv[3], ECCRYPT_BIGNUM_DIGITS);
  p1.is_inf = bignum_iszero(p1.x, ECCRYPT_BIGNUM_DIGITS) &&
    bignum_iszero(p1.y, ECCRYPT_BIGNUM_DIGITS);

  if(argc == 6) {
    if(strcmp(argv[1], "add"))
      return usage(argv[0]);
    bignum_fromhex(p2.x, argv[4], ECCRYPT_BIGNUM_DIGITS);
    bignum_fromhex(p2.y, argv[5], ECCRYPT_BIGNUM_DIGITS);
    p2.is_inf = bignum_iszero(p2.x, ECCRYPT_BIGNUM_DIGITS) &&
      bignum_iszero(p2.y, ECCRYPT_BIGNUM_DIGITS);
    eccrypt_point_add(&rslt, &p1, &p2, &curve);
  } else {
    if(strcmp(argv[1], "mul"))
      return usage(argv[0]);
    bignum_fromhex(k, argv[4], ECCRYPT_BIGNUM_DIGITS);
    eccrypt_point_mul(&rslt, &p1, k, &curve);
  }

  if(rslt.is_inf) {
    printf("0\n0\n(infinite point)\n");
  } else {
    bignum_tohex(rslt.x, buff, sizeof(buff), ECCRYPT_BIGNUM_DIGITS);
    printf("%s\n", buff);
    bignum_tohex(rslt.y, buff, sizeof(buff), ECCRYPT_BIGNUM_DIGITS);
    printf("%s\n", buff);
    printf("(real point)\n");
  }

  return 0;
} 
