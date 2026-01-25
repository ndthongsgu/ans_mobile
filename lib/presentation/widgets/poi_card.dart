import 'package:flutter/material.dart';
import '../../data/models/poi.dart';

class PoiCard extends StatelessWidget {
  final Poi poi;
  final VoidCallback? onTap;
  const PoiCard({Key? key, required this.poi, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place),
        title: Text(poi.name),
        subtitle: Text(poi.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
