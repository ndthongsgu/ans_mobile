import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quán yêu thích')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: 8,
        itemBuilder: (context, i) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(width: 56, height: 56, color: Colors.grey[300]),
                const SizedBox(width: 8),
                Expanded(child: Text('Quán ${i + 1}')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
