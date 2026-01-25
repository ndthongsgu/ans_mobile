// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Street Food Go';

  @override
  String get menuTitle => 'Street Food Go — Menu';

  @override
  String get mapTitle => 'Map';

  @override
  String get poiListTitle => 'POI list';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get statsTitle => 'Personal stats';

  @override
  String get narrationStatusTitle => 'Narration status';

  @override
  String get recentLabel => 'Recent';

  @override
  String get versionLabel => 'Version';

  @override
  String get playNow => 'Play now';

  @override
  String get backToMap => 'Back to map';

  @override
  String get locationInfo => 'Location information:';

  @override
  String get noNarration => 'No narration is running.';

  @override
  String get stop => 'Stop';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get autoPlayTitle => 'Auto play when arriving at POI';

  @override
  String get allowNotificationsTitle => 'Allow notifications';

  @override
  String get splashSubtitle => 'Play audio when you enter a POI area';

  @override
  String get permissionEnableMsg => 'Please enable location services to use the map.';

  @override
  String get permissionDeniedMsg => 'Location permission denied.';

  @override
  String get permissionDeniedForeverMsg => 'Location permission is permanently denied. Open settings to grant permission.';

  @override
  String locationErrorPrefix(Object error) {
    return 'Error getting location: $error';
  }

  @override
  String get noUserPositionMsg => 'No current location available. Tap to request permission.';

  @override
  String get suggestionsLabel => 'Suggestions:';

  @override
  String get suggestion_keep_gps => '- Keep GPS on to receive automatic narration';

  @override
  String visitedCountLabel(Object count) {
    return 'Visited POIs: $count';
  }

  @override
  String totalListenLabel(Object minutes) {
    return 'Total listening time: $minutes minutes';
  }

  @override
  String get languageLabel => 'Language';

  @override
  String get language_system => 'System default';

  @override
  String get language_en_label => 'English';

  @override
  String get language_vi_label => 'Tiếng Việt';

  @override
  String get language_zh_label => '中文';

  @override
  String get language_ko_label => '한국어';
}
