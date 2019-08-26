#!/bin/bash

set -e

GMP=gmp-6.1.2
MPFR=mpfr-4.0.2
MPC=mpc-1.1.0
GCC=gcc-9.1.0
NEWLIB=newlib-3.1.0
BINUTILS=binutils-2.32
GDB=gdb-8.3

GNU_MIRROR=https://ftp.gnu.org
#GNU_MIRROR=http://mirror.internode.on.net/pub

# gmp
wget -N $GNU_MIRROR/gnu/gmp/${GMP}.tar.xz
tar xf ${GMP}.tar.xz

# mpfr
wget -N $GNU_MIRROR/gnu/mpfr/${MPFR}.tar.xz
tar xf ${MPFR}.tar.xz

# mpc
wget -N $GNU_MIRROR/gnu/mpc/${MPC}.tar.gz
tar xf ${MPC}.tar.gz

# gcc

wget -N $GNU_MIRROR/gnu/gcc/${GCC}/${GCC}.tar.xz
tar xf ${GCC}.tar.xz

# newlib
wget -N ftp://sourceware.org/pub/newlib/${NEWLIB}.tar.gz
tar xf ${NEWLIB}.tar.gz

# binutils
wget -N $GNU_MIRROR/gnu/binutils/${BINUTILS}.tar.bz2
tar xf ${BINUTILS}.tar.bz2

# gdb
wget -N $GNU_MIRROR/gnu/gdb/${GDB}.tar.xz
tar xf ${GDB}.tar.xz

cd ${GCC}
ln -s ../${BINUTILS}/bfd
ln -s ../${BINUTILS}/binutils
ln -s ../${BINUTILS}/gas
ln -s ../${BINUTILS}/gold
ln -s ../${BINUTILS}/gprof
ln -s ../${BINUTILS}/opcodes
ln -s ../${BINUTILS}/ld

ln -s ../${NEWLIB}/newlib
ln -s ../${NEWLIB}/libgloss

ln -s ../${GDB} gdb
ln -s ../${MPC} mpc
ln -s ../${MPFR} mpfr
ln -s ../${GMP} gmp

cd ..
mkdir -p build
cd build
../${GCC}/configure  --prefix=/opt/lm32 --enable-languages=c --target=lm32-elf
make -j8
