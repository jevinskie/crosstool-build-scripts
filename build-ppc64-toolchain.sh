#!/usr/bin/env bash

set -e
set -x

JEV_TARGET=powerpc64-linux-gnu

# https://repology.org/project/gmp/information
JEV_GMP=gmp-6.3.0
# https://repology.org/project/mpfr/information
JEV_MPFR=mpfr-4.2.2
# https://repology.org/project/gnumpc/information
JEV_MPC=mpc-1.3.1
# https://repology.org/project/gcc/information
JEV_GCC=gcc-15.1.0
# JEV_GCC=gcc-git
# https://repology.org/project/newlib/information
# https://sourceware.org/ftp/newlib/index.html
# JEV_NEWLIB=newlib-4.5.0.20241231
# https://github.com/picolibc/picolibc/releases
JEV_PICOLIBC_VERSION=1.8.10
JEV_PICOLIBC=picolibc-${JEV_PICOLIBC_VERSION}
# https://repology.org/project/binutils/information
JEV_BINUTILS=binutils-2.44
# https://repology.org/project/gdb/information
JEV_GDB=gdb-16.3
# https://repology.org/project/isl/information
JEV_ISL=isl-0.27
# https://repology.org/project/cloog/information
# https://github.com/periscop/cloog/releases
JEV_CLOOG=cloog-0.21.1
# https://repology.org/project/python/information
JEV_PYTHON=3.13.5


JEV_XTOOL_PREFIX=/opt/x-tools/ppc64-elf
JEV_XTOOL_SYSROOT="${JEV_XTOOL_PREFIX}/${JEV_TARGET}/sysroot"


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

function refresh_path() {
    hash -r
}

if [[ "${OS}" == "Windows_NT" ]]; then
    echo "Windows not supported yet" >&2
    exit 1
else
    UNAME_S=$(uname -s)
    case "${UNAME_S}" in
        Darwin)
            if type brew &>/dev/null; then
                # brew install autoconf automake libtool make pkg-config gnu-tar openssl readline sqlite3 xz zstd zlib bzip2 texinfo tcl-tk flex bison xxhash
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
                sudo apt install -y build-essential autoconf automake libtool make pkg-config tar openssl libssl-dev libreadline-dev libsqlite3-dev xz-utils liblzma-dev zstd libzstd-dev zlib1g-dev bzip2 libbz2-dev texinfo tcl tk tcl-dev tk-dev curl git libncursesw5-dev libxml2-dev libxmlsec1-dev libffi-dev flex bison libxxhash-dev libdebuginfod-dev uuid-dev
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
mkdir -p "${JEV_XTOOL_PREFIX}/include"
mkdir -p "${JEV_XTOOL_PREFIX}/lib/pkgconfig"
mkdir -p "${JEV_XTOOL_SYSROOT}"
# GCC stage0 gets pissy if sysroot include doesn't exist at build time (fixinc)
mkdir -p "${JEV_XTOOL_SYSROOT}/include"

export PATH="${JEV_XTOOL_PREFIX}/bin:${PATH}"
export PKG_CONFIG_PATH="${JEV_XTOOL_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LDFLAGS="-L${JEV_XTOOL_PREFIX}/lib -Wl,-rpath,${JEV_XTOOL_PREFIX}/lib ${LDFLAGS}"
export CPPFLAGS="-I${JEV_XTOOL_PREFIX}/include ${CPPFLAGS}"
export CFLAGS="${CPPFLAGS} -Wno-error"
export CXXFLAGS="${CPPFLAGS} -Wno-error"

export C_CXX_EXTRA_FLAGS="-Wno-deprecated-declarations -Wno-deprecated-non-prototype -Wno-deprecated-declarations -Wno-mismatched-tags -Wno-unknown-warning-option"
export CFLAGS="${CFLAGS} ${C_CXX_EXTRA_FLAGS}"
export CXXFLAGS="${CXXFLAGS} ${C_CXX_EXTRA_FLAGS}"


export CFLAGS_FOR_TARGET="-Oz -g -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -fomit-frame-pointer -ffunction-sections -fdata-sections -fvisibility=hidden"
export CXXFLAGS_FOR_TARGET="${CFLAGS_FOR_TARGET} -fno-rtti"
export LDFLAGS_FOR_TARGET="-Oz -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -ffunction-sections -fdata-sections -fvisibility=hidden -Wl,--gc-sections"
JEV_LIBSTDCXX_FLAGS="-Oz -g -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-exceptions -fomit-frame-pointer -ffunction-sections -fdata-sections -fvisibility=hidden -fno-rtti"

JEV_GNU_MIRROR=https://ftp.gnu.org

NUM_CORES=$(nproc)

if false; then
    SYSROOT_CONF=""
else
    SYSROOT_CONF="--with-sysroot=${JEV_XTOOL_SYSROOT}"
fi

