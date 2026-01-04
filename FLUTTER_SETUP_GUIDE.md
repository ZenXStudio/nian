# Flutter开发环境配置指南

## 概述

本文档提供了全平台心理自助应用（Nian）Flutter客户端的开发环境配置指南。按照本指南操作，您将能够在Windows、macOS或Linux系统上搭建Flutter开发环境，并运行项目。

## 目录

1. [系统要求](#系统要求)
2. [Flutter SDK安装](#flutter-sdk安装)
3. [开发工具安装](#开发工具安装)
4. [平台配置](#平台配置)
5. [项目初始化](#项目初始化)
6. [验证安装](#验证安装)
7. [常见问题](#常见问题)

## 系统要求

### Windows

- 操作系统：Windows 10或更高版本（64位）
- 磁盘空间：至少2.5 GB（不包括IDE和开发工具）
- Git for Windows 2.x
- PowerShell 5.0或更高版本

### macOS

- 操作系统：macOS 10.14 (Mojave)或更高版本
- 磁盘空间：至少2.8 GB（不包括Xcode和Android Studio）
- Xcode 13或更高版本（用于iOS开发）
- CocoaPods（用于iOS依赖管理）

### Linux

- 操作系统：64位Ubuntu 20.04 LTS或更高版本
- 磁盘空间：至少1 GB
- 开发工具：bash, curl, file, git, mkdir, rm, unzip, which, xz-utils, zip

## Flutter SDK安装

### Windows平台

1. **下载Flutter SDK**

   访问Flutter官网下载页面：https://docs.flutter.dev/get-started/install/windows

   下载最新稳定版Flutter SDK（推荐3.16+）

2. **解压Flutter SDK**

   将下载的zip文件解压到你想安装Flutter的位置，例如：
   ```
   C:\src\flutter
   ```

   ⚠️ 注意：不要将Flutter安装到需要管理员权限的目录（如C:\Program Files\）

3. **配置环境变量**

   将Flutter的bin目录添加到系统PATH中：
   - 打开"系统属性" → "高级" → "环境变量"
   - 在"用户变量"中找到"Path"，点击"编辑"
   - 添加Flutter的bin目录完整路径，例如：`C:\src\flutter\bin`

4. **配置镜像源（可选，提升国内下载速度）**

   在用户环境变量中添加：
   ```
   FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   PUB_HOSTED_URL=https://pub.flutter-io.cn
   ```

### macOS平台

1. **下载Flutter SDK**

   使用终端下载：
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip
   unzip flutter_macos_3.16.0-stable.zip
   ```

   或从官网下载：https://docs.flutter.dev/get-started/install/macos

2. **配置环境变量**

   编辑shell配置文件（bash使用`~/.bash_profile`，zsh使用`~/.zshrc`）：
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```

   然后执行：
   ```bash
   source ~/.zshrc  # 或 source ~/.bash_profile
   ```

3. **配置镜像源（可选）**

   在shell配置文件中添加：
   ```bash
   export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   export PUB_HOSTED_URL=https://pub.flutter-io.cn
   ```

### Linux平台

1. **下载Flutter SDK**

   ```bash
   cd ~
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
   tar xf flutter_linux_3.16.0-stable.tar.xz
   ```

2. **配置环境变量**

   编辑`~/.bashrc`或`~/.zshrc`：
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```

   执行：
   ```bash
   source ~/.bashrc
   ```

3. **安装依赖**

   ```bash
   sudo apt-get update
   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
   ```

## 开发工具安装

### VS Code（推荐）

1. **下载安装VS Code**

   访问：https://code.visualstudio.com/

2. **安装Flutter和Dart插件**

   - 打开VS Code
   - 按`Ctrl+Shift+X`（macOS: `Cmd+Shift+X`）打开扩展面板
   - 搜索并安装以下插件：
     - Flutter（会自动安装Dart插件）
     - Flutter Widget Snippets（可选，提供代码片段）
     - Awesome Flutter Snippets（可选）

3. **配置Flutter SDK路径**

   - 按`Ctrl+Shift+P`（macOS: `Cmd+Shift+P`）
   - 输入"Flutter: Change SDK"
   - 选择Flutter SDK安装目录

### Android Studio（可选）

1. **下载安装Android Studio**

   访问：https://developer.android.com/studio

2. **安装Flutter和Dart插件**

   - 打开Android Studio
   - 进入"Settings/Preferences" → "Plugins"
   - 搜索并安装"Flutter"插件（会自动安装Dart插件）

3. **配置Flutter SDK**

   - 打开"Settings/Preferences" → "Languages & Frameworks" → "Flutter"
   - 设置Flutter SDK路径

## 平台配置

### Android配置

1. **安装Android Studio和SDK**

   如果还未安装，请先安装Android Studio

2. **配置Android SDK**

   打开Android Studio的SDK Manager：
   - 确保安装了Android SDK Platform 33或更高版本
   - 确保安装了Android SDK Build-Tools
   - 确保安装了Android SDK Command-line Tools
   - 确保安装了Android Emulator

3. **配置环境变量**

   Windows（添加到系统环境变量）：
   ```
   ANDROID_HOME=C:\Users\你的用户名\AppData\Local\Android\Sdk
   ```

   macOS/Linux（添加到shell配置文件）：
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
   # 或
   export ANDROID_HOME=$HOME/Android/Sdk  # Linux
   
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/tools
   ```

4. **接受Android许可协议**

   ```bash
   flutter doctor --android-licenses
   ```

5. **创建Android虚拟设备（AVD）**

   - 打开Android Studio
   - 点击"AVD Manager"
   - 创建新的虚拟设备（推荐Pixel 5或更新的设备）
   - 选择系统镜像（推荐API 33或更高）

### iOS配置（仅macOS）

1. **安装Xcode**

   - 从Mac App Store安装Xcode（13或更高版本）
   - 安装后首次运行Xcode以完成安装

2. **安装Xcode命令行工具**

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **接受Xcode许可协议**

   ```bash
   sudo xcodebuild -license
   ```

4. **安装CocoaPods**

   ```bash
   sudo gem install cocoapods
   ```

5. **配置iOS模拟器**

   打开Xcode并启动模拟器：
   ```bash
   open -a Simulator
   ```

### macOS桌面应用配置（仅macOS）

启用macOS桌面开发：
```bash
flutter config --enable-macos-desktop
```

### Windows桌面应用配置（仅Windows）

启用Windows桌面开发：
```powershell
flutter config --enable-windows-desktop
```

### Linux桌面应用配置（仅Linux）

1. **安装依赖**

   ```bash
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

2. **启用Linux桌面开发**

   ```bash
   flutter config --enable-linux-desktop
   ```

## 项目初始化

### 克隆项目（当Flutter应用准备好后）

```bash
cd ~/projects
git clone <repository-url>
cd nian/flutter_app
```

### 安装依赖

```bash
flutter pub get
```

### 配置环境变量

在项目根目录创建`.env`文件（参考`.env.example`）：

```env
API_BASE_URL=http://localhost:3000/api
API_TIMEOUT=30000
ENABLE_LOGGING=true
```

### 生成必要的代码文件

如果项目使用代码生成（如json_serializable），运行：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 验证安装

### 运行Flutter Doctor

运行以下命令检查环境配置：

```bash
flutter doctor -v
```

输出示例：
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.0, on macOS 14.0)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.0)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85.0)
[✓] Connected device (3 available)
```

解决所有标记为`[!]`或`[✗]`的问题。

### 测试运行

1. **创建测试项目**

   ```bash
   flutter create test_app
   cd test_app
   ```

2. **列出可用设备**

   ```bash
   flutter devices
   ```

3. **运行测试项目**

   Android设备/模拟器：
   ```bash
   flutter run
   ```

   iOS模拟器（仅macOS）：
   ```bash
   flutter run -d ios
   ```

   Chrome浏览器：
   ```bash
   flutter run -d chrome
   ```

   Windows桌面：
   ```bash
   flutter run -d windows
   ```

## 常见问题

### 1. Android许可协议问题

**问题**：运行`flutter doctor`时提示"Android licenses not accepted"

**解决方案**：
```bash
flutter doctor --android-licenses
```
按`y`接受所有许可协议。

### 2. Xcode版本过低（macOS）

**问题**：`flutter doctor`提示Xcode版本过低

**解决方案**：
- 从Mac App Store更新Xcode到最新版本
- 重新运行`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

### 3. CocoaPods安装失败（macOS）

**问题**：安装CocoaPods时出错

**解决方案**：
```bash
# 使用Homebrew安装
brew install cocoapods

# 或升级Ruby版本
brew install ruby
```

### 4. Flutter SDK下载缓慢

**问题**：在中国大陆地区下载Flutter SDK很慢

**解决方案**：使用镜像源（见上文"配置镜像源"部分）

### 5. Android模拟器无法启动

**问题**：Android Emulator启动失败

**解决方案**：
- 确保已启用硬件虚拟化（Intel VT-x或AMD-V）
- 在BIOS中启用虚拟化技术
- 确保Hyper-V未与Android Emulator冲突（Windows）

### 6. VS Code无法找到Flutter SDK

**问题**：VS Code提示找不到Flutter SDK

**解决方案**：
- 按`Ctrl+Shift+P`，输入"Flutter: Change SDK"
- 手动选择Flutter SDK安装目录
- 或在VS Code设置中添加：
  ```json
  "dart.flutterSdkPath": "/path/to/flutter"
  ```

### 7. Gradle构建失败（Android）

**问题**：首次构建Android应用时Gradle下载失败

**解决方案**：
- 配置Gradle镜像源
- 编辑`android/build.gradle`，添加：
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

### 8. iOS构建失败 - Pod Install Error

**问题**：运行iOS应用时CocoaPods依赖安装失败

**解决方案**：
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

## 性能优化建议

### 1. 启用Web支持（如需要）

```bash
flutter config --enable-web
```

### 2. 使用镜像源加速（中国大陆）

在shell配置文件中添加：
```bash
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

### 3. 配置IDE性能

**VS Code**：
- 启用Dart分析缓存
- 禁用不必要的扩展

**Android Studio**：
- 增加IDE内存：Help → Edit Custom VM Options
  ```
  -Xms512m
  -Xmx2048m
  ```

### 4. 模拟器性能优化

- 使用硬件加速（HAXM/KVM）
- 分配足够的RAM（建议2GB+）
- 启用GPU加速

## 下一步

环境配置完成后，您可以：

1. 查看[Flutter开发规范文档](FLUTTER_DEVELOPMENT_GUIDE.md)
2. 了解项目架构和代码组织
3. 开始开发功能模块
4. 运行测试和调试

## 参考资源

- [Flutter官方文档](https://docs.flutter.dev/)
- [Dart语言指南](https://dart.dev/guides)
- [Flutter中文社区](https://flutter.cn/)
- [Flutter包仓库](https://pub.dev/)
- [Flutter示例应用](https://github.com/flutter/samples)

## 技术支持

如遇到问题，请：
1. 查阅本文档的"常见问题"部分
2. 运行`flutter doctor -v`查看详细诊断信息
3. 访问Flutter官方文档
4. 联系项目技术团队

---

**文档版本**：1.0.0  
**最后更新**：2024-12-31  
**维护者**：Mental App Team
# Flutter开发环境配置指南

## 概述

本文档提供了全平台心理自助应用（Nian）Flutter客户端的开发环境配置指南。按照本指南操作，您将能够在Windows、macOS或Linux系统上搭建Flutter开发环境，并运行项目。

## 目录

1. [系统要求](#系统要求)
2. [Flutter SDK安装](#flutter-sdk安装)
3. [开发工具安装](#开发工具安装)
4. [平台配置](#平台配置)
5. [项目初始化](#项目初始化)
6. [验证安装](#验证安装)
7. [常见问题](#常见问题)

## 系统要求

### Windows

- 操作系统：Windows 10或更高版本（64位）
- 磁盘空间：至少2.5 GB（不包括IDE和开发工具）
- Git for Windows 2.x
- PowerShell 5.0或更高版本

### macOS

- 操作系统：macOS 10.14 (Mojave)或更高版本
- 磁盘空间：至少2.8 GB（不包括Xcode和Android Studio）
- Xcode 13或更高版本（用于iOS开发）
- CocoaPods（用于iOS依赖管理）

### Linux

- 操作系统：64位Ubuntu 20.04 LTS或更高版本
- 磁盘空间：至少1 GB
- 开发工具：bash, curl, file, git, mkdir, rm, unzip, which, xz-utils, zip

## Flutter SDK安装

### Windows平台

1. **下载Flutter SDK**

   访问Flutter官网下载页面：https://docs.flutter.dev/get-started/install/windows

   下载最新稳定版Flutter SDK（推荐3.16+）

2. **解压Flutter SDK**

   将下载的zip文件解压到你想安装Flutter的位置，例如：
   ```
   C:\src\flutter
   ```

   ⚠️ 注意：不要将Flutter安装到需要管理员权限的目录（如C:\Program Files\）

3. **配置环境变量**

   将Flutter的bin目录添加到系统PATH中：
   - 打开"系统属性" → "高级" → "环境变量"
   - 在"用户变量"中找到"Path"，点击"编辑"
   - 添加Flutter的bin目录完整路径，例如：`C:\src\flutter\bin`

4. **配置镜像源（可选，提升国内下载速度）**

   在用户环境变量中添加：
   ```
   FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   PUB_HOSTED_URL=https://pub.flutter-io.cn
   ```

### macOS平台

1. **下载Flutter SDK**

   使用终端下载：
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip
   unzip flutter_macos_3.16.0-stable.zip
   ```

   或从官网下载：https://docs.flutter.dev/get-started/install/macos

2. **配置环境变量**

   编辑shell配置文件（bash使用`~/.bash_profile`，zsh使用`~/.zshrc`）：
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```

   然后执行：
   ```bash
   source ~/.zshrc  # 或 source ~/.bash_profile
   ```

3. **配置镜像源（可选）**

   在shell配置文件中添加：
   ```bash
   export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   export PUB_HOSTED_URL=https://pub.flutter-io.cn
   ```

### Linux平台

1. **下载Flutter SDK**

   ```bash
   cd ~
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
   tar xf flutter_linux_3.16.0-stable.tar.xz
   ```

2. **配置环境变量**

   编辑`~/.bashrc`或`~/.zshrc`：
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```

   执行：
   ```bash
   source ~/.bashrc
   ```

3. **安装依赖**

   ```bash
   sudo apt-get update
   sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
   ```

## 开发工具安装

### VS Code（推荐）

1. **下载安装VS Code**

   访问：https://code.visualstudio.com/

2. **安装Flutter和Dart插件**

   - 打开VS Code
   - 按`Ctrl+Shift+X`（macOS: `Cmd+Shift+X`）打开扩展面板
   - 搜索并安装以下插件：
     - Flutter（会自动安装Dart插件）
     - Flutter Widget Snippets（可选，提供代码片段）
     - Awesome Flutter Snippets（可选）

3. **配置Flutter SDK路径**

   - 按`Ctrl+Shift+P`（macOS: `Cmd+Shift+P`）
   - 输入"Flutter: Change SDK"
   - 选择Flutter SDK安装目录

### Android Studio（可选）

1. **下载安装Android Studio**

   访问：https://developer.android.com/studio

2. **安装Flutter和Dart插件**

   - 打开Android Studio
   - 进入"Settings/Preferences" → "Plugins"
   - 搜索并安装"Flutter"插件（会自动安装Dart插件）

3. **配置Flutter SDK**

   - 打开"Settings/Preferences" → "Languages & Frameworks" → "Flutter"
   - 设置Flutter SDK路径

## 平台配置

### Android配置

1. **安装Android Studio和SDK**

   如果还未安装，请先安装Android Studio

2. **配置Android SDK**

   打开Android Studio的SDK Manager：
   - 确保安装了Android SDK Platform 33或更高版本
   - 确保安装了Android SDK Build-Tools
   - 确保安装了Android SDK Command-line Tools
   - 确保安装了Android Emulator

3. **配置环境变量**

   Windows（添加到系统环境变量）：
   ```
   ANDROID_HOME=C:\Users\你的用户名\AppData\Local\Android\Sdk
   ```

   macOS/Linux（添加到shell配置文件）：
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
   # 或
   export ANDROID_HOME=$HOME/Android/Sdk  # Linux
   
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/tools
   ```

4. **接受Android许可协议**

   ```bash
   flutter doctor --android-licenses
   ```

5. **创建Android虚拟设备（AVD）**

   - 打开Android Studio
   - 点击"AVD Manager"
   - 创建新的虚拟设备（推荐Pixel 5或更新的设备）
   - 选择系统镜像（推荐API 33或更高）

### iOS配置（仅macOS）

1. **安装Xcode**

   - 从Mac App Store安装Xcode（13或更高版本）
   - 安装后首次运行Xcode以完成安装

2. **安装Xcode命令行工具**

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **接受Xcode许可协议**

   ```bash
   sudo xcodebuild -license
   ```

4. **安装CocoaPods**

   ```bash
   sudo gem install cocoapods
   ```

5. **配置iOS模拟器**

   打开Xcode并启动模拟器：
   ```bash
   open -a Simulator
   ```

### macOS桌面应用配置（仅macOS）

启用macOS桌面开发：
```bash
flutter config --enable-macos-desktop
```

### Windows桌面应用配置（仅Windows）

启用Windows桌面开发：
```powershell
flutter config --enable-windows-desktop
```

### Linux桌面应用配置（仅Linux）

1. **安装依赖**

   ```bash
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

2. **启用Linux桌面开发**

   ```bash
   flutter config --enable-linux-desktop
   ```

## 项目初始化

### 克隆项目（当Flutter应用准备好后）

```bash
cd ~/projects
git clone <repository-url>
cd nian/flutter_app
```

### 安装依赖

```bash
flutter pub get
```

### 配置环境变量

在项目根目录创建`.env`文件（参考`.env.example`）：

```env
API_BASE_URL=http://localhost:3000/api
API_TIMEOUT=30000
ENABLE_LOGGING=true
```

### 生成必要的代码文件

如果项目使用代码生成（如json_serializable），运行：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 验证安装

### 运行Flutter Doctor

运行以下命令检查环境配置：

```bash
flutter doctor -v
```

输出示例：
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.0, on macOS 14.0)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.0)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85.0)
[✓] Connected device (3 available)
```

解决所有标记为`[!]`或`[✗]`的问题。

### 测试运行

1. **创建测试项目**

   ```bash
   flutter create test_app
   cd test_app
   ```

2. **列出可用设备**

   ```bash
   flutter devices
   ```

3. **运行测试项目**

   Android设备/模拟器：
   ```bash
   flutter run
   ```

   iOS模拟器（仅macOS）：
   ```bash
   flutter run -d ios
   ```

   Chrome浏览器：
   ```bash
   flutter run -d chrome
   ```

   Windows桌面：
   ```bash
   flutter run -d windows
   ```

## 常见问题

### 1. Android许可协议问题

**问题**：运行`flutter doctor`时提示"Android licenses not accepted"

**解决方案**：
```bash
flutter doctor --android-licenses
```
按`y`接受所有许可协议。

### 2. Xcode版本过低（macOS）

**问题**：`flutter doctor`提示Xcode版本过低

**解决方案**：
- 从Mac App Store更新Xcode到最新版本
- 重新运行`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

### 3. CocoaPods安装失败（macOS）

**问题**：安装CocoaPods时出错

**解决方案**：
```bash
# 使用Homebrew安装
brew install cocoapods

# 或升级Ruby版本
brew install ruby
```

### 4. Flutter SDK下载缓慢

**问题**：在中国大陆地区下载Flutter SDK很慢

**解决方案**：使用镜像源（见上文"配置镜像源"部分）

### 5. Android模拟器无法启动

**问题**：Android Emulator启动失败

**解决方案**：
- 确保已启用硬件虚拟化（Intel VT-x或AMD-V）
- 在BIOS中启用虚拟化技术
- 确保Hyper-V未与Android Emulator冲突（Windows）

### 6. VS Code无法找到Flutter SDK

**问题**：VS Code提示找不到Flutter SDK

**解决方案**：
- 按`Ctrl+Shift+P`，输入"Flutter: Change SDK"
- 手动选择Flutter SDK安装目录
- 或在VS Code设置中添加：
  ```json
  "dart.flutterSdkPath": "/path/to/flutter"
  ```

### 7. Gradle构建失败（Android）

**问题**：首次构建Android应用时Gradle下载失败

**解决方案**：
- 配置Gradle镜像源
- 编辑`android/build.gradle`，添加：
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

### 8. iOS构建失败 - Pod Install Error

**问题**：运行iOS应用时CocoaPods依赖安装失败

**解决方案**：
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

## 性能优化建议

### 1. 启用Web支持（如需要）

```bash
flutter config --enable-web
```

### 2. 使用镜像源加速（中国大陆）

在shell配置文件中添加：
```bash
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

### 3. 配置IDE性能

**VS Code**：
- 启用Dart分析缓存
- 禁用不必要的扩展

**Android Studio**：
- 增加IDE内存：Help → Edit Custom VM Options
  ```
  -Xms512m
  -Xmx2048m
  ```

### 4. 模拟器性能优化

- 使用硬件加速（HAXM/KVM）
- 分配足够的RAM（建议2GB+）
- 启用GPU加速

## 下一步

环境配置完成后，您可以：

1. 查看[Flutter开发规范文档](FLUTTER_DEVELOPMENT_GUIDE.md)
2. 了解项目架构和代码组织
3. 开始开发功能模块
4. 运行测试和调试

## 参考资源

- [Flutter官方文档](https://docs.flutter.dev/)
- [Dart语言指南](https://dart.dev/guides)
- [Flutter中文社区](https://flutter.cn/)
- [Flutter包仓库](https://pub.dev/)
- [Flutter示例应用](https://github.com/flutter/samples)

## 技术支持

如遇到问题，请：
1. 查阅本文档的"常见问题"部分
2. 运行`flutter doctor -v`查看详细诊断信息
3. 访问Flutter官方文档
4. 联系项目技术团队

---

**文档版本**：1.0.0  
**最后更新**：2024-12-31  
**维护者**：Mental App Team
