Please find the [English version](README.en.md).

这是一个适用于 iOS 平台和 Android 平台的 Openssl 静态链接库。基于 openssl-1.0.2c 版本编译生成。

后来又加入了适用于 iOS 平台和 Android 平台且支持 SSL 的 cURL 静态链接库。基于 curl-7.47.1 版本编译生成。

## 下载

如果你不想自己构建，那么你可以使用我们已经预先构建好的版本，[请在这里下载](https://github.com/leenjewel/openssl_for_ios_and_android/releases/tag/20170105)

## 在 iOS 工程中使用

将 `lib/libcrypto.a` 和 `lib/libssl.a` 还有 `lib/libcurl.a` 三个静态链接库文件拷贝到你的 iOS 工程下面合适的位置。

将 `include/openssl` 文件夹和 `include/curl` 文件夹拷贝到你的 iOS 工程下面合适的位置。注意，所有的头文件均要放置到 `openssl` 文件夹下，不要随意更改文件夹名称。

将 `libcrypto.a` 和 `libssl.a` 还有 `lib/libcurl.a` 三个静态链接库文件通过`[Build Phases]  ====> [Link Binary With Libraries]`引入你的 iOS 工程。

将包含所有头文件的 `openssl` 文件夹和含有头文件的 `curl` 文件夹设置到头文件搜索路径中。即在 `[Build Settings] ====> [User Header Search Paths]` 中设置好。

### 关于 "\_\_curl\_rule\_01\_\_ declared as an array with a negative size" 的问题解决办法

当你在 iOS 的 arm64 架构环境下编译 cURL 静态库时会遇到这个问题。解决的办法是修改 `curlbuild.h` 头文件，将下面这行 :

```c
#define CURL_SIZEOF_LONG 4
```

改成 :

```c
#ifdef __LP64__
#define CURL_SIZEOF_LONG 8
#else
#define CURL_SIZEOF_LONG 4
#endif
```

## 在 Android 工程中使用

将 `lib/armeabi` 和 `lib/armeabi-v7a` 还有 `lib/x86` 文件夹拷贝到你的 Android 工程下面的 `libs` 文件夹中。

将 `include/openssl` 文件夹和 `include/curl` 文件夹拷贝到你的 Android 工程下面合适的位置。注意，所有的头文件均要放置到 `openssl` 文件夹下，不要随意更改文件夹名称。

### Android Makefile 系统

修改 `jni/Android.mk` 文件，将头文件路径加入到搜索路径中，例如：

```
# Android.mk

include $(CLEAR_VARS)

LOCAL_MODULE := curl
LOCAL_SRC_FILES := Your cURL Library Path/$(TARGET_ARCH_ABI)/libcurl.a
include $(PREBUILT_STATIC_LIBRARY)


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

### CMake 系统
把 `ssl`, `crypto`, `curl` 定义成 *STATIC IMPORTED* 库。


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

把它们和你的目标链接，如：


```
target_link_libraries( # Specifies the target library.
                       native-lib

                       curl
                       ssl
                       crypto
                       )
```

## Reference / 参考资料

>[《How-To-Build-openssl-For-iOS》](http://www.cvursache.com/2013/08/13/How-To-Build-openssl-For-iOS/)
>
>[《Compiling the latest OpenSSL for Android》](http://stackoverflow.com/questions/11929773/compiling-the-latest-openssl-for-android)
>
>[《在 Cocos2d-x 中使用 OpenSSL》](http://leenjewel.github.io/blog/2015/06/30/zai-cocos2d-x-zhong-shi-yong-openssl/)
>
>[《using curl on iOS, I am unable to link with multiple architectures, CurlchkszEQ macro failing》](http://stackoverflow.com/questions/21681954/using-curl-on-ios-i-am-unable-to-link-with-multiple-architectures-curlchkszeq)
>
>[《porting libcurl on android with ssl support》](http://stackoverflow.com/questions/11330180/porting-libcurl-on-android-with-ssl-support)
