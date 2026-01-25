import 'package:flutter/material.dart';
import '../../core/services/geo_audio_manager.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final manager = GeoAudioManager.instance;

  @override
  void initState() {
    manager.addListener(_onChange);
    super.initState();
  }

  @override
  void dispose() {
    manager.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số POI đã ghé: ${manager.visitedCount}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Tổng thời gian nghe: ${manager.totalListen.inMinutes} phút', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 18),
            const Text('Gợi ý:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('- Duy trì GPS để nhận thuyết minh tự động')
          ],
        ),
      ),
    );
  }
}
