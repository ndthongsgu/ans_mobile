import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Thoát ứng dụng?'),
            content: const Text('Bạn có chắc muốn thoát không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Thông báo'), automaticallyImplyLeading: false),
        body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => ListTile(
          leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
          title: Text('Thông báo ${i + 1}'),
          subtitle: Text('Nội dung thông báo...'),
        ),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: 8,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      ),
    );
  }
}
