// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Street Food Go';

  @override
  String get menuTitle => 'Street Food Go — 菜单';

  @override
  String get mapTitle => '地图';

  @override
  String get poiListTitle => '地点列表';

  @override
  String get settingsTitle => '设置';

  @override
  String get statsTitle => '个人统计';

  @override
  String get narrationStatusTitle => '播报状态';

  @override
  String get recentLabel => '附近';

  @override
  String get versionLabel => '版本';

  @override
  String get playNow => '立即播放';

  @override
  String get backToMap => '返回地图';

  @override
  String get locationInfo => '位置信息：';

  @override
  String get noNarration => '当前没有正在播放的播报。';

  @override
  String get stop => '停止';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get autoPlayTitle => '到达地点时自动播放';

  @override
  String get allowNotificationsTitle => '允许通知';

  @override
  String get splashSubtitle => '进入景点区域时播放音频';

  @override
  String get permissionEnableMsg => '请启用定位服务以使用地图功能。';

  @override
  String get permissionDeniedMsg => '定位权限被拒绝。';

  @override
  String get permissionDeniedForeverMsg => '定位权限已被永久拒绝。请打开设置以授予权限。';

  @override
  String locationErrorPrefix(Object error) {
    return '获取位置错误：$error';
  }

  @override
  String get noUserPositionMsg => '当前没有可用位置。点击请求定位权限。';

  @override
  String get suggestionsLabel => '建议：';

  @override
  String get suggestion_keep_gps => '- 保持 GPS 打开以接收自动播报';

  @override
  String visitedCountLabel(Object count) {
    return '已访问地点：$count';
  }

  @override
  String totalListenLabel(Object minutes) {
    return '总收听时间：$minutes 分钟';
  }

  @override
  String get languageLabel => '语言';

  @override
  String get language_system => '系统默认';

  @override
  String get language_en_label => 'English';

  @override
  String get language_vi_label => 'Tiếng Việt';

  @override
  String get language_zh_label => '中文';

  @override
  String get language_ko_label => '한국어';

  @override
  String get loginButton => '登录';

  @override
  String get createAccount => '创建账户';

  @override
  String get createAccountNew => '创建新账户';

  @override
  String get fullNameLabel => '姓名';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get passwordLabel => '密码';

  @override
  String get enterNameMsg => '请输入姓名';

  @override
  String get enterEmailMsg => '请输入电子邮件';

  @override
  String get enterPasswordMsg => '请输入密码';

  @override
  String get passwordMinLengthMsg => '密码至少需要6个字符';

  @override
  String get loginSuccessMsg => '登录成功';

  @override
  String get registerSuccessMsg => '账户创建成功';

  @override
  String get loginGoogleSuccessMsg => '使用 Google 登录成功';

  @override
  String get loginDemoSuccessMsg => '演示登录成功';

  @override
  String get loginWithGoogle => '使用 Google 登录';

  @override
  String get quickLoginDemo => '快速登录（演示）';

  @override
  String get logoutLabel => '登出';

  @override
  String get loggedOutMsg => '已登出';

  @override
  String get backToLogin => '返回登录';

  @override
  String get forgotPassword => '忘记密码';

  @override
  String get bottom_home => '首页';

  @override
  String get bottom_notifications => '通知';

  @override
  String get bottom_profile => '个人';

  @override
  String get bottom_calendar => '日历';

  @override
  String get bottom_settings => '设置';
}
