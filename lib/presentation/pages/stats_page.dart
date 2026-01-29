import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../../core/services/geo_audio_manager.dart';
import '../widgets/app_bottom_nav.dart';

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
      extendBody: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.statsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30), child: Icon(Icons.place, color: Theme.of(context).colorScheme.primary)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.visitedCountLabel(manager.visitedCount), style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 4),
                                Text(AppLocalizations.of(context)!.recentLabel, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(30), child: Icon(Icons.access_time, color: Theme.of(context).colorScheme.secondary)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(AppLocalizations.of(context)!.totalListenLabel(manager.totalListen.inMinutes), style: Theme.of(context).textTheme.titleLarge)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.suggestionsLabel, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.suggestion_keep_gps, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
