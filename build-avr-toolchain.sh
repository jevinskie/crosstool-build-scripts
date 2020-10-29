#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -o xtrace

JEV_GMP=gmp-6.2.0
JEV_MPFR=mpfr-4.1.0
JEV_MPC=mpc-1.2.0
JEV_GCC=gcc-10.2.0
JEV_AVRLIBC=avr-libc-2.0.0
JEV_AVRDUDE=avrdude-6.3
JEV_BINUTILS=binutils-2.35.1
JEV_GDB=gdb-9.2
JEV_ISL=isl-0.22.1

JEV_XTOOL_PREFIX=/opt/avr/avr-gcc-10.2-lto

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
export PKG_CONFIG_PATH=${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}:`brew --prefix`/lib/pkgconfig
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
make -j8 install
popd

# mpfr
wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
rm -rf ${JEV_MPFR} build-mfr
tar xf ${JEV_MPFR}.tar.xz
mkdir -p build-mpfr
pushd build-mpfr
../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 install
popd

# mpc
wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
rm -rf ${JEV_MPC} build-mpc
tar xf ${JEV_MPC}.tar.gz
mkdir -p build-mpc
pushd build-mpc
../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 install
popd

# isl
wget -N http://isl.gforge.inria.fr/${JEV_ISL}.tar.xz
rm -rf ${JEV_ISL} build-isl
tar xf ${JEV_ISL}.tar.xz
mkdir -p build-isl
pushd build-isl
../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 install
popd

# binutils
wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
rm -rf ${JEV_BINUTILS} build-binutils
tar xf ${JEV_BINUTILS}.tar.bz2
pushd ${JEV_BINUTILS}
patch -p 1 < ../binutils-2.35.1-avr-size.patch
popd
mkdir -p build-binutils
pushd build-binutils
../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --target=avr
make -j8 all
make -j8 install
popd

# avr-libc
wget -N http://download.savannah.gnu.org/releases/avr-libc/${JEV_AVRLIBC}.tar.bz2
rm -rf ${JEV_AVRLIBC} build-avr-libc
tar xf ${JEV_AVRLIBC}.tar.bz2


# gcc
wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
rm -rf ${JEV_GCC} build-gcc
tar xf ${JEV_GCC}.tar.xz

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-plugin --target=avr
make -j8 all
make install
popd

# avr-libc
mkdir -p build-avr-libc
pushd build-avr-libc
../${JEV_AVRLIBC}/configure --host=avr --build=x86_64-apple-darwin18.7.0 --prefix=${JEV_XTOOL_PREFIX} --with-debug-info=dwarf-4
make -j8 all
make install
popd

# gdb
wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
rm -rf ${JEV_GDB} build-gdb
tar xf ${JEV_GDB}.tar.xz
mkdir -p build-gdb
pushd build-gdb
../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --target=avr
make -j8 all
make -j8 install
popd

# avrdude
wget -N http://download.savannah.gnu.org/releases/avrdude/${JEV_AVRDUDE}.tar.gz
rm -rf ${JEV_AVRDUDE} build-avrdude
tar xf ${JEV_AVRDUDE}.tar.gz
mkdir -p build-avrdude
pushd build-avrdude
../${JEV_AVRDUDE}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j8 all
make -j8 install
popd
