import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
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
                  label: Text(AppLocalizations.of(context)!.playNow),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.map),
                  label: Text(AppLocalizations.of(context)!.backToMap),
                )
              ],
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.locationInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Lat: ${poi.latitude} — Lng: ${poi.longitude}'),
          ],
        ),
      ),
    );
  }
}
