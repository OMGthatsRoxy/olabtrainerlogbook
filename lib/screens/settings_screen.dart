import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = '中文';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('账户设置'),
          _buildMenuItem('个人信息', Icons.person, () {
            // TODO: 导航到个人信息页面
          }),
          _buildMenuItem('修改密码', Icons.lock, () {
            // TODO: 导航到修改密码页面
          }),
          _buildSectionHeader('应用设置'),
          _buildSwitchItem('推送通知', Icons.notifications, _notificationsEnabled, (
            value,
          ) {
            setState(() {
              _notificationsEnabled = value;
            });
          }),
          _buildSwitchItem('深色模式', Icons.dark_mode, _darkModeEnabled, (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          }),
          _buildDropdownItem(
            '语言设置',
            Icons.language,
            _selectedLanguage,
            ['中文', 'English'],
            (value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
          ),
          _buildSectionHeader('数据管理'),
          _buildMenuItem('数据备份', Icons.backup, () {
            // TODO: 数据备份功能
          }),
          _buildMenuItem('数据恢复', Icons.restore, () {
            // TODO: 数据恢复功能
          }),
          _buildMenuItem('清除缓存', Icons.clear_all, () {
            _showClearCacheDialog();
          }),
          _buildSectionHeader('关于'),
          _buildMenuItem('版本信息', Icons.info, () {
            _showVersionInfo();
          }),
          _buildMenuItem('用户协议', Icons.description, () {
            // TODO: 显示用户协议
          }),
          _buildMenuItem('隐私政策', Icons.privacy_tip, () {
            // TODO: 显示隐私政策
          }),
          _buildMenuItem('联系我们', Icons.contact_support, () {
            // TODO: 联系我们功能
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF667eea),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF667eea)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF667eea)),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF667eea),
      ),
    );
  }

  Widget _buildDropdownItem(
    String title,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF667eea)),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: Container(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗？这将释放一些存储空间。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存已清除'),
                  backgroundColor: Color(0xFF667eea),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('版本信息'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用名称: 健身教练日志'),
            Text('版本号: 1.0.0'),
            Text('构建号: 1'),
            SizedBox(height: 16),
            Text('© 2024 健身教练日志. 保留所有权利。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
