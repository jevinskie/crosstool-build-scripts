#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -o xtrace

NUMJOBS=16

JEV_GMP=gmp-6.2.1
JEV_MPFR=mpfr-4.1.0
JEV_MPC=mpc-1.2.1
# JEV_GCC=gcc-10.3.0
JEV_GCC=gcc-git
# JEV_NEWLIB=newlib-4.1.0
JEV_NEWLIB=newlib-git
JEV_BINUTILS=binutils-2.36.1
# JEV_GDB=gdb-10.1
# JEV_GDB=gdb-git
JEV_GDB=binutils-gdb-git
JEV_ISL=isl-0.23

JEV_XTOOL_PREFIX=/opt/arm/arm-none-eabi-gcc-11-git-lto

BROOT=`brew --prefix`

# brew install zlib libusb libusb-compat zstd xz libftdi gettext boost source-highlight libedit expat ncurses libelf expat xxhash

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
export PKG_CONFIG_PATH=${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}:${BROOT}/opt/zlib/lib/pkgconfig:${BROOT}/opt/libusb/lib/pkgconfig:${BROOT}/opt/libusb-compat/lib/pkgconfig:${BROOT}/opt/zstd/lib/pkgconfig:${BROOT}/opt/xz/lib/pkgconfig:${BROOT}/opt/libftdi/lib/pkgconfig:${BROOT}/opt/gettext/lib/pkgconfig:${BROOT}/opt/boost/lib/pkgconfig:${BROOT}/opt/source-highlight/lib/pkgconfig:${BROOT}/opt/libedit/lib/pkgconfig:${BROOT}/opt/expat/lib/pkgconfig:${BROOT}/opt/ncurses/lib/pkgconfig:${BROOT}/opt/libelf/lib/pkgconfig:${BROOT}/opt/expat/lib/pkgconfig:${BROOT}/lib/pkgconfig
export LDFLAGS=-L${JEV_XTOOL_PREFIX}/lib
export CPPFLAGS=-I${JEV_XTOOL_PREFIX}/include
export CFLAGS=${CPPFLAGS}
export CXXFLAGS=${CPPFLAGS}
export LDFLAGS_FOR_TARGET="-flto -fuse-linker-plugin -ffat-lto-objects"
export CFLAGS_FOR_TARGET="${LDFLAGS_FOR_TARGET} -DPREFER_SIZE_OVER_SPEED=1 -Os -g -ffunction-sections -fdata-sections"
export LIBCFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export CXXFLAGS_FOR_TARGET="${CFLAGS_FOR_TARGET} -fno-exceptions"
export LIBCXXFLAGS_FOR_TARGET="${CXXFLAGS_FOR_TARGET} -fno-exceptions"

JEV_GNU_MIRROR=https://ftp.gnu.org

mkdir -p ${JEV_XTOOL_PREFIX}

# gmp
# wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
# rm -rf build-gmp
# rm -rf ${JEV_GMP}
# tar xf ${JEV_GMP}.tar.xz
# mkdir -p build-gmp
# pushd build-gmp
# ../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# mpfr
# wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
# rm -rf build-mpfr
# rm -rf ${JEV_MPFR}
# tar xf ${JEV_MPFR}.tar.xz
# mkdir -p build-mpfr
# pushd build-mpfr
# ../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# mpc
# wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
# rm -rf build-mpc
# rm -rf ${JEV_MPC}
# tar xf ${JEV_MPC}.tar.gz
# mkdir -p build-mpc
# pushd build-mpc
# ../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# isl
# wget -N http://isl.gforge.inria.fr/${JEV_ISL}.tar.xz
# rm -rf build-isl
# rm -rf ${JEV_ISL}
# tar xf ${JEV_ISL}.tar.xz
# mkdir -p build-isl
# pushd build-isl
# ../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd

# binutils
# wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
# rm -rf build-binutils
# rm -rf ${JEV_BINUTILS}
# tar xf ${JEV_BINUTILS}.tar.bz2
# mkdir -p build-binutils
# pushd build-binutils
# ../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-nls --enable-sysroot --enable-plugin --enable-interwork --target=arm-none-eabi
# make -j${NUMJOBS} all
# make -j${NUMJOBS} install
# popd

# newlib unpack
# wget -N http://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz
# rm -rf build-newlib build-newlib-nano
# rm -rf ${JEV_NEWLIB}
# tar xf ${JEV_NEWLIB}.tar.gz

# gcc
# wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
# rm -rf build-gcc
# rm -rf ${JEV_GCC}
# tar xf ${JEV_GCC}.tar.xz

# mkdir -p build-gcc
# pushd build-gcc
# ../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-multilib --enable-sysroot --enable-plugin --without-headers --with-newlib --with-gnu-as --with-gnu-ld --target=arm-none-eabi --with-multilib-list=rmprofile
# make -j${NUMJOBS} all-gcc
# make install-gcc
# popd

# newlib build
# mkdir -p build-newlib
# pushd build-newlib
# ../${JEV_NEWLIB}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-nls --enable-newlib-io-long-long --enable-newlib-io-c99-formats --enable-newlib-reent-check-verify --enable-newlib-register-fini --enable-newlib-retargetable-locking --disable-newlib-supplied-syscalls --target=arm-none-eabi
# make -j${NUMJOBS} all
# make install
# popd

# newlib-nano build
# mkdir -p build-newlib-nano
# pushd build-newlib-nano
# ../${JEV_NEWLIB}/configure --prefix=$PWD/target-libs --disable-nls --disable-newlib-supplied-syscalls --enable-newlib-reent-check-verify --enable-newlib-reent-small --enable-newlib-retargetable-locking --disable-newlib-fvwrite-in-streamio --disable-newlib-fseek-optimization --disable-newlib-wide-orient --enable-newlib-nano-malloc --disable-newlib-unbuf-stream-opt --enable-lite-exit --enable-newlib-global-atexit --enable-newlib-nano-formatted-io --target=arm-none-eabi
# make -j${NUMJOBS} all
# make install
# popd

# gcc final
# pushd build-gcc
# ../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --disable-nls --enable-multilib --enable-sysroot --enable-plugin --with-newlib --with-headers=yes --with-gnu-as --with-gnu-ld --target=arm-none-eabi --with-multilib-list=rmprofile
# make -j8 all INHIBIT_LIBC_CFLAGS="-DUSE_TM_CLONE_REGISTRY=0"
# make install
# popd

# copy newlib-nano
# mkdir -p ${JEV_XTOOL_PREFIX}/arm-none-eabi/include/newlib-nano
# cp -f build-newlib-nano/target-libs/arm-none-eabi/include/newlib.h \
#           ${JEV_XTOOL_PREFIX}/arm-none-eabi/include/newlib-nano/newlib.h

# gdb
# wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
# rm -rf ${JEV_GDB}
rm -rf build-gdb
# tar xf ${JEV_GDB}.tar.xz

# pushd ${JEV_GDB}
# patch -p 1 < ../gdb-bigsur-string-include.patch
# popd

mkdir -p build-gdb
pushd build-gdb
../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-binutils --disable-ld --disable-gold --disable-gas --disable-sim --disable-gprof --enable-werror=no --enable-languages=c,c++ --enable-multilib --enable-sysroot --enable-plugin --with-lzma=no --with-libexpat=yes --target=arm-none-eabi
make -j${NUMJOBS} all
make -j${NUMJOBS} install
popd

