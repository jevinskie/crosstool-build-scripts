#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

JEV_GMP=gmp-6.3.0
JEV_MPFR=mpfr-4.2.1
JEV_MPC=mpc-1.3.1
#JEV_GCC=gcc-14.1.0
# gcc 14.1.0 doesn't build libstdc++ with -fno-rtti but it is fixed on HEAD
JEV_GCC=gcc-git
# JEV_NEWLIB=newlib-4.4.0.20231231
# JEV_BINUTILS=binutils-2.42
JEV_BINUTILS=binutils-git
JEV_GDB=gdb-14.2
JEV_ISL=isl-0.26
JEV_PYTHON=3.11.9

JEV_XTOOL_PREFIX=/opt/gcc/gcc-15-bare

if [[ "${OS}" == "Windows_NT" ]]; then
    echo "Windows not supported yet" >&2
    exit 1
else
    UNAME_S=$(uname -s)
    case "${UNAME_S}" in
        Darwin)
            USING_MAC=1
            USING_LINUX=0
            ;;
        Linux)
            USING_MAC=0
            USING_LINUX=1
            ;;
        *)
            echo "Unsupported OS: ${UNAME_S}" >&2
            exit 1
            ;;
    esac
fi

if [[ "${USING_MAC}" -eq 1 ]]; then
   SCRIPT_DIR="$(dirname -- "$(greadlink -f -- "$0"; )"; )"
else
   SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0"; )"; )"
fi

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

if [[ "${JEV_GCC}" == "gcc-git" ]]; then
    if [[ ! -d "${GCC_GIT_DIR}" ]]; then
        echo "GCC_GIT_DIR env var must point to gcc git checkout." >&2
        exit 1
    fi
    USING_GCC_GIT=1
    GCC_SRC_DIR="${GCC_GIT_DIR}"
else
    USING_GCC_GIT=0
    GCC_SRC_DIR="${SCRIPT_DIR}/${JEV_GCC}"
fi

if [[ "${JEV_BINUTILS}" == "binutils-git" ]]; then
    if [[ ! -d "${BINUTILS_GIT_DIR}" ]]; then
        echo "BINUTILS_GIT_DIR env var must point to binutils git checkout." >&2
        exit 1
    fi
    USING_BINUTILS_GIT=1
    BINUTILS_SRC_DIR="${BINUTILS_GIT_DIR}"
else
    USING_BINUTILS_GIT=0
    BINUTILS_SRC_DIR="${SCRIPT_DIR}/${JEV_BINUTILS}"
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
                brew install autoconf automake libtool make pkg-config gnu-tar openssl readline sqlite3 xz zstd zlib bzip2 texinfo tcl-tk flex bison xxhash
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
            if [[ -z "${SKIP_APT_INSTALL}" ]] && type apt &>/dev/null; then
                sudo apt update
                sudo apt install -y build-essential autoconf automake libtool make tar openssl libssl-dev libreadline-dev libsqlite3-dev xz-utils liblzma-dev zstd libzstd-dev zlib1g-dev bzip2 libbz2-dev texinfo tcl tk tcl-dev tk-dev curl git libncursesw5-dev libxml2-dev libxmlsec1-dev libffi-dev flex bison libxxhash-dev libdebuginfod-dev uuid-dev
            elif [[ -n "${SKIP_APT_INSTALL}" ]]; then
                true
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

mkdir -p "${JEV_XTOOL_PREFIX}/bin" "${JEV_XTOOL_PREFIX}/lib/pkgconfig"

export PATH="${JEV_XTOOL_PREFIX}/bin:${PATH}"
export PKG_CONFIG_PATH="${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LDFLAGS="${LDFLAGS} -L${JEV_XTOOL_PREFIX}/lib -Wl,-rpath,${JEV_XTOOL_PREFIX}/lib ${LDFLAGS}"
# export CPPFLAGS="${CPPFLAGS} -I${JEV_XTOOL_PREFIX}/include ${CPPFLAGS} -march=native -ggdb3 -fno-eliminate-unused-debug-symbols -fvar-tracking -fvar-tracking-assignments -gdescribe-dies -grecord-gcc-switches -gstatement-frontiers -ginline-points -gas-locview-support -gvariable-location-views -fno-eliminate-unused-debug-types -O0"
export CPPFLAGS="${CPPFLAGS} -I${JEV_XTOOL_PREFIX}/include ${CPPFLAGS} -march=native"
export CFLAGS="${CFLAGS} ${CPPFLAGS} -Wno-error"
export CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} -Wno-error"
export CFLAGS_FOR_TARGET="-Wno-error"
export CXXFLAGS_FOR_TARGET="${CFLAGS_FOR_TARGET}"
export LDFLAGS_FOR_TARGET=""
JEV_LIBSTDCXX_FLAGS=""

JEV_GNU_MIRROR=https://ftp.gnu.org

NUM_CORES=$(nproc)

refresh_path

cd ${SCRIPT_DIR}/..

# # gmp
# wget -N "${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz"
# rm -rf "${JEV_GMP}" build-gmp
# tar xf "${JEV_GMP}.tar.xz"
# mkdir -p build-gmp
# pushd build-gmp
# ../${JEV_GMP}/configure --prefix="${JEV_XTOOL_PREFIX}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" "CXXFLAGS=${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
# rm libtool
# ln -s `which libtool` libtool
# make -j "${NUM_CORES}" all V=1
# make -j "${NUM_CORES}" install V=1
# popd
# refresh_path

