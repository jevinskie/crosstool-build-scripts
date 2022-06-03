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
JEV_PYTHON=Python-3.10.4
# JEV_GCC=gcc-11.1.0
JEV_GCC=gcc-git
# JEV_NEWLIB=newlib-4.1.0
JEV_NEWLIB=newlib-git
JEV_MUSL=musl-git
JEV_MUSL_PATCHED=musl-patched

# JEV_BINUTILS=binutils-2.36.1
JEV_BINUTILS=binutils-git
# JEV_GDB=gdb-10.2
JEV_GDB=gdb-git

# ln -s ~/code/gcc/git/gcc gcc-git
# ln -s ~/code/libc/newlib/git/newlib newlib-git
# ln -s ~/code/libc/musl/git/musl musl-git
# ln -s ~/code/linkers/binutils/git/binutils-gdb binutils-git
# ln -s ~/code/linkers/binutils/git/binutils-gdb/gdb gdb-git


JEV_XTOOL_PREFIX=/opt/riscv/rv32-linux-gcc-git-2022-06-02
unset GREP_OPTIONS
mkdir -p ${JEV_XTOOL_PREFIX}/bin
hash -r

export PATH=${JEV_XTOOL_PREFIX}/bin:${PATH}
hash -r
export LDFLAGS_SHARED="-L${JEV_XTOOL_PREFIX}/lib -Wl,-rpath,${JEV_XTOOL_PREFIX}/lib"
# export LDFLAGS_SHARED="${LDFLAGS_SHARED} -static-libgcc -static-libstdc++"
# export LDFLAGS="${LDFLAGS_SHARED} -static"
export LDFLAGS="${LDFLAGS_SHARED}"
export CPPFLAGS=-I${JEV_XTOOL_PREFIX}/include
export CFLAGS=${CPPFLAGS}
export CXXFLAGS=${CPPFLAGS}
# export LDFLAGS_FOR_TARGET=""
export CFLAGS_FOR_TARGET="-DPREFER_SIZE_OVER_SPEED=1 -Os -ffunction-sections -fdata-sections"
export LIBCFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export CXXFLAGS_FOR_TARGET=${CFLAGS_FOR_TARGET}
export LIBCXXFLAGS_FOR_TARGET=${CXXFLAGS_FOR_TARGET}

JEV_GNU_MIRROR=https://ftp.gnu.org

# # gmp
# wget -N ${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz
# rm -rf ${JEV_GMP} build-gmp
# tar xf ${JEV_GMP}.tar.xz
# mkdir -p build-gmp
# pushd build-gmp
# ../${JEV_GMP}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd
# hash -r

# # mpfr
# wget -N ${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz
# rm -rf ${JEV_MPFR} build-mfr
# tar xf ${JEV_MPFR}.tar.xz
# mkdir -p build-mpfr
# pushd build-mpfr
# ../${JEV_MPFR}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd
# hash -r

# # mpc
# wget -N ${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz
# rm -rf ${JEV_MPC} build-mpc
# tar xf ${JEV_MPC}.tar.gz
# mkdir -p build-mpc
# pushd build-mpc
# ../${JEV_MPC}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd
# hash -r

# # isl
# wget -N https://libisl.sourceforge.io/${JEV_ISL}.tar.xz
# rm -rf ${JEV_ISL} build-isl
# tar xf ${JEV_ISL}.tar.xz
# mkdir -p build-isl
# pushd build-isl
# ../${JEV_ISL}/configure --prefix=${JEV_XTOOL_PREFIX}
# make -j${NUMJOBS} install
# popd
# hash -r

# # python
# wget -N https://www.python.org/ftp/python/3.10.4/${JEV_PYTHON}.tar.xz
# rm -rf ${JEV_PYTHON} build-python
# tar xf ${JEV_PYTHON}.tar.xz
# mkdir -p build-python
# pushd build-python
# mkdir -p ${JEV_XTOOL_PREFIX}/opt/python
# LDFLAGS=${LDFLAGS_SHARED} ../${JEV_PYTHON}/configure --prefix=${JEV_XTOOL_PREFIX}/opt/python
# LDFLAGS=${LDFLAGS_SHARED} make -j${NUMJOBS} install
# popd
# hash -r

# # binutils
# # wget -N ${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2
# # rm -rf ${JEV_BINUTILS}
# rm -rf build-binutils
# # tar xf ${JEV_BINUTILS}.tar.bz2
# mkdir -p build-binutils
# pushd build-binutils
# ../${JEV_BINUTILS}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c,c++ --target=riscv32-linux-gnu --with-python=${JEV_XTOOL_PREFIX}/opt/python/bin/python3
# make -j${NUMJOBS} all
# make -j${NUMJOBS} install
# popd
# hash -r

# musl unpack
rm -rf build-musl

# musl patch
rm -rf ${JEV_MUSL_PATCHED}
cp -RH ${JEV_MUSL} ${JEV_MUSL_PATCHED}
git clone --depth 1 https://github.com/riscv/meta-riscv || true
pushd meta-riscv
git pull
popd
pushd ${JEV_MUSL_PATCHED}
setopt extendedglob
for p in ../meta-riscv/recipes-core/musl/musl/^0001*; do
    patch -p1 < $p
done
patch -p1 < ../meta-riscv/recipes-core/musl/musl/0001*
unsetopt extendedglob
popd

# gcc
# wget -N ${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz
# rm -rf ${JEV_GCC}
rm -rf build-gcc
# tar xf ${JEV_GCC}.tar.xz

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=riscv32-linux-gnu --without-headers --with-newlib --enable-sysroot --disable-multilib
make -j${NUMJOBS} all-gcc
make install-gcc
popd
hash -r

# musl build pt 1 headers
mkdir -p build-musl
pushd build-musl
../${JEV_MUSL_PATCHED}/configure --target=riscv32-linux-gnu --enable-optimize=size --disable-shared --prefix=${JEV_XTOOL_PREFIX}/riscv32-linux-gnu
make install-headers
popd
hash -r

# libgcc
pushd build-gcc
make -j${NUMJOBS} all-target-libgcc
make install-target-libgcc
popd

# musl pt 2
pushd build-musl
../${JEV_MUSL_PATCHED}/configure --target=riscv32-linux-gnu --enable-optimize=size --prefix=${JEV_XTOOL_PREFIX}/riscv32-linux-gnu
make -j${NUMJOBS} all
make install
popd

# gcc final
pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --enable-languages=c --target=riscv32-linux-gnu --with-newlib --enable-sysroot --disable-multilib
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