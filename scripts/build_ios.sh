#!/bin/bash

# 本地iOS构建脚本
# 使用方法: ./scripts/build_ios.sh [version] [build_number]

set -e  # 遇到错误立即退出

# 默认版本号
VERSION=${1:-"1.0.0"}
BUILD_NUMBER=${2:-$(date +%s)}

echo "🍎 开始构建iOS应用..."
echo "版本: $VERSION"
echo "构建号: $BUILD_NUMBER"

# 检查是否在macOS上
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误: iOS构建只能在macOS上进行"
    exit 1
fi

# 检查是否安装了Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: 未找到Flutter，请先安装Flutter SDK"
    exit 1
fi

# 检查是否安装了Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 错误: 未找到Xcode，请先安装Xcode"
    exit 1
fi

echo "🧹 清理之前的构建..."
flutter clean

echo "📦 获取依赖..."
flutter pub get

echo "🔧 检查iOS配置..."
flutter doctor

echo "🏗️  构建iOS应用..."
flutter build ios --release --build-name=$VERSION --build-number=$BUILD_NUMBER

echo "📱 检查构建结果..."
if [ -f "build/ios/iphoneos/Runner.app" ]; then
    echo "✅ iOS应用构建成功！"
    echo "📁 应用位置: build/ios/iphoneos/Runner.app"
    
    # 显示应用信息
    echo "📋 应用信息:"
    plutil -p build/ios/iphoneos/Runner.app/Info.plist | grep -E "(CFBundleShortVersionString|CFBundleVersion|CFBundleDisplayName|CFBundleIdentifier)"
    
    echo ""
    echo "🚀 下一步操作:"
    echo "1. 在Xcode中打开 ios/Runner.xcworkspace"
    echo "2. 选择 'Product' -> 'Archive'"
    echo "3. 在Organizer中上传到App Store Connect"
    echo "4. 或使用 fastlane 自动上传:"
    echo "   gem install fastlane"
    echo "   fastlane pilot upload --ipa path/to/app.ipa"
    
else
    echo "❌ 构建失败，请检查错误信息"
    exit 1
fi
