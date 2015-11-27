/*
 *  (c) Alexandr A Alexeev 2010 | http://eax.me/
 */

#include <stdio.h>

int main() {
  #ifdef PRINT_THIS_NUMBER
    printf("PRINT_THIS_NUMBER == %d\n", PRINT_THIS_NUMBER);
  #endif

  printf("sizeof(long long) == %d\n",sizeof(long long)); /* 8 - x86, 8 - amd64 */
  printf("sizeof(long) == %d\n", sizeof(long)); /* 4 - x86, 8 - amd64*/
  printf("sizeof(int) == %d\n", sizeof(int)); /* 4 - x86, 4 - amd64 */
  printf("sizeof(short) == %d\n", sizeof(short)); /* 2 - x86, 2 - amd64 */
  printf("sizeof(char) == %d\n", sizeof(char)); /* 1 - x86, 1 - amd64 */
  return 0;
}
