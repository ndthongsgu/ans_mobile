import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/core/services/locale_provider.dart';
import 'package:ans_mobile/core/services/auth_service.dart';
import 'package:ans_mobile/core/theme/grap_theme.dart';

import 'presentation/pages/splash_page.dart';
import 'presentation/pages/map_page.dart';
import 'presentation/pages/poi_list_page.dart';
import 'presentation/pages/poi_detail_page.dart';
import 'presentation/pages/narration_status_page.dart';
import 'presentation/pages/stats_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/player_page.dart';
import 'presentation/pages/downloads_page.dart';
import 'presentation/pages/history_page.dart';
import 'presentation/pages/favorites_page.dart';
import 'presentation/pages/reviews_page.dart';
import 'presentation/pages/support_page.dart';
import 'presentation/pages/notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleProvider.instance.init();
  // Init local auth service (loads persisted user if any)
  await AuthService.instance.init();
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
      theme: grapTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (ctx) => const SplashPage(),
        '/login': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/map': (ctx) => const MapPage(),
        '/poi_list': (ctx) => const PoiListPage(),
        '/poi_detail': (ctx) => const PoiDetailPage(),
        '/status': (ctx) => const NarrationStatusPage(),
        '/stats': (ctx) => const StatsPage(),
        '/forgot': (ctx) => const ForgotPasswordPage(),
        '/profile': (ctx) => const ProfilePage(),
        '/player': (ctx) => const PlayerPage(),
        '/downloads': (ctx) => const DownloadsPage(),
        '/history': (ctx) => const HistoryPage(),
        '/favorites': (ctx) => const FavoritesPage(),
        '/reviews': (ctx) => const ReviewsPage(),
        '/support': (ctx) => const SupportPage(),
        '/notifications': (ctx) => const NotificationsPage(),
      },
    );
  }
}

