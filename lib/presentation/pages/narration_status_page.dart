import 'package:flutter/material.dart';
import '../../core/services/geo_audio_manager.dart';

class NarrationStatusPage extends StatefulWidget {
  const NarrationStatusPage({Key? key}) : super(key: key);

  @override
  State<NarrationStatusPage> createState() => _NarrationStatusPageState();
}

class _NarrationStatusPageState extends State<NarrationStatusPage> {
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
    final poi = manager.currentPoi;

    return Scaffold(
      appBar: AppBar(title: const Text('Trạng thái thuyết minh')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (poi == null)
              const Text('Hiện không có thuyết minh nào đang chạy.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(poi.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(poi.description),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: manager.togglePlay,
                        icon: Icon(manager.isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(manager.isPlaying ? 'Tạm dừng' : 'Tiếp tục'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: manager.leavePoi,
                        icon: const Icon(Icons.stop),
                        label: const Text('Dừng'),
                      )
                    ],
                  )
                ],
              ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('Đã nghe: ${manager.visitedCount} điểm'),
            Text('Tổng thời gian nghe: ${manager.totalListen.inMinutes} phút')
          ],
        ),
      ),
    );
  }
}
