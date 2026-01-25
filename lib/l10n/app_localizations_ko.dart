// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Street Food Go';

  @override
  String get menuTitle => 'Street Food Go — 메뉴';

  @override
  String get mapTitle => '지도';

  @override
  String get poiListTitle => 'POI 목록';

  @override
  String get settingsTitle => '설정';

  @override
  String get statsTitle => '개인 통계';

  @override
  String get narrationStatusTitle => '내레이션 상태';

  @override
  String get recentLabel => '근처';

  @override
  String get versionLabel => '버전';

  @override
  String get playNow => '지금 재생';

  @override
  String get backToMap => '지도으로 돌아가기';

  @override
  String get locationInfo => '위치 정보:';

  @override
  String get noNarration => '현재 실행 중인 내레이션이 없습니다.';

  @override
  String get stop => '중지';

  @override
  String get pause => '일시 정지';

  @override
  String get resume => '다시 재생';

  @override
  String get autoPlayTitle => 'POI 도착 시 자동 재생';

  @override
  String get allowNotificationsTitle => '알림 허용';

  @override
  String get splashSubtitle => 'POI 영역에 들어가면 오디오 재생';

  @override
  String get permissionEnableMsg => '지도를 사용하려면 위치 서비스를 활성화하세요.';

  @override
  String get permissionDeniedMsg => '위치 권한이 거부되었습니다.';

  @override
  String get permissionDeniedForeverMsg => '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 부여하세요.';

  @override
  String locationErrorPrefix(Object error) {
    return '위치 가져오기 오류: $error';
  }

  @override
  String get noUserPositionMsg => '현재 위치가 없습니다. 권한을 요청하려면 탭하세요.';

  @override
  String get suggestionsLabel => '권장 사항:';

  @override
  String get suggestion_keep_gps => '- 자동 내레이션을 받으려면 GPS를 켜두세요';

  @override
  String visitedCountLabel(Object count) {
    return '방문한 POI 수: $count';
  }

  @override
  String totalListenLabel(Object minutes) {
    return '총 청취 시간: $minutes 분';
  }

  @override
  String get languageLabel => '언어';

  @override
  String get language_system => '시스템 기본값';

  @override
  String get language_en_label => 'English';

  @override
  String get language_vi_label => 'Tiếng Việt';

  @override
  String get language_zh_label => '中文';

  @override
  String get language_ko_label => '한국어';
}
