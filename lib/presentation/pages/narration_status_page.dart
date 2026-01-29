import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../../core/services/geo_audio_manager.dart';
import '../widgets/app_bottom_nav.dart';

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
      extendBody: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.narrationStatusTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (poi == null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.headset, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.noNarration, style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
              )
            else
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(poi.description, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: manager.togglePlay,
                            style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(14)),
                            child: Icon(manager.isPlaying ? Icons.pause : Icons.play_arrow),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: manager.leavePoi,
                            icon: const Icon(Icons.stop),
                            label: Text(AppLocalizations.of(context)!.stop),
                          ),
                          const Spacer(),
                          Text(AppLocalizations.of(context)!.playNow, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.visitedCountLabel(manager.visitedCount), style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.totalListenLabel(manager.totalListen.inMinutes), style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
