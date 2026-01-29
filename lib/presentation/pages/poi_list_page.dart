import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../../data/local/mock_pois.dart';
import '../../presentation/widgets/poi_card.dart';
import '../widgets/app_bottom_nav.dart';

class PoiListPage extends StatelessWidget {
  const PoiListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Thoát ứng dụng?'),
            content: const Text('Bạn có chắc muốn thoát không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.poiListTitle),
          automaticallyImplyLeading: false,
        ),
        body: ListView.builder(
          itemCount: mockPois.length,
          itemBuilder: (context, index) {
            final poi = mockPois[index];
            return PoiCard(
              poi: poi,
              onTap: () => Navigator.of(
                context,
              ).pushNamed('/poi_detail', arguments: poi),
            );
          },
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      ),
    );
  }
}
