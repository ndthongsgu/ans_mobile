import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.statsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.visitedCountLabel(manager.visitedCount), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.totalListenLabel(manager.totalListen.inMinutes), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 18),
            Text(AppLocalizations.of(context)!.suggestionsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.suggestion_keep_gps)
          ],
        ),
      ),
    );
  }
}
