#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

set -o xtrace

NUMJOBS=8

JEV_GMP=gmp-6.2.1
JEV_MPFR=mpfr-4.1.0
JEV_MPC=mpc-1.2.1
# JEV_GCC=gcc-10.2.0
JEV_GCC=gcc-git
# JEV_NEWLIB=newlib-4.1.0
JEV_NEWLIB=newlib-git
# JEV_BINUTILS=binutils-2.36.1
JEV_BINUTILS=binutils-git
# JEV_GDB=gdb-10.2
JEV_GDB=binutils-git/gdb
# stupid site is down
JEV_ISL=isl-0.24

JEV_XTOOL_PREFIX=/opt/aarch64/aarch64-elf-gcc-12-git-lto-2021-11-21
unset GREP_OPTIONS

BROOT=`brew --prefix`

# brew install zlib libusb libusb-compat zstd xz libftdi gettext boost source-highlight libedit expat ncurses
# brew install coreutils gsed make findutils gnu-tar gnu-which

# export PATH=${BROOT}/opt/coreutils/libexec/gnubin:${BROOT}/opt/gsed/libexec/gnubin:${BROOT}/opt/make/libexec/gnubin:${BROOT}/opt/findutils/libexec/gnubin:${BROOT}/opt/gnu-tar/libexec/gnubin:${BROOT}/opt/gnu-which/libexec/gnubin:${PATH}

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
export PKG_CONFIG_PATH=${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}:${BROOT}/opt/zlib/lib/pkgconfig:${BROOT}/opt/libusb/lib/pkgconfig:${BROOT}/opt/libusb-compat/lib/pkgconfig:${BROOT}/opt/zstd/lib/pkgconfig:${BROOT}/opt/xz/lib/pkgconfig:${BROOT}/opt/libftdi/lib/pkgconfig:${BROOT}/opt/gettext/lib/pkgconfig:${BROOT}/opt/boost/lib/pkgconfig:${BROOT}/opt/source-highlight/lib/pkgconfig:${BROOT}/opt/libedit/lib/pkgconfig:${BROOT}/opt/expat/lib/pkgconfig:${BROOT}/opt/ncurses/lib/pkgconfig:${BROOT}/lib/pkgconfig
# export LDFLAGS=-L${JEV_XTOOL_PREFIX}/lib
export LDFLAGS="-L${JEV_XTOOL_PREFIX}/lib -Wl,-rpath,${JEV_XTOOL_PREFIX}/lib"
export CPPFLAGS=-I${JEV_XTOOL_PREFIX}/include
export CFLAGS="${CPPFLAGS} -Wno-error"
export CXXFLAGS="${CPPFLAGS} -Wno-error"
export LDFLAGS_FOR_TARGET="-flto -fuse-linker-plugin -ffat-lto-objects"
export CFLAGS_FOR_TARGET="${LDFLAGS_FOR_TARGET} -DPREFER_SIZE_OVER_SPEED=1 -Os -ggdb3 -ffunction-sections -fdata-sections"
export LIBCFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export CXXFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export LIBCXXFLAGS_FOR_TARGET=${CXXFLAGS_FOR_TARGET}

JEV_GNU_MIRROR=https://ftp.gnu.org

mkdir -p ${JEV_XTOOL_PREFIX}

# gmp
# wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
# rm -rf ${JEV_GMP} build-gmp
# tar xf ${JEV_GMP}.tar.xz
# mkdir -p build-gmp
# pushd build-gmp
# ../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# mpfr
# wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
# rm -rf ${JEV_MPFR} build-mpfr
# tar xf ${JEV_MPFR}.tar.xz
# mkdir -p build-mpfr
# pushd build-mpfr
# ../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# mpc
# wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
# rm -rf ${JEV_MPC} build-mpc
# tar xf ${JEV_MPC}.tar.gz
# mkdir -p build-mpc
# pushd build-mpc
# ../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# isl
# rm -rf  build-isl
# # wget -N http://isl.gforge.inria.fr/${JEV_ISL}.tar.xz
# rm -rf ${JEV_ISL}
# tar xf ${JEV_ISL}.tar.xz
# mkdir -p build-isl
# pushd build-isl
# ../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# binutils
# rm -rf build-binutils
# # wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
# # rm -rf ${JEV_BINUTILS}
# # tar xf ${JEV_BINUTILS}.tar.bz2
# mkdir -p build-binutils
# pushd build-binutils
# ../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-multiarch --enable-sysroot --enable-sysroot --enable-plugin --target=aarch64-linux-gnu
# make -j${NUMJOBS} all
# make -j${NUMJOBS} install
# popd

# # newlib unpack
# # wget -N http://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz
# # rm -rf ${JEV_NEWLIB}
# # tar xf ${JEV_NEWLIB}.tar.gz
rm -rf build-newlib

# # gcc
# # wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
# # rm -rf ${JEV_GCC} build-gcc
# # tar xf ${JEV_GCC}.tar.xz
rm -rf build-gcc

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --with-mpc=${JEV_XTOOL_PREFIX} --with-mpfr=${JEV_XTOOL_PREFIX} --with-gmp=${JEV_XTOOL_PREFIX} --with-isl=${JEV_XTOOL_PREFIX} --disable-gcov --enable-languages=c,c++ --disable-nls --enable-multiarch --enable-sysroot --enable-sysroot --enable-plugin --target=aarch64-linux-gnu --without-headers --with-newlib --with-gnu-as --with-gnu-ld
make -j${NUMJOBS} all-host
make install-host
popd

# # newlib build
mkdir -p build-newlib
pushd build-newlib
../${JEV_NEWLIB}/configure --target=aarch64-linux-gnu --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} all
make install
popd

# # gcc final
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --with-mpc=${JEV_XTOOL_PREFIX} --with-mpfr=${JEV_XTOOL_PREFIX} --with-gmp=${JEV_XTOOL_PREFIX} --with-isl=${JEV_XTOOL_PREFIX} --disable-gcov --enable-languages=c,c++ --disable-nls --enable-multiarch --enable-sysroot --enable-sysroot --enable-plugin --target=aarch64-linux-gnu --with-newlib --with-gnu-as --with-gnu-ld
make -j8 all
make install
popd

# gdb
# handled by binutils-git

# # wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
# # rm -rf ${JEV_GDB}
# rm -rf build-gdb
# # tar xf ${JEV_GDB}.tar.xz

# mkdir -p build-gdb
# pushd build-gdb
# ../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --enable-multiarch --enable-multilib --enable-sysroot --enable-plugin --target=aarch64-linux-gnu --enable-targets=all
# make -j${NUMJOBS} all
# make -j${NUMJOBS} install
# popd

