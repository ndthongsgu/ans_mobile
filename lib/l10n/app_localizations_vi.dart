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

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get createAccountNew => 'Tạo tài khoản mới';

  @override
  String get fullNameLabel => 'Họ tên';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get enterNameMsg => 'Nhập họ tên';

  @override
  String get enterEmailMsg => 'Nhập email';

  @override
  String get enterPasswordMsg => 'Nhập mật khẩu';

  @override
  String get passwordMinLengthMsg => 'Mật khẩu ít nhất 6 ký tự';

  @override
  String get loginSuccessMsg => 'Đăng nhập thành công';

  @override
  String get registerSuccessMsg => 'Tạo tài khoản thành công';

  @override
  String get emailVerificationTitle => 'Xác thực email';

  @override
  String get emailVerificationDesc => 'Nhập mã OTP đã gửi tới email của bạn';

  @override
  String get verifyButtonText => 'Xác thực';

  @override
  String get resendOtpText => 'Gửi lại mã';

  @override
  String get backToRegister => 'Trở lại đăng ký';

  @override
  String get loginGoogleSuccessMsg => 'Đăng nhập bằng Google thành công';

  @override
  String get loginDemoSuccessMsg => 'Đăng nhập demo thành công';

  @override
  String get loginWithGoogle => 'Đăng nhập bằng Google';

  @override
  String get quickLoginDemo => 'Đăng nhập nhanh (Demo)';

  @override
  String get logoutLabel => 'Đăng xuất';

  @override
  String get loggedOutMsg => 'Đã đăng xuất';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get forgotPassword => 'Quên mật khẩu';

  @override
  String get forgotPasswordDesc => 'Nhập email để nhận mã đặt lại mật khẩu.';

  @override
  String get sendResetButton => 'Gửi';

  @override
  String get resetSentMsg => 'Mã đặt lại mật khẩu đã được gửi tới email';

  @override
  String get resetPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get resetPasswordDesc => 'Nhập mã được gửi tới email và nhập mật khẩu mới';

  @override
  String get otpLabel => 'Mã OTP';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get resetButton => 'Đặt lại';

  @override
  String get resetSuccessMsg => 'Đặt lại mật khẩu thành công';

  @override
  String get bottom_home => 'Trang chủ';

  @override
  String get bottom_notifications => 'Thông báo';

  @override
  String get bottom_profile => 'Hồ sơ';

  @override
  String get bottom_calendar => 'Lịch';

  @override
  String get bottom_settings => 'Cài đặt';
}
