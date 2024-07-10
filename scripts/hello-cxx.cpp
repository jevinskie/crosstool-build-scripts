#include <cstdio>
#include <string>
extern "C" void _Unwind_Backtrace(void);

int main(int argc, const char **argv) {
    printf("Hello, world! %s _Unwind_Backtrace: %p\n", std::string(argv[0]).c_str(),
           reinterpret_cast<void *>(_Unwind_Backtrace));
}
