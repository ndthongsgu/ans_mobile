import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá của tôi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => ListTile(
          title: Text('Quán ${i + 1}'),
          subtitle: Text('★★★★☆ - "Bài đánh giá..."'),
          trailing: PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
              const PopupMenuItem(value: 'delete', child: Text('Xóa')),
            ],
          ),
        ),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: 6,
      ),
    );
  }
}
