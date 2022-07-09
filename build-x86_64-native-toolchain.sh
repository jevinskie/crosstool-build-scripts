#!/usr/bin/env zsh

set -o errexit
set -o nounset
set -o pipefail

set -o xtrace

NUMJOBS=`nproc`

JEV_GMP=gmp-6.2.1
JEV_MPFR=mpfr-4.1.0
JEV_MPC=mpc-1.2.1
JEV_ISL=isl-0.24
JEV_PYTHON_VER=3.10.4
JEV_PYTHON=Python-${JEV_PYTHON_VER}
# JEV_GCC=gcc-12.1.0
JEV_GCC=gcc-git

# JEV_BINUTILS=binutils-2.38
JEV_BINUTILS=binutils-git
# JEV_GDB=gdb-12.1
JEV_GDB=gdb-git

# ln -s ~/code/gcc/git/gcc gcc-git
# ln -s ~/code/linkers/binutils/git/binutils-gdb binutils-git
# ln -s ~/code/linkers/binutils/git/binutils-gdb/gdb gdb-git


JEV_XTOOL_PREFIX=/opt/x86_64/x86_64-linux-gcc-git-2022-07-09
unset GREP_OPTIONS
mkdir -p ${JEV_XTOOL_PREFIX}/bin
hash -r

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
hash -r
export LDFLAGS_SHARED="-L${JEV_XTOOL_PREFIX}/lib -Wl,-rpath,${JEV_XTOOL_PREFIX}/lib"
export LDFLAGS="${LDFLAGS_SHARED}"
export CPPFLAGS=-I${JEV_XTOOL_PREFIX}/include
export CFLAGS="${CPPFLAGS} -march=native"
export CXXFLAGS="${CPPFLAGS} -march=native"

JEV_GNU_MIRROR=https://ftp.gnu.org

# gmp
wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
rm -rf ${JEV_GMP} build-gmp
tar xf ${JEV_GMP}.tar.xz
mkdir -p build-gmp
pushd build-gmp
../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd
hash -r

# mpfr
wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
rm -rf ${JEV_MPFR} build-mfr
tar xf ${JEV_MPFR}.tar.xz
mkdir -p build-mpfr
pushd build-mpfr
../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd
hash -r

# mpc
wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
rm -rf ${JEV_MPC} build-mpc
tar xf ${JEV_MPC}.tar.gz
mkdir -p build-mpc
pushd build-mpc
../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd
hash -r

# isl
wget -N https://libisl.sourceforge.io/${JEV_ISL}.tar.xz
rm -rf ${JEV_ISL} build-isl
tar xf ${JEV_ISL}.tar.xz
mkdir -p build-isl
pushd build-isl
../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
make -j${NUMJOBS} install
popd
hash -r

# python
wget -N https://www.python.org/ftp/python/${JEV_PYTHON_VER}/${JEV_PYTHON}.tar.xz
rm -rf ${JEV_PYTHON} build-python
tar xf ${JEV_PYTHON}.tar.xz
mkdir -p build-python
pushd build-python
mkdir -p ${JEV_XTOOL_PREFIX}/opt/python
LDFLAGS=${LDFLAGS_SHARED} ../${JEV_PYTHON}/configure --prefix=${JEV_XTOOL_PREFIX}/opt/python
LDFLAGS=${LDFLAGS_SHARED} make -j${NUMJOBS} install
popd
hash -r

# binutils
# wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
# rm -rf ${JEV_BINUTILS}
rm -rf build-binutils
# tar xf ${JEV_BINUTILS}.tar.bz2
mkdir -p build-binutils
pushd build-binutils
../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-plugin --with-python=${JEV_XTOOL_PREFIX}/opt/python/bin/python3
make -j${NUMJOBS} all
make -j${NUMJOBS} install
popd
hash -r

# gcc
# wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
# rm -rf ${JEV_GCC}
rm -rf build-gcc
# tar xf ${JEV_GCC}.tar.xz

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-sysroot
make -j${NUMJOBS} all
make install
popd
hash -r

# gdb
# # wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
# # rm -rf ${JEV_GDB}
# rm -rf build-gdb
# # tar xf ${JEV_GDB}.tar.xz

# mkdir -p build-gdb
# pushd build-gdb
# ../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --enable-sysroot --enable-plugin --target=lm32-elf
# make -j${NUMJOBS} all
# make -j${NUMJOBS} install
# popd
# hash -r
