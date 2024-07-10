#include <stdint.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>

extern void _Unwind_Backtrace(void);

volatile int foo;

#ifdef NULTERM
typedef char ptr_hex_str_buf[2 + sizeof(uintptr_t) * 2 + 1];
#else
typedef char ptr_hex_str_buf[2 + sizeof(uintptr_t) * 2];
#endif

__attribute__((always_inline)) static inline char nibble_to_ascii_hex(const uint8_t chr) {
    if (chr <= 9) {
        return chr + '0';
    } else if (chr >= 0xA && chr <= 0xF) {
        return chr - 0xA + 'a';
    } else {
        __builtin_unreachable();
    }
}

__attribute__((always_inline)) static inline void byte_to_ascii_hex(uint8_t n, char *hex) {
    hex[0] = nibble_to_ascii_hex(n >> 4);
    hex[1] = nibble_to_ascii_hex(n & 0xF);
}

__attribute__((noinline)) static void ptr_to_hex_str(void *ptr, char *hex) {
    uintptr_t p = (uintptr_t)ptr;
    hex[0]      = '0';
    hex[1]      = 'x';
    for (size_t i = 0; i < sizeof(p); ++i) {
        byte_to_ascii_hex((uint8_t)p, &hex[2 + ((sizeof(p) - i - 1) * 2)]);
        p >>= 8;
    }
}

#ifdef NULTERM
__attribute__((noinline)) static void my_strnfill(char *str, char c, size_t sz) {
    for (size_t i = 0; i < sz; ++i) {
        str[i] = c;
    }
}
#endif

__attribute__((noinline)) static void write_syscall_x64(int fd, const void *buf, size_t count) {
    int sys_result;
    register const int _fd __asm("edi")       = fd;
    register const void *_buf __asm("rsi")    = buf;
    register const size_t _count __asm("rdx") = count;
    register int _sc_num __asm("rax")         = __NR_write;
    __asm __volatile("syscall"
                     : "=a"(sys_result)
                     : "r"(_sc_num), "r"(_fd), "r"(_buf), "r"(_count)
                     : "cc", "rcx", "r11", "memory");
}

#ifdef NO_MAIN
__attribute__((noinline, noreturn)) static void exit_syscall_x64(int res) {
    int sys_result;
    register const int _res __asm("edi") = res;
    register int _sc_num __asm("rax")    = __NR_exit;
    __asm __volatile("syscall"
                     : "=a"(sys_result)
                     : "r"(_sc_num), "r"(_res)
                     : "cc", "rcx", "r11", "memory");
}
#endif

static const char uw_bt_prefix_str[] = "_Unwind_Backtrace: ";
static const char newline_str[]      = "\n";

#ifdef NO_MAIN
#define main _start
#endif

#ifdef NO_MAIN
__attribute__((noreturn)) void
#else
int
#endif
main(void) {
    int res;
    uintptr_t pu = (uintptr_t)_Unwind_Backtrace;
    ptr_hex_str_buf pbuf;
#ifdef NULTERM
    my_strnfill(pbuf, ' ', sizeof(pbuf));
    pbuf[sizeof(pbuf) - 1] = '\0';
#endif
    ptr_to_hex_str((void *)pu, pbuf);
    write_syscall_x64(STDERR_FILENO, uw_bt_prefix_str, sizeof(uw_bt_prefix_str) - 1);
    write_syscall_x64(STDERR_FILENO, pbuf, sizeof(pbuf));
    write_syscall_x64(STDERR_FILENO, newline_str, sizeof(newline_str) - 1);
    res = (int)((uint32_t)(pu >> 32) ^ (uint32_t)(pu & UINT32_MAX));
    foo = res;
#ifndef NO_MAIN
    return res;
#else
    exit_syscall_x64(res);
#endif
}
