#!/bin/bash

set -e
set -x

JEV_GMP=gmp-6.2.1
JEV_MPFR=mpfr-4.2.0
JEV_MPC=mpc-1.3.1
JEV_GCC=gcc-13.1.0
JEV_NEWLIB=newlib-4.3.0.20230120
JEV_BINUTILS=binutils-2.40
JEV_GDB=gdb-13.2
JEV_ISL=isl-0.26
JEV_PYTHON=3.11.4

JEV_XTOOL_PREFIX=/opt/x-tools/lm32-elf

if [[ "${OS}" == "Windows_NT" ]]; then
    echo "Windows not supported yet" 1>&2
    exit 1
else
    UNAME_S=$(uname -s)
    if [[ "${UNAME_S}" == "Darwin" ]]; then
        if type brew &>/dev/null; then
            brew install openssl readline sqlite3 xz zlib pkg-config
            JEV_BREW_ROOT=$(brew --prefix)
            export PATH=${JEV_BREW_ROOT}/bin:${PATH}
            export PKG_CONFIG_PATH=${JEV_BREW_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}
            export LDFLAGS="-L${JEV_BREW_ROOT}/lib ${LDFLAGS}"
            export CPPFLAGS="-I${JEV_BREW_ROOT}/include ${CPPFLAGS}"
        else
            echo "Windows not supported yet" 1>&2
            exit 1
        fi
    fi
fi

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
export PKG_CONFIG_PATH=${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
export LDFLAGS="-L${JEV_XTOOL_PREFIX}/lib ${LDFLAGS}"
export CPPFLAGS="-I${JEV_XTOOL_PREFIX}/include ${CPPFLAGS}"
export CFLAGS="${CPPFLAGS} -Wno-error"
export CXXFLAGS="${CPPFLAGS} -Wno-error"
export CFLAGS_FOR_TARGET="-DPREFER_SIZE_OVER_SPEED=1 -mbarrel-shift-enabled -mmultiply-enabled -mdivide-enabled -msign-extend-enabled -Oz -g -ffunction-sections -fdata-sections"
export CXXFLAGS_FOR_TARGET="${CFLAGS_FOR_TARGET}"

JEV_GNU_MIRROR=https://ftp.gnu.org

NUM_CORES=$(nproc)

# gmp
wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
rm -rf ${JEV_GMP} build-gmp
tar xf ${JEV_GMP}.tar.xz
mkdir -p build-gmp
pushd build-gmp
../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j "${NUM_CORES}" install
popd

# mpfr
wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
rm -rf ${JEV_MPFR} build-mfr
tar xf ${JEV_MPFR}.tar.xz
mkdir -p build-mpfr
pushd build-mpfr
../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j "${NUM_CORES}" install
popd

# mpc
wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
rm -rf ${JEV_MPC} build-mpc
tar xf ${JEV_MPC}.tar.gz
mkdir -p build-mpc
pushd build-mpc
../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j "${NUM_CORES}" install
popd

# isl
wget -N https://libisl.sourceforge.io/${JEV_ISL}.tar.xz
rm -rf ${JEV_ISL} build-isl
tar xf ${JEV_ISL}.tar.xz
mkdir -p build-isl
pushd build-isl
../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j "${NUM_CORES}" install
popd

# python
wget -N https://www.python.org/ftp/python/${JEV_PYTHON}/Python-${JEV_PYTHON}.tar.xz
rm -rf ${JEV_PYTHON} build-python
tar xf Python-${JEV_PYTHON}.tar.xz
mkdir -p build-python
pushd build-python
../Python-${JEV_PYTHON}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-shared
make -j "${NUM_CORES}" install
popd

# binutils
wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
rm -rf ${JEV_BINUTILS} build-binutils
tar xf ${JEV_BINUTILS}.tar.bz2
mkdir -p build-binutils
pushd build-binutils
../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-multilib --enable-languages=c,c++ --target=lm32-elf
make -j "${NUM_CORES}" all
make -j "${NUM_CORES}" install
popd

# newlib
wget -N http://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz
rm -rf ${JEV_NEWLIB} build-newlib
tar xf ${JEV_NEWLIB}.tar.gz

# gcc
wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
rm -rf ${JEV_GCC} build-gcc
tar xf ${JEV_GCC}.tar.xz

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-shared --disable-multilib --disable-threads --disable-tls --enable-languages=c,c++ --target=lm32-elf --without-headers --with-newlib --with-gnu-as --with-gnu-ld --enable-target-optspace --enable-cxx-flags='-Oz -ffunction-sections -fdata-sections'
make -j "${NUM_CORES}" all-gcc
make install-gcc
popd

mkdir -p build-newlib
pushd build-newlib
../${JEV_NEWLIB}/configure --disable-shared --disable-multilib --enable-target-optspace --target=lm32-elf --prefix=${JEV_XTOOL_PREFIX}
make -j "${NUM_CORES}" all
make install
popd

pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-shared --disable-multilib --disable-threads --disable-tls --enable-languages=c,c++ --target=lm32-elf --with-newlib --with-gnu-as --with-gnu-ld --enable-target-optspace --enable-cxx-flags='-Oz -ffunction-sections -fdata-sections'
make -j "${NUM_CORES}" all
make install
popd


# gdb
wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
rm -rf ${JEV_GDB} build-gdb
tar xf ${JEV_GDB}.tar.xz
mkdir -p build-gdb
pushd build-gdb
../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --target=lm32-elf
make -j "${NUM_CORES}" all
make -j "${NUM_CORES}" install
popd
