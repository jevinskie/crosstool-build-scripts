#include <stdio.h>

extern void _Unwind_Backtrace(void);

extern int fourty_two;
extern int fourty_two_minus_two(void);

int main(void) {
    printf("Hello, world! _Unwind_Backtrace: %p\n", (void *)_Unwind_Backtrace);
    printf("fourty_two: %d\n", fourty_two);
    printf("fourty_two_minus_two() = %d\n", fourty_two_minus_two());
    return 0;
}