refresh_path

# gmp
build_gmp() {
    wget -N "${JEV_GNU_MIRROR}/gnu/gmp/${JEV_GMP}.tar.xz"
    rm -rf "${JEV_GMP}"
    tar xf "${JEV_GMP}.tar.xz"
    rm -rf build-gmp
    mkdir -p build-gmp
    pushd build-gmp
    "../${JEV_GMP}/configure" -C --disable-maintainer-mode --prefix="${JEV_XTOOL_PREFIX}"
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

# mpfr
build_mpfr() {
    wget -N "${JEV_GNU_MIRROR}/gnu/mpfr/${JEV_MPFR}.tar.xz"
    rm -rf "${JEV_MPFR}"
    tar xf "${JEV_MPFR}.tar.xz"
    rm -rf build-mfr
    mkdir -p build-mpfr
    pushd build-mpfr
    "../${JEV_MPFR}/configure" -C --disable-maintainer-mode --prefix="${JEV_XTOOL_PREFIX}"
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

# mpc
build_mpc() {
    wget -N "${JEV_GNU_MIRROR}/gnu/mpc/${JEV_MPC}.tar.gz"
    rm -rf "${JEV_MPC}"
    tar xf "${JEV_MPC}.tar.gz"
    rm -rf build-mpc
    mkdir -p build-mpc
    pushd build-mpc
    "../${JEV_MPC}/configure" -C --disable-maintainer-mode --prefix="${JEV_XTOOL_PREFIX}"
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

# isl
build_isl() {
    wget -N "https://libisl.sourceforge.io/${JEV_ISL}.tar.xz"
    rm -rf "${JEV_ISL}"
    tar xf "${JEV_ISL}.tar.xz"
    rm -rf build-isl
    mkdir -p build-isl
    pushd build-isl
    "../${JEV_ISL}/configure" -C --disable-maintainer-mode --prefix="${JEV_XTOOL_PREFIX}"
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

# cloog
build_cloog() {
    wget -N "https://github.com/periscop/cloog/releases/download/${JEV_CLOOG}/${JEV_CLOOG}.tar.gz"
    rm -rf "${JEV_CLOOG}"
    tar xf "${JEV_CLOOG}.tar.gz"
    rm -rf build-cloog
    mkdir -p build-cloog
    pushd build-cloog
    "../${JEV_CLOOG}/configure" --disable-maintainer-mode --disable-maintainer-mode --prefix="${JEV_XTOOL_PREFIX}" --with-isl=system
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

# python
build_python() {
    wget -N "https://www.python.org/ftp/python/${JEV_PYTHON}/Python-${JEV_PYTHON}.tar.xz"
    rm -rf "${JEV_PYTHON}"
    tar xf "Python-${JEV_PYTHON}.tar.xz"
    rm -rf build-python
    mkdir -p build-python
    pushd build-python
    "../Python-${JEV_PYTHON}/configure" --prefix="${JEV_XTOOL_PREFIX}" --enable-shared
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    pushd "${JEV_XTOOL_PREFIX}/bin"
    ln -f -s python3 python
    ln -f -s python3-config python-config
    popd
    refresh_path
}

# binutils
build_binutils() {
    wget -N "${JEV_GNU_MIRROR}/gnu/binutils/${JEV_BINUTILS}.tar.zst"
    rm -rf "${JEV_BINUTILS}"
    tar xf "${JEV_BINUTILS}.tar.zst"
    pushd "${JEV_BINUTILS}"
    sd -F '#if defined(MACOS) || defined(TARGET_OS_MAC)' '#if !defined(__APPLE__) && (defined(MACOS) || defined(TARGET_OS_MAC))' zlib/zutil.h
    popd
    rm -rf build-binutils
    mkdir -p build-binutils
    pushd build-binutils
    "../${JEV_BINUTILS}/configure" --prefix="${JEV_XTOOL_PREFIX}" --disable-maintainer-mode --disable-multilib --disable-nls --enable-plugin --enable-lto --enable-languages=c,c++ --target=${JEV_TARGET}
    make -j "${NUM_CORES}" all V=1
    make -j "${NUM_CORES}" install V=1
    popd
    refresh_path
}

# gcc
build_gcc_stage0() {
    if [[ "${USING_GCC_GIT}" -eq 0 ]]; then
        # wget -N "${JEV_GNU_MIRROR}/gnu/gcc/${JEV_GCC}/${JEV_GCC}.tar.xz"
        # rm -rf "${GCC_SRC_DIR}"
        # tar xf "${JEV_GCC}.tar.xz"
        pushd "${JEV_GCC}"
        sd -F '#if defined(MACOS) || defined(TARGET_OS_MAC)' '#if !defined(__APPLE__) && (defined(MACOS) || defined(TARGET_OS_MAC))' zlib/zutil.h
        popd
        # true
    fi
    rm -rf build-gcc
    mkdir -p build-gcc
    pushd build-gcc
    "${GCC_SRC_DIR}/configure" --prefix="${JEV_XTOOL_PREFIX}" $SYSROOT_CONF --with-native-system-header-dir=/include --disable-maintainer-mode --disable-bootstrap --disable-shared --disable-nls --disable-multilib --disable-tm-clone-registry --with-newlib --enable-lto --without-headers --with-gnu-as --with-gnu-ld --enable-languages=c --target=${JEV_TARGET}
    make -j "${NUM_CORES}" all-gcc V=0
    make -j "${NUM_CORES}" install-gcc V=0
    popd
    refresh_path
}

# newlib
build_newlib() {
    wget -N "https://sourceware.org/pub/newlib/${JEV_NEWLIB}.tar.gz"
    rm -rf "${JEV_NEWLIB}"
    tar xf "${JEV_NEWLIB}.tar.gz"
    rm -rf build-newlib
    mkdir -p build-newlib
    pushd build-newlib
    "../${JEV_NEWLIB}/configure" -C --prefix="${JEV_XTOOL_SYSROOT}" --disable-maintainer-mode --disable-shared --disable-multilib --target=${JEV_TARGET}
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

# picolibc
build_picolibc() {
    wget -N "https://github.com/picolibc/picolibc/releases/download/${JEV_PICOLIBC_VERSION}/${JEV_PICOLIBC}.tar.xz"
    rm -rf "${JEV_PICOLIBC}"
    tar xf "${JEV_PICOLIBC}.tar.xz"
    rm -rf build-picolibc
    env -u CPPFLAGS -u CFLAGS -u CXXFLAGS -u LDFLAGS meson setup --cross-file "${JEV_PICOLIBC}/scripts/cross-powerpc64-linux-gnu.txt" --prefix "${JEV_XTOOL_SYSROOT}" build-picolibc "${JEV_PICOLIBC}"
    env -u CPPFLAGS -u CFLAGS -u CXXFLAGS -u LDFLAGS meson compile -C build-picolibc
    env -u CPPFLAGS -u CFLAGS -u CXXFLAGS -u LDFLAGS meson install -C build-picolibc
    refresh_path
}

build_gcc_stage1() {
    rm -rf build-gcc1
    mkdir -p build-gcc1
    pushd build-gcc1
    "${GCC_SRC_DIR}/configure" -C --prefix="${JEV_XTOOL_PREFIX}" $SYSROOT_CONF --with-native-system-header-dir=/include --disable-maintainer-mode --disable-bootstrap --disable-shared --disable-nls --disable-multilib --disable-tm-clone-registry --with-newlib --enable-lto --with-gnu-as --with-gnu-ld --enable-cxx-flags="${JEV_LIBSTDCXX_FLAGS}" --enable-languages=c,c++ --target=${JEV_TARGET}
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    # make -j 1 all V=1
    # make -j 1 install V=1
    popd
    refresh_path
}

# gdb
build_gdb() {
    wget -N ${JEV_GNU_MIRROR}/gnu/gdb/${JEV_GDB}.tar.xz
    rm -rf "${JEV_GDB}"
    tar xf "${JEV_GDB}.tar.xz"
    rm -rf build-gdb
    mkdir -p build-gdb
    pushd "${JEV_GDB}"
    sd -F '#if defined(MACOS) || defined(TARGET_OS_MAC)' '#if !defined(__APPLE__) && (defined(MACOS) || defined(TARGET_OS_MAC))' zlib/zutil.h
    popd
    mkdir -p build-gdb
    pushd build-gdb
    "../${JEV_GDB}/configure" -C --prefix="${JEV_XTOOL_PREFIX}" $SYSROOT_CONF --disable-maintainer-mode --disable-nls --disable-guile --enable-python --enable-sim --enable-tui --enable-languages=c,c++ --target=${JEV_TARGET}
    make -j "${NUM_CORES}" all V=0
    make -j "${NUM_CORES}" install V=0
    popd
    refresh_path
}

build_python_stage1() {
    pushd "${JEV_XTOOL_PREFIX}/bin"
    rm -f python python-config
    mv python3 ${JEV_TARGET}-python3
    mv python3-config ${JEV_TARGET}-python3-config
    ln -s -f ${JEV_TARGET}-python3 ${JEV_TARGET}-python
    ln -s -f ${JEV_TARGET}-python3-config ${JEV_TARGET}-python-config
    popd
}

# build_gmp
# build_mpfr
# build_mpc
# build_isl
# build_cloog
# build_python

# checkpoint opportunity stage0
# exit 1

# build_binutils

# checkpoint opportunity stage1
# exit 1

build_gcc_stage0
# build_newlib
build_picolibc

# checkpoint opportunity stage2
# exit 1

build_gcc_stage1
# build_gdb
# build_python_stage1
