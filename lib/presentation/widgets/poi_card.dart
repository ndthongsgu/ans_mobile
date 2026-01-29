import 'package:flutter/material.dart';
import '../../data/models/poi.dart';

class PoiCard extends StatelessWidget {
  final Poi poi;
  final VoidCallback? onTap;
  const PoiCard({Key? key, required this.poi, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 64,
                  height: 64,
                  color: colorScheme.primary.withAlpha(30),
                  child: poi.thumbnailUrl != null
                      ? Image.network(poi.thumbnailUrl!, fit: BoxFit.cover)
                      : Icon(Icons.restaurant, color: colorScheme.primary, size: 36),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(poi.name, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      poi.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
