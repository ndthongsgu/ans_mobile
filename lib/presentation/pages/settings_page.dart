import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import 'package:ans_mobile/presentation/widgets/app_toast.dart';
import '../widgets/language_selector.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/locale_provider.dart';
import '../widgets/app_bottom_nav.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoPlay = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('lib/assets/imgs/favicon.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.appTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      const SizedBox(height: 6),
                      Text('${AppLocalizations.of(context)!.versionLabel}: 1.0.0', style: TextStyle(color: colorScheme.onSurface.withAlpha(178))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.autoPlayTitle, style: TextStyle(color: colorScheme.onSurface)),
                  value: _autoPlay,
                  onChanged: (v) => setState(() => _autoPlay = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.allowNotificationsTitle, style: TextStyle(color: colorScheme.onSurface)),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.onSurface),
                  title: Text(AppLocalizations.of(context)!.versionLabel, style: TextStyle(color: colorScheme.onSurface)),
                  subtitle: Text('1.0.0', style: TextStyle(color: colorScheme.onSurface.withAlpha(178))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.languageLabel, style: TextStyle(color: colorScheme.onSurface)),
              subtitle: Text(_localeLabel(context, LocaleProvider.instance.locale), style: TextStyle(color: colorScheme.onSurface.withAlpha(178))),
              trailing: const LanguageSelector(),
            ),
          ),

        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  String _localeLabel(BuildContext context, Locale? locale) {
    if (locale == null) return AppLocalizations.of(context)!.language_system;
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.language_en_label;
      case 'vi':
        return AppLocalizations.of(context)!.language_vi_label;
      case 'zh':
        return AppLocalizations.of(context)!.language_zh_label;
      case 'ko':
        return AppLocalizations.of(context)!.language_ko_label;
      default:
        return AppLocalizations.of(context)!.language_system;
    }
  }
}
