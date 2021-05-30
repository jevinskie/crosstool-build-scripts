#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -o xtrace

NUMJOBS=16

JEV_GMP=gmp-6.2.1
JEV_MPFR=mpfr-4.1.0
JEV_MPC=mpc-1.2.1
# JEV_GCC=gcc-10.2.0
JEV_GCC=gcc-git
JEV_NEWLIB=newlib-4.1.0
JEV_BINUTILS=binutils-2.36.1
JEV_GDB=gdb-10.2
JEV_ISL=isl-0.24

JEV_XTOOL_PREFIX=/opt/aarch64/aarch64-elf-gcc-12-git-lto

BROOT=`brew --prefix`

# brew install zlib libusb libusb-compat zstd xz libftdi gettext boost source-highlight libedit expat ncurses

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
export PKG_CONFIG_PATH=${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}:${BROOT}/opt/zlib/lib/pkgconfig:${BROOT}/opt/libusb/lib/pkgconfig:${BROOT}/opt/libusb-compat/lib/pkgconfig:${BROOT}/opt/zstd/lib/pkgconfig:${BROOT}/opt/xz/lib/pkgconfig:${BROOT}/opt/libftdi/lib/pkgconfig:${BROOT}/opt/gettext/lib/pkgconfig:${BROOT}/opt/boost/lib/pkgconfig:${BROOT}/opt/source-highlight/lib/pkgconfig:${BROOT}/opt/libedit/lib/pkgconfig:${BROOT}/opt/expat/lib/pkgconfig:${BROOT}/opt/ncurses/lib/pkgconfig:${BROOT}/lib/pkgconfig
export LDFLAGS=-L${JEV_XTOOL_PREFIX}/lib
export CPPFLAGS=-I${JEV_XTOOL_PREFIX}/include
export CFLAGS=${CPPFLAGS}
export CXXFLAGS=${CPPFLAGS}
export LDFLAGS_FOR_TARGET="-flto -fuse-linker-plugin -ffat-lto-objects"
export CFLAGS_FOR_TARGET="${LDFLAGS_FOR_TARGET} -DPREFER_SIZE_OVER_SPEED=1 -Os -g -ffunction-sections -fdata-sections"
export LIBCFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export CXXFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export LIBCXXFLAGS_FOR_TARGET=${CXXFLAGS_FOR_TARGET}

JEV_GNU_MIRROR=https://ftp.gnu.org

mkdir -p ${JEV_XTOOL_PREFIX}

# gmp
wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
rm -rf ${JEV_GMP} build-gmp
tar xf ${JEV_GMP}.tar.xz
mkdir -p build-gmp
pushd build-gmp
../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd

# mpfr
wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
rm -rf ${JEV_MPFR} build-mfr
tar xf ${JEV_MPFR}.tar.xz
mkdir -p build-mpfr
pushd build-mpfr
../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd

# mpc
wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
rm -rf ${JEV_MPC} build-mpc
tar xf ${JEV_MPC}.tar.gz
mkdir -p build-mpc
pushd build-mpc
../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd

# isl
wget -N http://isl.gforge.inria.fr/${JEV_ISL}.tar.xz
rm -rf ${JEV_ISL} build-isl
tar xf ${JEV_ISL}.tar.xz
mkdir -p build-isl
pushd build-isl
../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd

# binutils
wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
rm -rf ${JEV_BINUTILS} build-binutils
tar xf ${JEV_BINUTILS}.tar.bz2
mkdir -p build-binutils
pushd build-binutils
../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-multiarch --enable-sysroot --enable-plugin --target=aarch64-none-elf
make -j${NUMJOBS} all
make -j${NUMJOBS} install
popd

# newlib unpack
wget -N http://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz
rm -rf ${JEV_NEWLIB} build-newlib
tar xf ${JEV_NEWLIB}.tar.gz

# gcc
# wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
# rm -rf ${JEV_GCC} build-gcc
# tar xf ${JEV_GCC}.tar.xz
rm -rf build-gcc

# pushd ${JEV_GCC}
# patch -p 0 < ../gcc-10-aarch64-cxx11-build-fix.patch
# popd

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-multiarch --enable-multilib --enable-sysroot --enable-plugin --target=aarch64-none-elf --without-headers --with-newlib --with-gnu-as --with-gnu-ld
make -j${NUMJOBS} all-gcc
make install-gcc
popd

# newlib build
mkdir -p build-newlib
pushd build-newlib
../${JEV_NEWLIB}/configure --target=aarch64-none-elf --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} all
make install
popd

# gcc final
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-multiarch --enable-multilib --enable-sysroot --enable-plugin --target=aarch64-none-elf --with-newlib --with-gnu-as --with-gnu-ld
make -j8 all
make install
popd

# gdb
wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
rm -rf ${JEV_GDB} build-gdb
tar xf ${JEV_GDB}.tar.xz

mkdir -p build-gdb
pushd build-gdb
../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --enable-multiarch --enable-multilib --enable-sysroot --enable-plugin --target=aarch64-none-elf
make -j${NUMJOBS} all
make -j${NUMJOBS} install
popd

