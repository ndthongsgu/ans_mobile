import 'package:flutter/material.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tải xuống')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => ListTile(
          leading: Icon(Icons.audiotrack, color: Theme.of(context).colorScheme.primary),
          title: Text('Track ${i + 1}'),
          subtitle: const Text('Downloaded'),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
        ),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: 6,
      ),
    );
  }
}