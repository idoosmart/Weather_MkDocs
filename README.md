# IDOWeatherSDK

基于 Kotlin Multiplatform 的天气 SDK，支持 Android 和 iOS 平台。

## 功能特性

- ✅ 跨平台支持 (Android AAR, iOS Framework)
- ✅ 单例模式，简单易用
- ✅ 返回原始 JSON 响应 (便于自定义解析)
- ✅ 网络请求重试机制 (指数退避)
- ✅ 请求超时处理
- ✅ 请求频率限制
- ✅ 完善的错误处理

## 项目结构

```
IDOWeatherSDK/
├── library/                    # SDK 核心库
│   └── src/
│       ├── commonMain/         # 公共代码
│       ├── androidMain/        # Android 平台代码
│       └── iosMain/            # iOS 平台代码
├── example-android/            # Android 示例应用
└── example-ios/                # iOS 示例应用
```

## 构建

### 前置条件

- JDK 17+
- Android SDK (compileSdk 34)
- Xcode 15+ (用于 iOS)

### 构建 Android AAR

```bash
./gradlew :library:assembleRelease
```

输出: `library/build/outputs/aar/library-release.aar`

### 构建 iOS Framework

```bash
./gradlew :library:linkReleaseFrameworkIosArm64
# 或构建 Fat Framework (包含多架构)
./gradlew :library:assembleFatFramework
```

输出: `library/build/fat-framework/release/IDOWeatherSDK.framework`

### 构建示例应用

```bash
# Android
./gradlew :example-android:assembleDebug

# iOS (使用 Xcode 打开)
open example-ios/IDOWeatherExample.xcodeproj
```

## 使用方法

详细使用文档请参考 [使用指南](usage.md)。

