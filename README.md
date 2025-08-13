# Trainer Logbook - 教练日志管理系统

一个专为健身教练设计的跨平台应用，支持iOS、Android和Web平台。

## 功能特性

- 🔐 用户认证系统
- 👥 学员管理
- 💪 课程记录
- 📈 进度跟踪
- 📊 数据统计
- ⚙️ 系统设置

## 开发环境配置

### 系统要求
- Flutter SDK 3.8.1+
- Dart SDK
- iOS开发需要Xcode
- Android开发需要Android Studio

### 安装步骤

1. 克隆项目
```bash
git clone <repository-url>
cd trainerlogbook
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用

**在iOS设备上运行：**
```bash
flutter run -d ios
```

**在Android设备上运行：**
```bash
flutter run -d android
```

**在Web浏览器中运行：**
```bash
flutter run -d chrome
```

## 测试账号

为了演示目的，应用提供了以下测试账号：

- **用户名：** admin
- **密码：** 123456

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── screens/               # 页面
│   ├── login_screen.dart  # 登录页面
│   └── home_screen.dart   # 主页面
├── services/              # 服务层
│   └── auth_service.dart  # 认证服务
├── models/                # 数据模型
├── widgets/               # 自定义组件
└── utils/                 # 工具类
```

## 技术栈

- **框架：** Flutter
- **状态管理：** Provider
- **本地存储：** SharedPreferences
- **HTTP请求：** http
- **表单验证：** form_validator

## 开发说明

### 热重载
在开发过程中，您可以使用热重载功能快速查看更改：
- 保存文件后，应用会自动重新加载
- 或者按 `r` 键手动触发热重载

### 调试
- 使用 `flutter doctor` 检查环境配置
- 使用 `flutter devices` 查看可用设备
- 使用 `flutter logs` 查看应用日志

## 下一步开发计划

- [ ] 实现真实的API接口
- [ ] 添加学员管理功能
- [ ] 实现课程记录系统
- [ ] 添加数据可视化
- [ ] 实现推送通知
- [ ] 添加离线支持

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## CI 自动部署到 Vercel

本项目使用 GitHub Actions 自动部署 Flutter Web 应用到 Vercel。每次推送到 `main` 分支时，会自动构建并部署到生产环境。

### 配置要求

#### 1. GitHub Secrets 设置

在 GitHub 仓库设置中添加以下 Secret：

- **VERCEL_TOKEN**: 从 Vercel Dashboard 生成的 Token
  - 获取方法：访问 [Vercel Account Tokens](https://vercel.com/account/tokens)
  - 创建新的 Token 并复制到 GitHub Secrets

#### 2. 首次本地绑定（推荐）

```bash
# 安装 Vercel CLI
npm install -g vercel

# 登录 Vercel
vercel login

# 链接项目（仅第一次需要）
vercel link
# 选择现有项目或创建新项目
```

### 部署流程

#### 自动部署
- 推送代码到 `main` 分支时自动触发
- GitHub Actions 会执行以下步骤：
  1. 安装 Flutter SDK
  2. 获取依赖 (`flutter pub get`)
  3. 构建 Web 应用 (`flutter build web --release`)
  4. 生成 `vercel.json` 配置
  5. 使用 Vercel CLI 部署到生产环境

#### 手动触发
1. 访问 GitHub 仓库的 Actions 页面
2. 选择 `deploy-vercel` 工作流
3. 点击 "Run workflow" 手动触发部署

### 本地一键部署

项目提供了本地部署脚本，方便快速部署：

```bash
# 设置 Vercel Token
export VERCEL_TOKEN=your_token_here

# 执行本地部署
./scripts/local_deploy_vercel.sh
```

### 访问地址

- **主域名**: https://olabtrainerlogbook.vercel.app
- **团队域名**: https://olabtrainerlogbook-omgs-projects-ad9f92cb.vercel.app

### Firebase Auth 配置

如果使用 Firebase Authentication，记得在 Firebase Console 的 Authorized domains 中添加：
- 您的自定义域名（如果有）
- `*.vercel.app`（允许所有 Vercel 子域名）

### 故障排除

1. **构建失败**: 检查 GitHub Actions 日志
2. **部署失败**: 确认 VERCEL_TOKEN 是否正确设置
3. **404 错误**: 检查 `vercel.json` 配置是否正确

## iOS 部署到 TestFlight

本项目支持自动构建iOS应用并上传到TestFlight进行测试分发。

### 配置要求

#### 1. Apple Developer 账户
- 需要有效的 Apple Developer 账户
- 在 App Store Connect 中创建应用

#### 2. GitHub Secrets 设置

在 GitHub 仓库设置中添加以下 Secrets：

- **IOS_P12_BASE64**: iOS分发证书的Base64编码
- **IOS_P12_PASSWORD**: iOS分发证书密码
- **APPSTORE_ISSUER_ID**: App Store Connect API Issuer ID
- **APPSTORE_API_KEY_ID**: App Store Connect API Key ID
- **APPSTORE_API_PRIVATE_KEY**: App Store Connect API Private Key
- **APPSTORE_CONNECT_USERNAME**: App Store Connect 用户名
- **APPSTORE_CONNECT_APP_SPECIFIC_PASSWORD**: App Store Connect 应用专用密码
- **APPSTORE_TEAM_ID**: Apple Developer Team ID

#### 3. 证书和配置文件设置

1. **创建分发证书**：
   ```bash
   # 在Xcode中创建分发证书
   # 或使用命令行
   security create-keychain -p "password" build.keychain
   security import certificate.p12 -k build.keychain -P "password" -T /usr/bin/codesign
   ```

2. **配置Fastlane**：
   ```bash
   cd ios
   gem install fastlane
   fastlane init
   # 编辑 fastlane/Appfile 和 fastlane/Fastfile
   ```

### 部署流程

#### 自动部署
- 推送代码到 `main` 分支时自动触发构建
- 创建版本标签时自动上传到TestFlight：
  ```bash
  git tag v1.0.0
  git push origin v1.0.0
  ```

#### 手动触发
1. 访问 GitHub 仓库的 Actions 页面
2. 选择 `build-ios` 工作流
3. 点击 "Run workflow" 并输入版本信息

#### 本地构建
```bash
# 构建iOS应用
./scripts/build_ios.sh 1.0.0 1

# 使用Fastlane上传到TestFlight
cd ios
fastlane beta
```

### 访问TestFlight
- 在App Store Connect中查看构建状态
- 通过TestFlight应用下载测试版本
- 邀请测试用户进行测试

### 故障排除

1. **证书问题**: 检查证书是否过期，重新生成证书
2. **配置文件问题**: 确保Bundle ID匹配
3. **构建失败**: 检查Xcode版本和Flutter兼容性
4. **上传失败**: 检查App Store Connect API权限

## 许可证

MIT License

## 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱：your-email@example.com
- GitHub Issues：[项目Issues页面]
