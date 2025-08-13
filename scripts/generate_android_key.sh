#!/bin/bash

# Android签名密钥生成脚本
# 使用方法: ./scripts/generate_android_key.sh

set -e  # 遇到错误立即退出

echo "🔑 生成Android签名密钥..."

# 检查是否安装了keytool
if ! command -v keytool &> /dev/null; then
    echo "❌ 错误: 未找到keytool，请先安装Java JDK"
    exit 1
fi

# 创建android目录（如果不存在）
mkdir -p android/app

# 生成密钥库
echo "📝 生成密钥库文件..."
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

echo "✅ 密钥库生成成功！"
echo "📁 密钥库位置: android/app/upload-keystore.jks"

# 生成Base64编码（用于GitHub Secrets）
echo ""
echo "🔐 生成Base64编码（用于GitHub Secrets）:"
echo "ANDROID_KEYSTORE_BASE64:"
base64 -i android/app/upload-keystore.jks

echo ""
echo "📋 下一步操作:"
echo "1. 编辑 android/key.properties 文件，填入正确的密码"
echo "2. 将密钥库密码添加到GitHub Secrets:"
echo "   - ANDROID_KEYSTORE_PASSWORD"
echo "   - ANDROID_KEY_PASSWORD"
echo "   - ANDROID_KEY_ALIAS (通常是 'upload')"
echo "3. 将上面的Base64编码添加到GitHub Secrets:"
echo "   - ANDROID_KEYSTORE_BASE64"
echo ""
echo "⚠️  重要提醒:"
echo "- 请妥善保管密钥库文件和密码"
echo "- 不要将密钥库文件提交到Git仓库"
echo "- 生产环境请使用更安全的密码"
