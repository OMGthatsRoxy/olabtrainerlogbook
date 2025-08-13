#!/bin/bash

# 本地一键部署到Vercel脚本
# 使用方法: ./scripts/local_deploy_vercel.sh

set -e  # 遇到错误立即退出

echo "🚀 开始本地部署到Vercel..."

# 检查VERCEL_TOKEN环境变量
if [ -z "$VERCEL_TOKEN" ]; then
    echo "❌ 错误: 请设置VERCEL_TOKEN环境变量"
    echo "   获取方法: 访问 https://vercel.com/account/tokens"
    echo "   设置方法: export VERCEL_TOKEN=your_token_here"
    exit 1
fi

# 检查是否安装了Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: 未找到Flutter，请先安装Flutter SDK"
    exit 1
fi

# 检查是否安装了Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "📦 安装Vercel CLI..."
    npm install -g vercel@latest
fi

echo "🧹 清理之前的构建..."
flutter clean

echo "📦 获取依赖..."
flutter pub get

echo "🏗️  构建Web应用..."
flutter build web --release

echo "📝 复制vercel.json配置..."
cp vercel.json build/web/vercel.json

echo "🚀 部署到Vercel..."
vercel --cwd build/web --prod --yes --token "$VERCEL_TOKEN"

echo "✅ 部署完成！"
echo "🌐 访问地址: https://olabtrainerlogbook.vercel.app"
