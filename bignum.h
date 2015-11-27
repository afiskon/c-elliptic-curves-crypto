/*
 *  (c) Alexandr A Alexeev 2010 | http://eax.me/
 */

/* TODO: как скажется различная оптимизация на скорости работы программы?
оптимизировать умножение, реализовать mul2 с помощью побитовых сдвигов,
написать возведение в квадрат */

/* беззнаковое целое, используемое для хранения одного разряда числа
для 32-х разрядных машин - unsiged short, для 64-х разрядных - unsigned int */
typedef unsigned short bignum_digit_t;

/* беззнаковое целое, имеющее в два раза больше бит, чем bignum_digit_t
для 32-х разрядных машин - unsiged int, для 64-х разрядных - unsigned long */
typedef unsigned int bignum_double_t;

/* беззнаковое целое, имеющее в два раза больше бит, чем bignum_digit_t
для 32-х разрядных машин - siged int, для 64-х разрядных - signed long */
typedef signed int bignum_signed_double_t;

/* кол-во бит в одном разряде числа */
#define BIGNUM_DIGIT_BITS (sizeof(bignum_digit_t) * 8)

/* маска для выделения разрядов числа */
#define BIGNUM_DIGIT_MASK (((bignum_double_t)1 << BIGNUM_DIGIT_BITS) - 1)

/* макрос, вычисляющий кол-во разрядов в числе по его размеру */
#define BIGNUM_DIGITS(x) (( x ) / sizeof(bignum_digit_t) )

/* макрос, вычисляющий размер числа по кол-ву разрядов в нем */
#define BIGNUM_SIZE(x) (( x ) * sizeof(bignum_digit_t) )

/* максимальный размер числа в байтах */
#define BIGNUM_MAX_SIZE 32

/* максимально допустимое кол-во разрядов в числе */
#define BIGNUM_MAX_DIGITS  (BIGNUM_MAX_SIZE / sizeof(bignum_digit_t))

/* преобразование числа в строку */
void bignum_tohex(bignum_digit_t* num, char* buff, int buffsize, int digits);

/* преобразование строки в число */
void bignum_fromhex(bignum_digit_t* num, char* str, int digits);

/* является ли число нулем */
int bignum_iszero(bignum_digit_t* num, int digits);

/* присвоить числу значение ноль */
void bignum_setzero(bignum_digit_t* num, int digits);

/* сравнение двух чисел: 0 => равны, 1 => a > b, -1 => a < b*/
int bignum_cmp(bignum_digit_t* a, bignum_digit_t* b, int digits);

/* скопировать число */
void bignum_cpy(bignum_digit_t* to, bignum_digit_t* from,
                int to_digits, int from_digits);

/* прибавить b к a. digits - кол-во разрядов в числах */
void bignum_add(bignum_digit_t* a, bignum_digit_t* b, int digits);

/* вычесть b из a. digits - кол-во разрядов в числах */
void bignum_sub(bignum_digit_t* a, bignum_digit_t* b, int digits);

/* умножить a на b */
void bignum_mul(bignum_digit_t* a, bignum_digit_t* b, int digits);

/* выполнить деление a на b, найти частное и (опционально) остаток.
детальное описание алгоритма приведено у Кнута, Уоррена и Вельшенбаха */
void bignum_div(bignum_digit_t* a, /* делимое */
                bignum_digit_t* b, /* делитель */
                bignum_digit_t* q, /* частное, может быть a, b или NULL */
                bignum_digit_t* r, /* частное, может быть a, b или NULL */
                int digits); /* кол-во разрядов в числах */

/* найти сумму a и b в поле вычетов по модулю m
использовать двойной размер буфера */
void bignum_madd(bignum_digit_t* a, bignum_digit_t* b,
                 bignum_digit_t* m, int digits);

/* найти разность a и b в поле вычетов по модулю m
использовать двойной размер буфера */
void bignum_msub(bignum_digit_t* a, bignum_digit_t* b,
                 bignum_digit_t* m, int digits);

/* найти произведение a на b в поле вычетов по модулю m
использовать двойной размер буфера */
void bignum_mmul(bignum_digit_t* a, bignum_digit_t* b,
                 bignum_digit_t* m, int digits);

/* найти элемент, обратный num в поле вычетов по модулю m */
void bignum_inv(bignum_digit_t* num, bignum_digit_t* m, int digits);

/* найти частное a и b в поле вычетов по модулю m
использовать двойной размер буфера */
void bignum_mdiv(bignum_digit_t* a, /* делимое */
                 bignum_digit_t* b, /* делитель */
                 bignum_digit_t* m, /* модуль */
                 int digits); /* кол-во разрядов в числах */
