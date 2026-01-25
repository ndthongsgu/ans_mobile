import 'package:flutter/material.dart';
import '../../data/models/poi.dart';
import '../../core/services/geo_audio_manager.dart';

class PoiDetailPage extends StatelessWidget {
  const PoiDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poi = ModalRoute.of(context)!.settings.arguments as Poi;
    final manager = GeoAudioManager.instance;

    return Scaffold(
      appBar: AppBar(title: Text(poi.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poi.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(poi.description),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => manager.enterPoi(poi),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Phát ngay'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.map),
                  label: const Text('Quay lại bản đồ'),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Thông tin vị trí:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Lat: ${poi.latitude} — Lng: ${poi.longitude}'),
          ],
        ),
      ),
    );
  }
}
