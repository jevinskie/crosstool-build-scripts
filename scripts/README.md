# Notes

```shell
/opt/gcc/gcc-15-bare/bin/gcc -o standalone-main.s -S -masm=intel standalone.c -Wextra -Wall -Wpedantic -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -Oz -fno-ipa-cp
/opt/gcc/gcc-15-bare/bin/gcc -o standalone-start.s -S -masm=intel standalone.c -Wextra -Wall -Wpedantic -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -Oz -fno-ipa-cp -DNO_MAIN

/opt/gcc/gcc-15-bare/bin/gcc -o standalone-main standalone.c -specs custom.specs -Wextra -Wall -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -Oz -fno-ipa-cp
/opt/gcc/gcc-15-bare/bin/gcc -o standalone-start standalone.c -specs custom.specs -Wextra -Wall -Wpedantic -ggdb3 -Oz -fno-ipa-cp -DNO_MAIN -nostartfiles -nolibc
# ERROR no backtrace symbol
/opt/gcc/gcc-15-bare/bin/gcc -o standalone-start standalone.c -specs custom.specs -Wextra -Wall -Wpedantic -ggdb3 -Oz -fno-ipa-cp -DNO_MAIN -nostartfiles -nostdlib
# ERROR no backtrace symbol
/opt/gcc/gcc-15-bare/bin/gcc -o standalone-start standalone.c -specs custom.specs -Wextra -Wall -Wpedantic -ggdb3 -Oz -fno-ipa-cp -DNO_MAIN -nostartfiles -nostdlib -shared-libgcc

```
