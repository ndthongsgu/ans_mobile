import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp & Hỗ trợ')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(title: const Text('FAQ'), subtitle: const Text('Câu hỏi thường gặp'), onTap: () {}),
          const Divider(),
          ListTile(title: const Text('Liên hệ hỗ trợ'), onTap: () {}),
          const Divider(),
          ListTile(title: const Text('Báo cáo lỗi'), onTap: () {}),
          const Divider(),
          ListTile(title: const Text('Điều khoản sử dụng'), onTap: () {}),
        ],
      ),
    );
  }
}
