#!/bin/bash

# 本地Android构建脚本
# 使用方法: ./scripts/build_android.sh [version] [build_number]

set -e  # 遇到错误立即退出

# 默认版本号
VERSION=${1:-"1.0.0"}
BUILD_NUMBER=${2:-$(date +%s)}

echo "🤖 开始构建Android应用..."
echo "版本: $VERSION"
echo "构建号: $BUILD_NUMBER"

# 检查是否安装了Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: 未找到Flutter，请先安装Flutter SDK"
    exit 1
fi

# 检查是否安装了Java
if ! command -v java &> /dev/null; then
    echo "❌ 错误: 未找到Java，请先安装Java JDK"
    exit 1
fi

echo "🧹 清理之前的构建..."
flutter clean

echo "📦 获取依赖..."
flutter pub get

echo "🔧 检查Android配置..."
flutter doctor

echo "🔑 检查签名配置..."
if [ ! -f "android/key.properties" ]; then
    echo "⚠️  警告: 未找到签名配置文件 android/key.properties"
    echo "   这将使用调试签名构建应用"
    echo "   生产环境请配置正式签名"
fi

echo "🏗️  构建Android应用..."
flutter build apk --release --build-name=$VERSION --build-number=$BUILD_NUMBER

echo "📱 检查构建结果..."
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ Android应用构建成功！"
    echo "📁 APK位置: build/app/outputs/flutter-apk/app-release.apk"
    
    # 显示APK信息
    echo "📋 APK信息:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    
    # 获取APK版本信息
    echo "📊 版本信息:"
    aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep -E "(versionName|versionCode|package)"
    
    echo ""
    echo "🚀 下一步操作:"
    echo "1. 安装到设备: adb install build/app/outputs/flutter-apk/app-release.apk"
    echo "2. 上传到Firebase App Distribution:"
    echo "   firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \\"
    echo "     --app \$FIREBASE_APP_ID --groups testers"
    echo "3. 上传到Google Play Console:"
    echo "   在Google Play Console中创建新版本并上传APK"
    
else
    echo "❌ 构建失败，请检查错误信息"
    exit 1
fi
