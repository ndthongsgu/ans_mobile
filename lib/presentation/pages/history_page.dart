import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';
class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

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
        appBar: AppBar(title: const Text('Lịch sử nghe'), automaticallyImplyLeading: false),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(child: Icon(Icons.music_note)),
            title: Text('Track ${i + 1}'),
            subtitle: Text('Nghe ${i + 1} giờ trước'),
            trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: 12,
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      ),
    );
  }
}
