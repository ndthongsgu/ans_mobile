import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/core/services/locale_provider.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/map_page.dart';
import 'presentation/pages/poi_list_page.dart';
import 'presentation/pages/poi_detail_page.dart';
import 'presentation/pages/narration_status_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/stats_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleProvider.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocaleProvider.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleProvider.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3C828E)).copyWith(
      secondary: const Color(0xFFAB2524),
      tertiary: const Color(0xFFD69D45),
    );

    return MaterialApp(
      // Title is provided by localization
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: LocaleProvider.instance.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: scheme.primary,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: scheme.onPrimary,
          textColor: scheme.onPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.secondary,
            foregroundColor: scheme.onSecondary,
          ),
        ),
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

