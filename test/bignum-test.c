/*
 *  (c) Alexandr A Alexeev 2010 | http://eax.me/
 */

#include <stdio.h>
#include <string.h>
#include "../bignum.h"

int main(int argc, char ** argv) {
  bignum_digit_t arg1[BIGNUM_MAX_DIGITS];
  bignum_digit_t arg2[BIGNUM_MAX_DIGITS];
  bignum_digit_t arg3[BIGNUM_MAX_DIGITS];
  bignum_digit_t rslt1[BIGNUM_MAX_DIGITS];
  bignum_digit_t rslt2[BIGNUM_MAX_DIGITS];
  char buff[256];
  int results = 1;

  if((argc < 4) || (argc > 5)) {
    printf("Usage: %s action arg1 arg2 [arg3]\n"
           "available actions: add, sub, mul, div, madd, msub, mmul, mdiv\n",
           argv[0]);
    return 1;
  }

  bignum_fromhex(arg1, argv[2], BIGNUM_DIGITS(sizeof(arg1)));
  bignum_fromhex(arg2, argv[3], BIGNUM_DIGITS(sizeof(arg2)));
  if(argc == 5)
    bignum_fromhex(arg3, argv[4], BIGNUM_DIGITS(sizeof(arg3)));

  memset(rslt1, 0, sizeof(rslt1));
  memset(rslt2, 0, sizeof(rslt2));

  if(argc == 4) {
    if(!strcmp(argv[1], "add")) {
      bignum_add(arg1, arg2, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    } else if(!strcmp(argv[1], "sub")) {
      bignum_sub(arg1, arg2, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    } else if(!strcmp(argv[1], "mul")) {
      bignum_mul(arg1, arg2, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    } else if(!strcmp(argv[1], "div")) {
      if(bignum_iszero(arg2, BIGNUM_DIGITS(sizeof(arg2)))) {
        printf("Error: devision by zero\n");
        return 2;
      }
      bignum_div(arg1, arg2, rslt1, rslt2, BIGNUM_DIGITS(sizeof(arg1)));
      results++;
    }
  } else { /* argc == 5 */
    if(!strcmp(argv[1], "madd")) {
      bignum_madd(arg1, arg2, arg3, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    } else if(!strcmp(argv[1], "msub")) {
      bignum_msub(arg1, arg2, arg3, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    } else if(!strcmp(argv[1], "mmul")) {
      bignum_mmul(arg1, arg2, arg3, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    } else if(!strcmp(argv[1], "mdiv")) {
      bignum_mdiv(arg1, arg2, arg3, BIGNUM_DIGITS(sizeof(arg1)));
      memcpy(rslt1, arg1, sizeof(rslt1));
    }
  }

  bignum_tohex(rslt1, buff, sizeof(buff), BIGNUM_DIGITS(sizeof(rslt1)));
  printf("%s\n", buff);

  if(results == 2) {
    bignum_tohex(rslt2, buff, sizeof(buff), BIGNUM_DIGITS(sizeof(rslt2)));
    printf("%s\n", buff);
  }

  return 0;
}
