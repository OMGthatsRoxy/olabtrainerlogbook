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

## 许可证

MIT License

## 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱：your-email@example.com
- GitHub Issues：[项目Issues页面]
