#!/bin/bash

set -e

JEV_GMP=gmp-6.2.0
JEV_MPFR=mpfr-4.0.2
JEV_MPC=mpc-1.1.0
JEV_GCC=gcc-9.3.0
JEV_NEWLIB=newlib-3.3.0
JEV_BINUTILS=binutils-2.34
JEV_GDB=gdb-9.1

JEV_XTOOL_PREFIX=/opt/lm32

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
export PKG_CONFIG_PATH=${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
export LDFLAGS=-L${JEV_XTOOL_PREFIX}/lib
export CPPFLAGS=-I${JEV_XTOOL_PREFIX}/include
export CFLAGS=${CPPFLAGS}
export CXXFLAGS=${CPPFLAGS}

JEV_GNU_MIRROR=https://ftp.gnu.org
#GNU_MIRROR=http://mirror.internode.on.net/pub

# gmp
# wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
rm -rf ${JEV_GMP} build-gmp
tar xf ${JEV_GMP}.tar.xz
mkdir -p build-gmp
pushd build-gmp
../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 install
popd

# mpfr
# wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
rm -rf ${JEV_MPFR} build-mfr
tar xf ${JEV_MPFR}.tar.xz
mkdir -p build-mpfr
pushd build-mpfr
../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 install
popd

# mpc
# wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
rm -rf ${JEV_MPC} build-mpc
tar xf ${JEV_MPC}.tar.gz
mkdir -p build-mpc
pushd build-mpc
../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 install
popd

# binutils
# wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
rm -rf ${JEV_BINUTILS} build-binutils
tar xf ${JEV_BINUTILS}.tar.bz2
mkdir -p build-binutils
pushd build-binutils
../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=lm32-elf
make -j8 all
make -j8 install
popd

# newlib
# wget -N ftp://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz
rm -rf ${JEV_NEWLIB} build-newlib
tar xf ${JEV_NEWLIB}.tar.gz


# gcc
# wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
rm -rf ${JEV_GCC} build-gcc
tar xf ${JEV_GCC}.tar.xz
pushd ${JEV_GCC}
# ln -s ../${JEV_BINUTILS}/bfd
# ln -s ../${JEV_BINUTILS}/binutils
# ln -s ../${JEV_BINUTILS}/gas
# ln -s ../${JEV_BINUTILS}/gold
# ln -s ../${JEV_BINUTILS}/gprof
# ln -s ../${JEV_BINUTILS}/opcodes
# ln -s ../${JEV_BINUTILS}/ld
# ln -s ../${JEV_BINUTILS}/libctf

# ln -s ../${JEV_NEWLIB}/newlib
# ln -s ../${JEV_NEWLIB}/libgloss

# ln -s ../${JEV_GDB} gdb
# ln -s ../${JEV_MPC} mpc
# ln -s ../${JEV_MPFR} mpfr
# ln -s ../${JEV_GMP} gmp
popd

# mkdir -p build-gcc
# pushd build-gcc
# ../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=lm32-elf
# make -j8
# make -j8 install
# popd

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=lm32-elf --without-headers --with-newlib --with-gnu-as --with-gnu-ld
make -j8 all-gcc
make install-gcc
popd

mkdir -p build-newlib
pushd build-newlib
../${JEV_NEWLIB}/configure --target=lm32-elf --prefix=${JEV_XTOOL_PREFIX}
make -j8 all
make install
popd

pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=lm32-elf --with-newlib --with-gnu-as --with-gnu-ld
make -j8 all
make install
popd


# gdb
# wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
rm -rf ${JEV_GDB} build-gdb
tar xf ${JEV_GDB}.tar.xz
mkdir -p build-gdb
pushd build-gdb
../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=lm32-elf
make -j8 all
make -j8 install
popd
