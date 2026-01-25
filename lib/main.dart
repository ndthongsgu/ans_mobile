import 'package:flutter/material.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/map_page.dart';
import 'presentation/pages/poi_list_page.dart';
import 'presentation/pages/poi_detail_page.dart';
import 'presentation/pages/narration_status_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/stats_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANS — Thuyết minh tự động',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (ctx) => const SplashPage(),
        '/map': (ctx) => const MapPage(),
        '/poi_list': (ctx) => const PoiListPage(),
        '/poi_detail': (ctx) => const PoiDetailPage(),
        '/status': (ctx) => const NarrationStatusPage(),
        '/settings': (ctx) => const SettingsPage(),
        '/stats': (ctx) => const StatsPage(),
      },
    );
  }
}

