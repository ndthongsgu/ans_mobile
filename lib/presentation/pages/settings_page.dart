import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../widgets/language_selector.dart';

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.autoPlayTitle, style: TextStyle(color: colorScheme.onSurface)),
            value: _autoPlay,
            onChanged: (v) => setState(() => _autoPlay = v),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.allowNotificationsTitle, style: TextStyle(color: colorScheme.onSurface)),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.onSurface),
            title: Text(AppLocalizations.of(context)!.versionLabel, style: TextStyle(color: colorScheme.onSurface)),
            subtitle: Text('1.0.0', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)!.languageLabel, style: TextStyle(color: colorScheme.onSurface)),
            trailing: const LanguageSelector(),
          )
        ],
      ),
    );
  }
}
