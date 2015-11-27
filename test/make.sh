#!/bin/sh
gcc bignum-test.c ../bignum.c -o bignum-test
gcc eccrypt-test.c ../bignum.c ../eccrypt.c -o eccrypt-test
