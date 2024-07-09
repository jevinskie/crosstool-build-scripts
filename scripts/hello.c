#include <stdio.h>

extern void _Unwind_Backtrace(void);

int main(void) {
  printf("Hello, world! _Unwind_Backtrace: %p\n", (void *)_Unwind_Backtrace);
  return 0;
}

