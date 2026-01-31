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

  @override
  String get loginButton => '로그인';

  @override
  String get createAccount => '계정 생성';

  @override
  String get createAccountNew => '새 계정 만들기';

  @override
  String get fullNameLabel => '이름';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get enterNameMsg => '이름을 입력하세요';

  @override
  String get enterEmailMsg => '이메일을 입력하세요';

  @override
  String get enterPasswordMsg => '비밀번호를 입력하세요';

  @override
  String get passwordMinLengthMsg => '비밀번호는 최소 6자여야 합니다';

  @override
  String get loginSuccessMsg => '로그인 성공';

  @override
  String get registerSuccessMsg => '계정 생성 완료';

  @override
  String get emailVerificationTitle => '이메일 인증';

  @override
  String get emailVerificationDesc => '이메일로 전송된 인증 코드를 입력하세요';

  @override
  String get verifyButtonText => '인증';

  @override
  String get resendOtpText => '코드 재전송';

  @override
  String get backToRegister => '등록으로 돌아가기';

  @override
  String get loginGoogleSuccessMsg => 'Google로 로그인 성공';

  @override
  String get loginDemoSuccessMsg => '데모 로그인 성공';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get quickLoginDemo => '빠른 로그인 (데모)';

  @override
  String get logoutLabel => '로그아웃';

  @override
  String get loggedOutMsg => '로그아웃되었습니다';

  @override
  String get backToLogin => '로그인으로 돌아가기';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get forgotPasswordDesc => '재설정 코드를 받으려면 이메일을 입력하세요.';

  @override
  String get sendResetButton => '전송';

  @override
  String get resetSentMsg => '비밀번호 재설정 코드가 이메일로 전송되었습니다';

  @override
  String get resetPasswordTitle => '비밀번호 재설정';

  @override
  String get resetPasswordDesc => '이메일로 전송된 코드를 입력하고 새 비밀번호를 설정하세요';

  @override
  String get otpLabel => '코드';

  @override
  String get newPasswordLabel => '새 비밀번호';

  @override
  String get resetButton => '재설정';

  @override
  String get resetSuccessMsg => '비밀번호가 재설정되었습니다';

  @override
  String get bottom_home => '홈';

  @override
  String get bottom_notifications => '알림';

  @override
  String get bottom_profile => '프로필';

  @override
  String get bottom_calendar => '달력';

  @override
  String get bottom_settings => '설정';
}
