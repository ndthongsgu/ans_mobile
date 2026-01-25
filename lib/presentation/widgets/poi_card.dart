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
      color: colorScheme.surface,
      child: ListTile(
        leading: Icon(Icons.place, color: colorScheme.onSurface),
        title: Text(poi.name, style: TextStyle(color: colorScheme.onSurface)),
        subtitle: Text(
          poi.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.75)),
        ),
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface),
        onTap: onTap,
      ),
    );
  }
}
