#!/bin/bash

set -u

#ARCHS=("android" "android-armeabi" "android64-aarch64" "android-x86" "android64" "android-mips" "android-mips64")
OUTNAME=( "armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mips" "mips64" )
TOOLS_ROOT=`pwd`
LIB_NAME="boringssl"
LIB_SRC="/Users/david/boringssl"
LIB_INST_ROOT=${TOOLS_ROOT}/..
ANDROID_API=${ANDROID_API:-"21"}
ANDROID_NDK=${ANDROID_NDK}

for ABI in "${OUTNAME[@]}"
do
  [[ ${ANDROID_API} < 21 ]] && ( echo "${ABI}" | grep 64 > /dev/null ) && continue;
  if [ ${1:-""} == "${ABI}" ] || [ ${1:-"x"} == "x" ]; then
    BUILD_DIR=${LIB_NAME}-${ABI}
    rm -rf ${BUILD_DIR}
    mkdir ${BUILD_DIR}
    pushd "${BUILD_DIR}"
    cmake -DCMAKE_TOOLCHAIN_FILE=${LIB_SRC}/third_party/android-cmake/android.toolchain.cmake \
          -DANDROID_NDK=${ANDROID_NDK} \
          -DCMAKE_BUILD_TYPE=Release \
          -DANDROID_ABI="${ABI}" \
          -DANDROID_NATIVE_API_LEVEL="${ANDROID_API}" \
          ${LIB_SRC}
    cmake --build .
    popd;

    cp ${BUILD_DIR}/crypto/libcrypto.a ${LIB_INST_ROOT}/lib/${ABI}
    cp ${BUILD_DIR}/ssl/libssl.a ${LIB_INST_ROOT}/lib/${ABI}
    cp -r ${LIB_SRC}/include/openssl ${LIB_INST_ROOT}/include/${ABI}
  fi;
done;
