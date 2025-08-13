# Flutter Web 应用部署指南

## 项目信息
- **项目名称**: 健身教练客户管理系统
- **技术栈**: Flutter Web + Firebase
- **部署平台**: Vercel

## 部署步骤

### 1. 本地构建
```bash
flutter build web --release
```

### 2. Vercel部署
1. 将项目推送到GitHub仓库
2. 在Vercel中导入项目
3. 设置构建配置：
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`

### 3. 环境变量配置
在Vercel项目设置中添加以下环境变量（如果需要）：
- `FIREBASE_API_KEY`: AIzaSyCibaFjlPVFArgWh-dYeW33NZ7zOUHH1rk
- `FIREBASE_PROJECT_ID`: ftrainerlogbook
- `FIREBASE_AUTH_DOMAIN`: ftrainerlogbook.firebaseapp.com

### 4. 域名配置
1. 在Vercel项目设置中添加自定义域名
2. 配置DNS记录指向Vercel

## 文件结构
```
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── services/
│   ├── models/
│   └── screens/
├── build/web/          # 构建输出目录
├── vercel.json         # Vercel配置
└── pubspec.yaml        # 依赖配置
```

## 注意事项
- Firebase配置已包含在代码中，无需额外配置
- 应用使用Firebase Authentication和Firestore
- 支持实时数据同步
- 响应式设计，适配移动端和桌面端

## 故障排除
1. 如果构建失败，检查Flutter版本和依赖
2. 如果Firebase连接失败，检查网络和配置
3. 如果路由问题，检查vercel.json配置
