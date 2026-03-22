import 'package:flutter/material.dart';
import '../../data/models/poi.dart';
import '../../core/services/geo_audio_manager.dart';
import '../../core/services/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class PoiDetailPage extends StatefulWidget {
  const PoiDetailPage({Key? key}) : super(key: key);

  @override
  State<PoiDetailPage> createState() => _PoiDetailPageState();
}

class _PoiDetailPageState extends State<PoiDetailPage> {
  late Poi poi;
  late GeoAudioManager manager;
  bool _contentsLoaded = false;

  @override
  void initState() {
    super.initState();
    manager = GeoAudioManager.instance;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load POI from route arguments
    if (!_contentsLoaded) {
      poi = ModalRoute.of(context)!.settings.arguments as Poi;
      final userLang = LocaleProvider.instance.locale?.languageCode ?? 'vi';
      
      // Load audio contents (but don't play automatically)
      manager.enterPoi(poi, language: userLang);
      _contentsLoaded = true;
    }
  }

  @override
  void dispose() {
    // Stop audio when leaving this page
    manager.leavePoi();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String? value, {TextStyle? valueStyle}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: valueStyle ?? const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(poi.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              if (poi.coverImage != null && poi.coverImage!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    poi.coverImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Name & Category
              Text(poi.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (poi.category != null)
                Text(poi.category!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              if (poi.ownerName != null) ...[
                const SizedBox(height: 4),
                Text('${AppLocalizations.of(context)!.ownerLabel} ${poi.ownerName}', 
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 16),

              // Description from audio contents
              ListenableBuilder(
                listenable: manager,
                builder: (context, _) {
                  if (manager.currentPoi?.id != poi.id || manager.currentContents.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  // Get all unique scripts from contents
                  final scripts = manager.currentContents
                      .where((c) => (c['tts_script'] as String?)?.isNotEmpty ?? false)
                      .map((c) => c['tts_script'] as String)
                      .toList();
                  
                  if (scripts.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.descriptionTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scripts.join('\n\n'),
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Audio Player Section
              ListenableBuilder(
                listenable: manager,
                builder: (context, _) {
                  if (manager.currentPoi?.id != poi.id) {
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton(
                            onPressed: () async {
                              // If no contents loaded yet, load them first
                              if (manager.currentContents.isEmpty) {
                                final userLang = LocaleProvider.instance.locale?.languageCode ?? 'vi';
                                await manager.enterPoi(poi, language: userLang);
                              }
                              // Toggle play/pause
                              if (manager.currentContents.isNotEmpty) {
                                if (!manager.isPlaying) {
                                  // Start playing from beginning if not playing
                                  await manager.playContent(0);
                                } else {
                                  // Pause if currently playing
                                  await manager.togglePlay();
                                }
                              }
                            },
                            child: Icon(manager.isPlaying ? Icons.pause : Icons.play_arrow),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Contact Section
              if (poi.contactPhone != null || poi.website != null) ...[
                Text(AppLocalizations.of(context)!.contactTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (poi.contactPhone != null)
                  _buildInfoRow(AppLocalizations.of(context)!.phoneLabel, poi.contactPhone,
                      valueStyle: const TextStyle(fontSize: 14, color: Colors.blue)),
                if (poi.website != null)
                  _buildInfoRow(AppLocalizations.of(context)!.websiteLabel, poi.website,
                      valueStyle: const TextStyle(fontSize: 14, color: Colors.blue)),
                const SizedBox(height: 24),
              ],

              // Info Section
              if (poi.openingHours != null || poi.priceRange != null) ...[
                Text(AppLocalizations.of(context)!.infoTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (poi.openingHours != null)
                  _buildInfoRow(AppLocalizations.of(context)!.openingHoursLabel, poi.openingHours),
                if (poi.priceRange != null)
                  _buildInfoRow(AppLocalizations.of(context)!.priceRangeLabel, poi.priceRange),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
