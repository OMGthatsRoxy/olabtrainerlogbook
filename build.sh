#!/bin/bash

# 确保Flutter已安装
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter..."
    # 这里可以添加Flutter安装逻辑
    exit 1
fi

# 获取依赖
flutter pub get

# 构建Web应用
flutter build web --release --web-renderer canvaskit

echo "Build completed successfully!"
