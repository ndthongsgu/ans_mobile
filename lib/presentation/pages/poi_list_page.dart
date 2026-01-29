import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../../data/local/mock_pois.dart';
import '../../presentation/widgets/poi_card.dart';
import '../widgets/app_bottom_nav.dart';

class PoiListPage extends StatelessWidget {
  const PoiListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.poiListTitle)),
      body: ListView.builder(
        itemCount: mockPois.length,
        itemBuilder: (context, index) {
          final poi = mockPois[index];
          return PoiCard(poi: poi, onTap: () => Navigator.of(context).pushNamed('/poi_detail', arguments: poi));
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
