#include <cstdio>

extern "C" void _Unwind_Backtrace(void);

int main(void) {
  printf("Hello, world! _Unwind_Backtrace: %p\n", reinterpret_cast<void *>(_Unwind_Backtrace));
}

