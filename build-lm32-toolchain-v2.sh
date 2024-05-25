#!/usr/bin/env bash

set -e
set -x

JEV_GMP=gmp-6.3.0
JEV_MPFR=mpfr-4.2.1
JEV_MPC=mpc-1.3.1
JEV_GCC=gcc-14.1.0
JEV_NEWLIB=newlib-4.4.0.20231231
JEV_BINUTILS=binutils-2.42
JEV_GDB=gdb-14.2
JEV_ISL=isl-0.26
JEV_PYTHON=3.11.9

JEV_XTOOL_PREFIX=/opt/x-tools/lm32-elf

if [[ -n "${ZSH_VERSION}" ]]; then
    USING_ZSH=1
    USING_BASH=0
elif [[ -n "${BASH_VERSION}" ]]; then
    USING_BASH=1
    USING_ZSH=0
else
    echo "Only zsh or bash is supported." >&2
    exit 1
fi

function refresh_path() {
    if [[ "${USING_ZSH}" -eq 1 ]]; then
        rehash
    elif [[ "${USING_BASH}" -eq 1 ]]; then
        hash -r
    else
        echo "Bad shell." >&2
    fi
}

if [[ "${OS}" == "Windows_NT" ]]; then
    echo "Windows not supported yet" >&2
    exit 1
else
    UNAME_S=$(uname -s)
    case "${UNAME_S}" in
        Darwin)
            if type brew &>/dev/null; then
                brew install make pkg-config gnu-tar openssl readline sqlite3 xz zstd zlib bzip2 texinfo
                JEV_BREW_ROOT=$(brew --prefix)
                export PATH="${JEV_BREW_ROOT}/bin:${PATH}"
                export PKG_CONFIG_PATH="${JEV_BREW_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"
                export LDFLAGS="-L${JEV_BREW_ROOT}/lib ${LDFLAGS}"
                export CPPFLAGS="-idirafter ${JEV_BREW_ROOT}/include ${CPPFLAGS}"
                alias tar=gtar
            else
                echo "Homebrew is required." >&2
                exit 1
            fi
            ;;
        Linux)
            if type apt &>/dev/null; then
                sudo apt update
                sudo apt install -y make pkg-config tar openssl libssl-dev libreadline-dev libsqlite3-dev xz-utils liblzma-dev zstd libzstd-dev zlib1g-dev bzip2 libbz2-dev texinfo
            else
                echo "Linux without apt is not supported." >&2
                exit 1
            fi
            ;;
        *)
            echo "Unknown OS ${UNAME_S} is not supported." >&2
            exit 1
            ;;
    esac
fi

mkdir -p "${JEV_XTOOL_PREFIX}/bin"

export PATH="${JEV_XTOOL_PREFIX}/bin:${PATH}"
export PKG_CONFIG_PATH="${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LDFLAGS="-L${JEV_XTOOL_PREFIX}/lib ${LDFLAGS}"
export CPPFLAGS="-I${JEV_XTOOL_PREFIX}/include ${CPPFLAGS}"
export CFLAGS="${CPPFLAGS} -Wno-error"
export CXXFLAGS="${CPPFLAGS} -Wno-error"
export CFLAGS_FOR_TARGET="-DPREFER_SIZE_OVER_SPEED=1 -DSMALL_MEMORY=1 -DSMALL_DTOA=1 -mbarrel-shift-enabled -mmultiply-enabled -mdivide-enabled -msign-extend-enabled -Oz -g -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -fomit-frame-pointer -ffunction-sections -fdata-sections -fvisibility=hidden"
export CXXFLAGS_FOR_TARGET="${CFLAGS_FOR_TARGET} -fno-rtti"
export LDFLAGS_FOR_TARGET="-Oz -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -ffunction-sections -fdata-sections -fvisibility=hidden -Wl,--gc-sections"
JEV_LIBSTDCXXFLAGS="-mbarrel-shift-enabled -mmultiply-enabled -mdivide-enabled -msign-extend-enabled  -Oz -g -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions  -fomit-frame-pointer -ffunction-sections -fdata-sections -fvisibility=hidden -fno-rtti"

JEV_GNU_MIRROR=https://ftp.gnu.org

NUM_CORES=$(nproc)

