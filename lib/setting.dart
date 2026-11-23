import 'package:flutter/material.dart';
import 'package:shop_easy/login.dart';
import 'package:shop_easy/dashboard.dart';
import 'main.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool isNotificationOn = true;
  bool rememberLogin = true;

  String selectedLanguage = 'Tiếng Việt';

  void _showLanguageDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chọn ngôn ngữ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tiếng Việt'),
                leading: Icon(
                  selectedLanguage == 'Tiếng Việt'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: primaryColor,
                ),
                onTap: () {
                  setState(() {
                    selectedLanguage = 'Tiếng Việt';
                  });
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('English'),
                leading: Icon(
                  selectedLanguage == 'English'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: primaryColor,
                ),
                onTap: () {
                  setState(() {
                    selectedLanguage = 'English';
                  });
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        backgroundColor: isDark ? const Color(0xFF1A1A26) : Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Ứng dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Nhận thông báo'),
            value: isNotificationOn,
            onChanged: (value) {
              setState(() {
                isNotificationOn = value;
              });
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Chế độ tối'),
                value: currentMode == ThemeMode.dark,
                onChanged: (value) {
                  themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: const Text('Nhớ đăng nhập'),
            value: rememberLogin,
            onChanged: (value) {
              setState(() {
                rememberLogin = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Ngôn ngữ'),
            subtitle: Text(selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLanguageDialog,
          ),
          ListTile(
            leading: const Icon(Icons.format_size_outlined),
            title: const Text('Cỡ chữ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Tổng quan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Về ứng dụng'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
