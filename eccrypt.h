#include "bignum.h"

/*
 *  (c) Alexandr A Alexeev 2010 | http://eax.me/
 */

/* число разрядов в числах, используемых модулем, <= BIGNUM_MAX_DIGITS */
#define ECCRYPT_BIGNUM_DIGITS BIGNUM_MAX_DIGITS

/* точка на эллиптической кривой */
struct eccrypt_point_t {
  bignum_digit_t x[ECCRYPT_BIGNUM_DIGITS]; /* координата x */
  bignum_digit_t y[ECCRYPT_BIGNUM_DIGITS]; /* координата y */
  int is_inf; /* является ли точка несобственной */
};

/* параметры кривой */
struct eccrypt_curve_t {
  bignum_digit_t a[ECCRYPT_BIGNUM_DIGITS]; /* коэффициенты уравнения     */
  bignum_digit_t b[ECCRYPT_BIGNUM_DIGITS]; /*     y^2 = x^3 + a*x + b    */
  bignum_digit_t m[ECCRYPT_BIGNUM_DIGITS]; /* в поле вычетов по модулю m */
  struct eccrypt_point_t g; /* генерирующая точка */
};

/* пара ключей */
struct eccrypt_keypair_t {
  bignum_digit_t priv[ECCRYPT_BIGNUM_DIGITS]; /* закрытый ключ */
  struct eccrypt_point_t pub; /* открытый ключ */
};

/* копирование точки */
void eccrypt_point_cpy(struct eccrypt_point_t* to, /* куда копируем */
                       struct eccrypt_point_t* from); /* откуда */

/* сложение точек эллиптической кривой */
void eccrypt_point_add(struct eccrypt_point_t* rslt, /* сумма */
                       struct eccrypt_point_t* p, /* первое слогаемое */
                       struct eccrypt_point_t* q, /* второе слогаемое */
                       struct eccrypt_curve_t* curve); /* параметры кривой */

/* умножение точек эллиптической кривой */
void eccrypt_point_mul(struct eccrypt_point_t* rslt, /* результат */
                       struct eccrypt_point_t* p, /* точка */
                       bignum_digit_t* k, /* множитель */
                       struct eccrypt_curve_t* curve); /* параметры кривой */
