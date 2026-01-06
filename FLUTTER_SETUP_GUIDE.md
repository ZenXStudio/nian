# Flutter开发环境配置指南

## 概述

本文档提供Flutter客户端的开发环境配置指南，支持Windows、macOS和Linux。

## 系统要求

| 平台 | 最低要求 | 磁盘空间 |
|------|---------|---------|
| Windows | Windows 10 64位 + 开发者模式 | 2.5 GB |
| macOS | macOS 10.14+ | 2.8 GB |
| Linux | Ubuntu 20.04 LTS 64位 | 1 GB |

## 快速安装

### Windows

```powershell
# 1. 开启开发者模式（必须）
start ms-settings:developers
# 在设置中开启"开发者模式"

# 2. 下载Flutter SDK
# https://docs.flutter.dev/get-started/install/windows
# 解压到 C:\src\flutter

# 3. 添加环境变量
# PATH 添加: C:\src\flutter\bin
# 可选镜像源:
# FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
# PUB_HOSTED_URL=https://pub.flutter-io.cn

# 4. 验证
flutter doctor -v
```

### macOS

```bash
# 1. 下载解压
cd ~/development
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.16.0-stable.zip
unzip flutter_macos_arm64_3.16.0-stable.zip

# 2. 配置环境变量 (~/.zshrc)
export PATH="$PATH:$HOME/development/flutter/bin"
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn

source ~/.zshrc

# 3. iOS开发额外配置
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo gem install cocoapods

# 4. 验证
flutter doctor -v
```

### Linux

```bash
# 1. 安装依赖
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

# 2. 下载解压
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz

# 3. 配置环境变量 (~/.bashrc)
export PATH="$PATH:$HOME/flutter/bin"
source ~/.bashrc

# 4. 验证
flutter doctor -v
```

## IDE配置

### VS Code（推荐）

1. 安装 [VS Code](https://code.visualstudio.com/)
2. 安装扩展: Flutter（自动包含Dart）
3. `Ctrl+Shift+P` → "Flutter: Change SDK" → 选择Flutter目录

### Android Studio

1. 安装 [Android Studio](https://developer.android.com/studio)
2. Plugins → 搜索安装 "Flutter"
3. Settings → Languages & Frameworks → Flutter → 设置SDK路径

## 平台配置

### Android

```bash
# 1. 安装Android Studio后配置SDK
# SDK Manager → 安装 Android SDK Platform 33+

# 2. 环境变量
# Windows: ANDROID_HOME=C:\Users\你的用户名\AppData\Local\Android\Sdk
# macOS/Linux: export ANDROID_HOME=$HOME/Library/Android/sdk

# 3. 接受许可
flutter doctor --android-licenses

# 4. 创建模拟器
# Android Studio → AVD Manager → 创建设备
```

### iOS（仅macOS）

```bash
# 1. 安装Xcode（App Store）

# 2. 配置命令行工具
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license

# 3. 安装CocoaPods
sudo gem install cocoapods
# 或: brew install cocoapods

# 4. 启动模拟器
open -a Simulator
```

### Windows桌面

```powershell
# 1. 开启开发者模式
start ms-settings:developers

# 2. 启用Windows桌面支持
flutter config --enable-windows-desktop

# 3. 添加平台支持到项目
flutter create --platforms=windows .
```

### macOS桌面

```bash
flutter config --enable-macos-desktop
flutter create --platforms=macos .
```

### Linux桌面

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
flutter config --enable-linux-desktop
flutter create --platforms=linux .
```

## 项目运行

```bash
cd flutter_app

# 安装依赖
flutter pub get

# 检查可用设备
flutter devices

# 运行（自动选择设备）
flutter run

# 指定平台运行
flutter run -d windows
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

## 常见问题

### Windows: 需要符号链接支持

**解决**: 开启开发者模式
```powershell
start ms-settings:developers
```

### Android许可协议未接受

```bash
flutter doctor --android-licenses
# 按y接受所有
```

### CocoaPods安装失败（macOS）

```bash
brew install cocoapods
# 或
sudo gem install cocoapods
```

### Gradle下载慢（Android）

编辑 `android/build.gradle`:
```gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/public/' }
        maven { url 'https://maven.aliyun.com/repository/google/' }
        google()
        mavenCentral()
    }
}
```

### iOS Pod安装失败

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### 编译时类重复错误

```bash
flutter clean
flutter pub get
```

## 验证清单

运行 `flutter doctor -v`，确保所有项目显示 ✓：

```
[✓] Flutter
[✓] Android toolchain
[✓] Xcode (macOS)
[✓] Chrome
[✓] VS Code
[✓] Connected device
```

## 参考资源

- [Flutter官方文档](https://docs.flutter.dev/)
- [Dart语言指南](https://dart.dev/guides)
- [Flutter中文社区](https://flutter.cn/)
- [Flutter包仓库](https://pub.dev/)

---
**版本**: 1.1.0 | **更新**: 2026-01-06
