# OpenSSL & cURL Library for iOS and Android

<table>
<thead>
<tr><td>library</td><td>version</td><td>platform support</td><td>arch support</td><td>pull commit</td></tr>
</thead>
<tr><td>openssl</td><td>1.1.0c</td><td>ios</td><td>armv7s armv7 i386 x86_64 arm64</td><td>20651fbb</td></tr>
<tr><td></td><td></td><td>android</td><td>armeabi armeabi-v7a arm64-v8a x86 x86_64 mips mips64</td><td>20651fbb</td></tr>
<tr><td>curl</td><td>7.51.0</td><td>ios</td><td>armv7s armv7 i386 x86_64 arm64</td><td>20651fbb</td></tr>
<tr><td></td><td></td><td>android</td><td>armeabi armeabi-v7a arm64-v8a x86 x86_64 mips mips64</td><td>20651fbb</td></tr>
</table>

## Downloads

If you do not want to build it by yourself, you could download our prebuilt library from [there](https://github.com/leenjewel/openssl_for_ios_and_android/releases/tag/20170105)

## OpenSSL Version

This a static library compile from openssl and cURL for iOS and Android.

~~[openssl-1.0.2c.tar.gz](https://www.openssl.org/source/openssl-1.0.2c.tar.gz)~~

[openssl-1.1.0c.tar.gz](https://www.openssl.org/source/openssl-1.1.0c.tar.gz)

## cURL Version

~~[curl-7.47.1.tar.gz](https://curl.haxx.se/download/curl-7.47.1.tar.gz)~~

[curl-7.51.0.tar.gz](https://curl.haxx.se/download/curl-7.51.0.tar.gz)

## protobuf Version

[protobuf.tar.gz](https://github.com/google/protobuf/archive/v3.1.0.tar.gz)

##Android NDK Version

[android-ndk-r13b](https://dl.google.com/android/repository/android-ndk-r13b-darwin-x86_64.zip)

## How to build

### For iOS

Copy `openssl-1.1.0c.tar.gz` to `tools` file folder and run

```
cd tools
sh ./build-openssl4ios.sh
```

Copy `curl-7.51.0.tar.gz` to `tools` file folder and run

```
cd tools
sh ./build-curl4ios.sh
```

### For Android

Set ENV `NDK_ROOT`


```
cd tools
sh ./build-openssl4android.sh
```

You could build it with ABI like

```
cd tools
sh ./build-openssl4android.sh android  # for armeabi
sh ./build-openssl4android.sh android-armeabi #for armeabi-v7a
sh ./build-openssl4android.sh android64-arm64 #for arm64_v8a
sh ./build-openssl4android.sh android-x86  #for x86
sh ./build-openssl4android.sh android64  #for x86_64
sh ./build-openssl4android.sh mips  #for mips
sh ./build-openssl4android.sh mips64 #for mips64
```

> **You must build openssl first**
> 
> **otherwise cURL HTTPS is disable (without ssl)**

OpenSSL for Android is build with `libz` support using dynamic
link. `libz` is publically provided by Android system.

```
sh ./build-curl4android.sh
```

You could build it with ABI like

```
cd tools
sh ./build-curl4android.sh android  # for armeabi
sh ./build-curl4android.sh android-armv7 #for armeabi-v7a
sh ./build-curl4android.sh android64-arm64 #for arm64_v8a
sh ./build-curl4android.sh android-x86  #for x86
sh ./build-curl4android.sh android-x86_64  #for x86_64
sh ./build-curl4android.sh mips  #for mips
sh ./build-curl4android.sh mips64 #for mips64
```

## How to use

### For iOS

Copy `lib/libcrypto.a` and `lib/libssl.a` and `lib/libcurl.a` to your project.

Copy `include/openssl` folder and `include/curl` folder to your project.

Add `libcrypto.a` and `libssl.a` and `libcurl.a` to `Frameworks` group and add them to `[Build Phases]  ====> [Link Binary With Libraries]`.

Add openssl include path and curl include path to your `[Build Settings] ====> [User Header Search Paths]`

### About "\_\_curl\_rule\_01\_\_ declared as an array with a negative size" problem

When you build cURL for arm64 you will get this error.

You need to change `curlbuild.h` from :

```c
#define CURL_SIZEOF_LONG 4
```

to :

```c
#ifdef __LP64__
#define CURL_SIZEOF_LONG 8
#else
#define CURL_SIZEOF_LONG 4
#endif
```

### For Android

Copy `lib/armeabi` folder and `lib/armeabi-v7a` folder and `lib/x86` to your android project `libs` folder.

Copy `include/openssl` folder and `include/curl` to your android project.

#### Android Makefile
Add openssl include path to `jni/Android.mk`. 

```
#Android.mk

include $(CLEAR_VARS)

LOCAL_MODULE := curl
LOCAL_SRC_FILES := Your cURL Library Path/$(TARGET_ARCH_ABI)/libcurl.a
include $(PREBUILT_STATIC_LIBRARY)


LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/Your Openssl Include Path/openssl \
	$(LOCAL_PATH)/Your cURL Include Path/curl

LOCAL_STATIC_LIBRARIES := libcurl

LOCAL_LDLIBS := -lz
	
```

### CMake
Define `ssl`, `crypto`, `curl` as *STATIC IMPORTED* libraries.


```
add_library(crypto STATIC IMPORTED)
set_target_properties(crypto
  PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libcrypto.a)

add_library(ssl STATIC IMPORTED)
set_target_properties(ssl
  PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libssl.a)

add_library(curl STATIC IMPORTED)
set_target_properties(curl
  PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libcurl.a)
```

Then link these libraries with your target, e.g.


```
target_link_libraries( # Specifies the target library.
                       native-lib

                       curl
                       ssl
                       crypto
                       )
```
