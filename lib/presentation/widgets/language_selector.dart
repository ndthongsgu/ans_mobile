import 'package:flutter/material.dart';
import 'package:ans_mobile/l10n/app_localizations.dart';
import '../../core/services/locale_provider.dart';

class _LanguageItem {
  final Locale? locale;
  final String label;
  const _LanguageItem(this.locale, this.label);
}

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final provider = LocaleProvider.instance;
    final current = provider.locale;

    final items = <_LanguageItem>[
      _LanguageItem(null, AppLocalizations.of(context)!.language_system),
      _LanguageItem(const Locale('en'), AppLocalizations.of(context)!.language_en_label),
      _LanguageItem(const Locale('vi'), AppLocalizations.of(context)!.language_vi_label),
      _LanguageItem(const Locale('zh'), AppLocalizations.of(context)!.language_zh_label),
      _LanguageItem(const Locale('ko'), AppLocalizations.of(context)!.language_ko_label),
    ];

    return DropdownButton<Locale?>(
      value: current,
      onChanged: (Locale? v) {
        provider.setLocale(v);
        setState(() {});
      },
      items: items.map((it) => DropdownMenuItem<Locale?>(value: it.locale, child: Text(it.label))).toList(),
    );
  }
}
