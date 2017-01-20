#!/bin/bash

## Environments

# Exit the build pass if any command returns a non-zero value
#set -o errexit

# Echo commands
set -x

# 13.4.0 - Mavericks
# 14.0.0 - Yosemite
# 15.0.0 - El Capitan
# 16.0.0 - Sierra
DARWIN=darwin`uname -r`

MIN_SDK_VERSION=8.0

IPHONEOS_SYSROOT=`xcrun --sdk iphoneos --show-sdk-path`
IPHONESIMULATOR_SYSROOT=`xcrun --sdk iphonesimulator --show-sdk-path`

# Verbose clang output
#CLANG_VERBOSE="--verbose"

CC=clang
CXX=clang

SILENCED_WARNINGS="-Wno-unused-local-typedef -Wno-unused-function"

# NOTE: Google Protobuf does not currently build if you specify 'libstdc++'
# instead of `libc++` here.
STDLIB=libc++

CFLAGS="${CLANG_VERBOSE} ${SILENCED_WARNINGS} -DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions"
CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=${STDLIB}"

LDFLAGS="-stdlib=${STDLIB}"
LIBS="-lc++ -lc++abi"

PROTOC=`which protoc`

PROTOBUF_SOURCE_DIR=protobuf

PREFIX=`pwd`/../output/protobuf
if [ -d ${PREFIX} ]
then
    rm -rf "${PREFIX}"
fi
mkdir -p "${PREFIX}/platform"

## Functions

build-arch() {
  HOST=$1
  ARCH=$2
  PLATFORM_NAME=${ARCH}
  SYSROOT=${IPHONEOS_SYSROOT}

  make distclean
  ./configure \
    --build=x86_64-apple-${DARWIN} \
    --host=${HOST} \
    --with-protoc=${PROTOC} \
    --disable-shared \
    --prefix=${PREFIX} \
    --exec-prefix=${PREFIX}/platform/${PLATFORM_NAME} \
    "CC=${CC}" \
    "CFLAGS=${CFLAGS} -miphoneos-version-min=${MIN_SDK_VERSION} -arch ${ARCH} -isysroot ${SYSROOT}" \
    "CXX=${CXX}" \
    "CXXFLAGS=${CXXFLAGS} -miphoneos-version-min=${MIN_SDK_VERSION} -arch ${ARCH} -isysroot ${SYSROOT}" \
    LDFLAGS="-arch ${ARCH} -miphoneos-version-min=${MIN_SDK_VERSION} ${LDFLAGS}" \
    "LIBS=${LIBS}"

  make -j8
  make install
}

build-i386-simulator() {
  ARCH=i386
  HOST=${ARCH}-apple-${DARWIN}
  PLATFORM_NAME=${ARCH}-simulator
  SYSROOT=${IPHONESIMULATOR_SYSROOT}

  make distclean
  ./configure \
    --build=x86_64-apple-${DARWIN} \
    --host=${HOST} \
    --with-protoc=${PROTOC} \
    --disable-shared \
    --prefix=${PREFIX} \
    --exec-prefix=${PREFIX}/platform/${PLATFORM_NAME} \
    "CC=${CC}" \
    "CFLAGS=${CFLAGS} -mios-simulator-version-min=${MIN_SDK_VERSION} -arch ${ARCH} -isysroot ${SYSROOT}" \
    "CXX=${CXX}" \
    "CXXFLAGS=${CXXFLAGS} -mios-simulator-version-min=${MIN_SDK_VERSION} -arch ${ARCH} -isysroot ${SYSROOT}" \
    LDFLAGS="-arch ${ARCH} -mios-simulator-version-min=${MIN_SDK_VERSION} ${LDFLAGS}" \
    "LIBS=${LIBS}"

  make -j8
  make install
}

build-x86_64-simulator() {
  ARCH=x86_64
  PLATFORM_NAME=${ARCH}-simulator
  SYSROOT=${IPHONESIMULATOR_SYSROOT}

  make distclean
  ./configure --prefix=${PREFIX} \
              --exec-prefix=${PREFIX}/platform/${PLATFORM_NAME} \
              --with-sysroot=${SYSROOT} \
              --with-protoc=`which protoc` \
              --enable-static \
              --disable-shared

  make -j8
  make install
}

build-fat-lib() {
  OUT=${PREFIX}/universal
  mkdir -p ${OUT}

  PLATFORM_ROOT=${PREFIX}/platform
  LIPO=lipo

  LIB=libprotobuf.a
  ${LIPO} ${PLATFORM_ROOT}/arm64/lib/${LIB} \
          ${PLATFORM_ROOT}/armv7/lib/${LIB} \
          ${PLATFORM_ROOT}/x86_64-simulator/lib/${LIB} \
          ${PLATFORM_ROOT}/i386-simulator/lib/${LIB} \
          -create \
          -output ${OUT}/${LIB}

  LIB_LITE=libprotobuf-lite.a
  ${LIPO} ${PLATFORM_ROOT}/arm64/lib/${LIB_LITE} \
          ${PLATFORM_ROOT}/armv7/lib/${LIB_LITE} \
          ${PLATFORM_ROOT}/x86_64-simulator/lib/${LIB_LITE} \
          ${PLATFORM_ROOT}/i386-simulator/lib/${LIB_LITE} \
          -create \
          -output ${OUT}/${LIB_LITE}
}

## Build pass

cd ${PROTOBUF_SOURCE_DIR}

./autogen.sh

build-x86_64-simulator
build-i386-simulator

build-arch arm arm64
build-arch armv7-apple-${DARWIN} armv7

build-fat-lib

echo DONE!