# # mpfr
# wget -N "${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz"
# rm -rf "${JEV_MPFR}" build-mfr
# tar xf "${JEV_MPFR}.tar.xz"
# mkdir -p build-mpfr
# pushd build-mpfr
# ../${JEV_MPFR}/configure --prefix="${JEV_XTOOL_PREFIX}"
# make -j "${NUM_CORES}" all V=0
# make -j "${NUM_CORES}" install V=0
# popd
# refresh_path

# # mpc
# wget -N "${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz"
# rm -rf "${JEV_MPC}" build-mpc V=0
# tar xf "${JEV_MPC}.tar.gz"
# mkdir -p build-mpc
# pushd build-mpc
# ../${JEV_MPC}/configure --prefix="${JEV_XTOOL_PREFIX}"
# make -j "${NUM_CORES}" all V=0
# make -j "${NUM_CORES}" install V=0
# popd
# refresh_path

# # isl
# wget -N "https://libisl.sourceforge.io/${JEV_ISL}.tar.xz"
# rm -rf "${JEV_ISL}" build-isl
# tar xf "${JEV_ISL}.tar.xz"
# mkdir -p build-isl
# pushd build-isl
# ../${JEV_ISL}/configure --prefix="${JEV_XTOOL_PREFIX}"
# make -j "${NUM_CORES}" all V=0
# make -j "${NUM_CORES}" install V=0
# popd
# refresh_path

# # python
# wget -N "https://www.python.org/ftp/python/${JEV_PYTHON}/Python-${JEV_PYTHON}.tar.xz"
# rm -rf "${JEV_PYTHON}" build-python
# tar xf "Python-${JEV_PYTHON}.tar.xz"
# mkdir -p build-python
# pushd build-python
# ../Python-${JEV_PYTHON}/configure --prefix="${JEV_XTOOL_PREFIX}" --enable-shared
# make -j "${NUM_CORES}" all V=0
# make -j "${NUM_CORES}" install V=0
# popd
# ln -f -s "${JEV_XTOOL_PREFIX}/bin/python3" "${JEV_XTOOL_PREFIX}/bin/python"
# ln -f -s "${JEV_XTOOL_PREFIX}/bin/python3-config" "${JEV_XTOOL_PREFIX}/bin/python-config"
# refresh_path

# # binutils
# if [[ "${USING_BINUTILS_GIT}" -eq 0 ]]; then
#     wget -N "${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.bz2"
#     rm -rf "${BINUTILS_SRC_DIR}"
#     tar xf "${JEV_BINUTILS}.tar.xz"
# fi
# rm -rf build-binutils

# mkdir -p build-binutils
# pushd build-binutils
# "${BINUTILS_SRC_DIR}/configure" --prefix="${JEV_XTOOL_PREFIX}" --enable-multilib --enable-plugin --enable-languages=c,c++ --disable-werror --enable-targets=all --with-lzma --with-zstd --enable-gold --enable-gprofng --enable-host-pie --enable-libssp --enable-lto --enable-vtable-verify --with-intel-pt --with-debuginfod --with-xxhash --enable-sim --enable-libbacktrace --enable-tui --enable-plugins --enable-isl-version-check --enable-libquadmath --disable-guile --with-python=${JEV_XTOOL_PREFIX}/bin/python3.11 --with-curses --with-system-readline
# # --enable-source-highlight
# make -j "${NUM_CORES}" all V=0
# make -j "${NUM_CORES}" install V=0
# popd
# refresh_path

# gcc
if [[ "${USING_GCC_GIT}" -eq 0 ]]; then
    wget -N "${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz"
    rm -rf "${GCC_SRC_DIR}"
    tar xf "${JEV_GCC}.tar.xz"
fi
rm -rf build-gcc

mkdir -p build-gcc
pushd build-gcc
"${GCC_SRC_DIR}/configure" --prefix="${JEV_XTOOL_PREFIX}" --enable-shared --disable-multilib --enable-threads --enable-tls --disable-werror --disable-lto --enable-languages=c,c++ --disable-gcov --disable-tm-clone-registry --enable-__cxa_atexit --enable-gnu-indirect-function --disable-bootstrap --disable-libada --disable-libgm2 --disable-libsanitizer --disable-libgomp --disable-libvtv --disable-checking --disable-nls --disable-decimal-float --with-linker-hash-style=gnu --enable-linker-build-id --disable-cet

make -j "${NUM_CORES}" all V=0
make -j "${NUM_CORES}" install V=0
popd
refresh_path

# if [[ "${USING_BINUTILS_GIT}" -eq 0 ]]; then
#     # gdb
#     wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
#     rm -rf ${JEV_GDB} build-gdb
#     tar xf ${JEV_GDB}.tar.xz
#     mkdir -p build-gdb
#     pushd build-gdb
#     ../${JEV_GDB}/configure --prefix=${JEV_XTOOL_PREFIX} --disable-guile --enable-python --enable-sim --enable-tui --enable-languages=c,c++
#     make -j "${NUM_CORES}" all V=0
#     make -j "${NUM_CORES}" install V=0
#     popd
#     refresh_path
# fi