refresh_path

# gmp
wget -N "${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz"
rm -rf "${JEV_GMP}" build-gmp
tar xf "${JEV_GMP}.tar.xz"
mkdir -p build-gmp
pushd build-gmp
../${JEV_GMP}/configure --prefix="${JEV_XTOOL_PREFIX}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" "CXXFLAGS=${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# mpfr
wget -N "${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz"
rm -rf "${JEV_MPFR}" build-mfr
tar xf "${JEV_MPFR}.tar.xz"
mkdir -p build-mpfr
pushd build-mpfr
../${JEV_MPFR}/configure --prefix="${JEV_XTOOL_PREFIX}"
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# mpc
wget -N "${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz"
rm -rf "${JEV_MPC}" build-mpc V=0
tar xf "${JEV_MPC}.tar.gz"
mkdir -p build-mpc
pushd build-mpc
../${JEV_MPC}/configure --prefix="${JEV_XTOOL_PREFIX}"
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# isl
wget -N "https://libisl.sourceforge.io/${JEV_ISL}.tar.xz"
rm -rf "${JEV_ISL}" build-isl
tar xf "${JEV_ISL}.tar.xz"
mkdir -p build-isl
pushd build-isl
../${JEV_ISL}/configure --prefix="${JEV_XTOOL_PREFIX}"
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# python
wget -N "https://www.python.org/ftp/python/${JEV_PYTHON}/Python-${JEV_PYTHON}.tar.xz"
rm -rf "${JEV_PYTHON}" build-python
tar xf "Python-${JEV_PYTHON}.tar.xz"
mkdir -p build-python
pushd build-python
../Python-${JEV_PYTHON}/configure --prefix="${JEV_XTOOL_PREFIX}" --enable-shared
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
ln -f -s "${JEV_XTOOL_PREFIX}/bin/python3" "${JEV_XTOOL_PREFIX}/bin/python"
ln -f -s "${JEV_XTOOL_PREFIX}/bin/python3-config" "${JEV_XTOOL_PREFIX}/bin/python-config"
refresh_path

# binutils
wget -N "${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2"
rm -rf "${JEV_BINUTILS}" build-binutils
tar xf "${JEV_BINUTILS}.tar.bz2"
mkdir -p build-binutils
pushd build-binutils
../${JEV_BINUTILS}/configure --prefix="${JEV_XTOOL_PREFIX}" --disable-multilib --enable-plugin --enable-lto --enable-languages=c,c++ --target=lm32-elf
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# newlib
wget -N "https://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz"
rm -rf "${JEV_NEWLIB}" build-newlib
tar xf "${JEV_NEWLIB}.tar.gz"

# gcc
wget -N "${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz"
rm -rf "${JEV_GCC}" build-gcc
tar xf "${JEV_GCC}.tar.xz"

mkdir -p build-gcc
pushd build-gcc
../${JEV_GCC}/configure --prefix="${JEV_XTOOL_PREFIX}" --disable-shared --disable-multilib --disable-threads --disable-tls --enable-lto --enable-languages=c,c++ --target=lm32-elf --without-headers --with-newlib --with-gnu-as --with-gnu-ld --disable-tm-clone-registry --enable-cxx-flags="${JEV_LIBSTDCXX_FLAGS}"
make -j "${NUM_CORES}" all-gcc V=0
make -j "${NUM_CORES}" install-gcc V=0
popd
refresh_path

mkdir -p build-newlib
pushd build-newlib
../${JEV_NEWLIB}/configure --disable-shared --disable-multilib --target=lm32-elf --prefix="${JEV_XTOOL_PREFIX}"
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

pushd build-gcc
../${JEV_GCC}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-shared --disable-multilib --disable-threads --disable-tls --enable-lto --enable-languages=c,c++ --target=lm32-elf --with-newlib --with-gnu-as --with-gnu-ld --enable-cxx-flags="${JEV_LIBSTDCXX_FLAGS}"
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# gdb
wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
rm -rf ${JEV_GDB} build-gdb
tar xf ${JEV_GDB}.tar.xz
mkdir -p build-gdb
pushd build-gdb
../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-guile --enable-python --enable-sim --enable-tui --enable-languages=c,c++ --target=lm32-elf
make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path
