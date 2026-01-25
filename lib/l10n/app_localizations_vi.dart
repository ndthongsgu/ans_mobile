// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Street Food Go';

  @override
  String get menuTitle => 'Street Food Go — Menu';

  @override
  String get mapTitle => 'Bản đồ';

  @override
  String get poiListTitle => 'Danh sách POI';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get statsTitle => 'Thống kê cá nhân';

  @override
  String get narrationStatusTitle => 'Trạng thái thuyết minh';

  @override
  String get recentLabel => 'Gần đây';

  @override
  String get versionLabel => 'Phiên bản';

  @override
  String get playNow => 'Phát ngay';

  @override
  String get backToMap => 'Quay lại bản đồ';

  @override
  String get locationInfo => 'Thông tin vị trí:';

  @override
  String get noNarration => 'Hiện không có thuyết minh nào đang chạy.';

  @override
  String get stop => 'Dừng';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get resume => 'Tiếp tục';

  @override
  String get autoPlayTitle => 'Tự động phát khi đến điểm tham quan';

  @override
  String get allowNotificationsTitle => 'Cho phép thông báo';

  @override
  String get splashSubtitle => 'Phát audio khi đến khu vực điểm tham quan';

  @override
  String get permissionEnableMsg => 'Vui lòng bật vị trí để sử dụng tính năng bản đồ.';

  @override
  String get permissionDeniedMsg => 'Quyền vị trí bị từ chối.';

  @override
  String get permissionDeniedForeverMsg => 'Quyền vị trí bị chặn vĩnh viễn. Hãy mở cài đặt để cấp phép.';

  @override
  String locationErrorPrefix(Object error) {
    return 'Lỗi lấy vị trí: $error';
  }

  @override
  String get noUserPositionMsg => 'Chưa có vị trí hiện tại. Bấm để yêu cầu quyền vị trí.';

  @override
  String get suggestionsLabel => 'Gợi ý:';

  @override
  String get suggestion_keep_gps => '- Duy trì GPS để nhận thuyết minh tự động';

  @override
  String visitedCountLabel(Object count) {
    return 'Số POI đã ghé: $count';
  }

  @override
  String totalListenLabel(Object minutes) {
    return 'Tổng thời gian nghe: $minutes phút';
  }

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get language_system => 'Mặc định hệ thống';

  @override
  String get language_en_label => 'English';

  @override
  String get language_vi_label => 'Tiếng Việt';

  @override
  String get language_zh_label => '中文';

  @override
  String get language_ko_label => '한국어';
}
