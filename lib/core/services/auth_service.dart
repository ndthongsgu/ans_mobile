import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ans_mobile/data/remote/api_client.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? full_name;

  UserProfile({required this.id, this.email, this.full_name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': full_name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> js) => UserProfile(
        id: js['id'] as String,
        email: js['email'] as String?,
        full_name: js['full_name'] as String?,
      );
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();

  AuthService._();

  static const _kUserKey = 'auth_user';
  static const _kAccessTokenKey = 'auth_access_token';
  static const _kRefreshTokenKey = 'auth_refresh_token';

  UserProfile? _user;
  UserProfile? get user => _user;

  bool get isLoggedIn => _user != null;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final s = _prefs.getString(_kUserKey);
    if (s != null) {
      try {
        final js = Map<String, dynamic>.from(jsonDecode(s));
        _user = UserProfile.fromJson(js);
      } catch (_) {}
    }
    if (kDebugMode) {
      await _ensureMockUsers();
    }
    // If we have tokens stored, try to refresh user from API
    final access = _prefs.getString(_kAccessTokenKey);
    final refresh = _prefs.getString(_kRefreshTokenKey);
    if (access != null) {
      try {
        final me = await ApiClient.instance.me(access);
        _user = _profileFromMe(me);
        await _saveUserToPrefs();
      } catch (e) {
        // Try refresh if available
        if (refresh != null) {
          try {
            final tokens = await ApiClient.instance.refresh(refresh);
            await _storeTokens(tokens['accessToken'] as String, tokens['refreshToken'] as String);
            final me2 = await ApiClient.instance.me(tokens['accessToken'] as String);
            _user = _profileFromMe(me2);
            await _saveUserToPrefs();
          } catch (_) {
            // ignore
          }
        }
      }
    }

    notifyListeners();
  }

  /// Register via remote API. On success stores tokens and user profile.
  /// Start registration: sends OTP to email. Does not log the user in.
  Future<void> register({String? username, required String email, required String password, required String full_name}) async {
    try {
      await ApiClient.instance.register(username: username, full_name: full_name, email: email, password: password);
      // Register only sends OTP now; client should show verification UI.
      return;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP and complete registration. On success stores tokens and fetches profile.
  Future<void> verifyAndComplete({required String email, required String otp}) async {
    try {
      final res = await ApiClient.instance.verify(email: email, otp: otp);
      final access = res['accessToken'] as String;
      final refresh = res['refreshToken'] as String;
      await _storeTokens(access, refresh);
      final me = await ApiClient.instance.me(access);
      _user = _profileFromMe(me);
      await _saveUserToPrefs();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Request password reset (sends OTP to email)
  Future<void> forgotPassword({required String email}) async {
    try {
      await ApiClient.instance.forgotPassword(email: email);
      return;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP and reset password
  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    try {
      await ApiClient.instance.resetPassword(email: email, otp: otp, newPassword: newPassword);
      return;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in using remote API
  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      final res = await ApiClient.instance.login(email: email, password: password);
      final access = res['accessToken'] as String;
      final refresh = res['refreshToken'] as String;
      await _storeTokens(access, refresh);
      final me = await ApiClient.instance.me(access);
      _user = _profileFromMe(me);
      await _saveUserToPrefs();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email']);
    final acc = await googleSignIn.signIn();
    if (acc == null) throw Exception('Quá trình đăng nhập Google bị huỷ');
    final idStr = acc.id;
    _user = UserProfile(id: idStr, email: acc.email, full_name: acc.displayName);
    await _saveUserToPrefs();
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    await _prefs.remove(_kUserKey);
    await _prefs.remove(_kAccessTokenKey);
    await _prefs.remove(_kRefreshTokenKey);
    // Also sign out from Google if needed
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _saveUserToPrefs() async {
    if (_user == null) return;
    await _prefs.setString(_kUserKey, jsonEncode(_user!.toJson()));
  }

  Future<void> _storeTokens(String access, String refresh) async {
    await _prefs.setString(_kAccessTokenKey, access);
    await _prefs.setString(_kRefreshTokenKey, refresh);
  }

  UserProfile _profileFromMe(Map<String, dynamic> me) {
    // id may be at top-level or nested under 'user'
    final id = me['id']?.toString() ?? (me['user'] is Map ? (me['user']['id']?.toString()) : null) ?? 'unknown';
    final email = me['email'] as String? ?? (me['user'] is Map ? me['user']['email'] as String? : null);
    String? full_name = me['full_name'] as String?;
    if (full_name == null && me['user'] is Map) {
      full_name = me['user']['username'] as String? ?? me['user']['email'] as String?;
    }
    full_name ??= me['username'] as String?;
    return UserProfile(id: id, email: email, full_name: full_name);
  }

  String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();

  // Debug helper: ensure a demo user exists so you can test login quickly
  Future<void> _ensureMockUsers() async {
    // Note: keep existing local demo users for convenience in development
    final usersKey = 'registered_users';
    final users = _prefs.getStringList(usersKey) ?? <String>[];
    var found = false;
    for (final u in users) {
      final m = Map<String, dynamic>.from(jsonDecode(u));
      if (m['email'] == 'demo@grap.dev') {
        found = true;
        break;
      }
    }
    if (!found) {
      final demo = {'id': 'demo', 'email': 'demo@grap.dev', 'full_name': 'Demo User', 'password': _sha256('password123')};
      users.add(jsonEncode(demo));
      await _prefs.setStringList(usersKey, users);
    }
  }

  // Quick demo login (convenience for development)
  Future<void> quickLoginDemo() async {
    // If API fails or not configured, fallback to local demo
    try {
      await signInWithEmail(email: 'demo@grap.dev', password: 'password123');
    } catch (_) {
      final users = _prefs.getStringList('registered_users') ?? <String>[];
      final pwdHash = _sha256('password123');
      for (final u in users) {
        final m = Map<String, dynamic>.from(jsonDecode(u));
        if (m['email'] == 'demo@grap.dev' && m['password'] == pwdHash) {
          _user = UserProfile(id: m['id'] as String, email: m['email'] as String?, full_name: m['full_name'] as String?);
          await _saveUserToPrefs();
          notifyListeners();
          return;
        }
      }
      throw Exception('Demo login failed');
    }
  }
}
