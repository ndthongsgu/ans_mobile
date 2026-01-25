import 'package:flutter/material.dart';
import '../../data/local/mock_pois.dart';
import '../../presentation/widgets/poi_card.dart';

class PoiListPage extends StatelessWidget {
  const PoiListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách POI')),
      body: ListView.builder(
        itemCount: mockPois.length,
        itemBuilder: (context, index) {
          final poi = mockPois[index];
          return PoiCard(poi: poi, onTap: () => Navigator.of(context).pushNamed('/poi_detail', arguments: poi));
        },
      ),
    );
  }
}
