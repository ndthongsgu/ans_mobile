import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? displayName;

  UserProfile({required this.id, this.email, this.displayName});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };

  factory UserProfile.fromJson(Map<String, dynamic> js) => UserProfile(
        id: js['id'] as String,
        email: js['email'] as String?,
        displayName: js['displayName'] as String?,
      );
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();

  AuthService._();

  static const _kUserKey = 'auth_user';
  static const _kUsersKey = 'registered_users';

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
    notifyListeners();
  }

  // Simple registration storing hashed password locally. Not for production use.
  Future<void> register({required String email, required String password, String? displayName}) async {
    final users = _prefs.getStringList(_kUsersKey) ?? <String>[];
    for (final u in users) {
      final m = jsonDecode(u) as Map<String, dynamic>;
      if (m['email'] == email) throw Exception('Email đã tồn tại');
    }
    final pwdHash = _sha256(password);
    final userMap = {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'email': email, 'displayName': displayName, 'password': pwdHash};
    users.add(jsonEncode(userMap));
    await _prefs.setStringList(_kUsersKey, users);
    // Auto login after register
    _user = UserProfile(id: userMap['id'] as String, email: email, displayName: displayName);
    await _saveUserToPrefs();
    notifyListeners();
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    final users = _prefs.getStringList(_kUsersKey) ?? <String>[];
    final pwdHash = _sha256(password);
    for (final u in users) {
      final m = Map<String, dynamic>.from(jsonDecode(u));
      if (m['email'] == email && m['password'] == pwdHash) {
        _user = UserProfile(
          id: m['id'] as String,
          email: m['email'] as String?,
          displayName: m['displayName'] as String?,
        );
        await _saveUserToPrefs();
        notifyListeners();
        return;
      }
    }
    throw Exception('Email hoặc mật khẩu không đúng');
  }

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email']);
    final acc = await googleSignIn.signIn();
    if (acc == null) throw Exception('Quá trình đăng nhập Google bị huỷ');
    final idStr = acc.id;
    _user = UserProfile(id: idStr, email: acc.email, displayName: acc.displayName);
    await _saveUserToPrefs();
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    await _prefs.remove(_kUserKey);
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

  String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();

  // Debug helper: ensure a demo user exists so you can test login quickly
  Future<void> _ensureMockUsers() async {
    final users = _prefs.getStringList(_kUsersKey) ?? <String>[];
    var found = false;
    for (final u in users) {
      final m = Map<String, dynamic>.from(jsonDecode(u));
      if (m['email'] == 'demo@grap.dev') {
        found = true;
        break;
      }
    }
    if (!found) {
      final demo = {'id': 'demo', 'email': 'demo@grap.dev', 'displayName': 'Demo User', 'password': _sha256('password123')};
      users.add(jsonEncode(demo));
      await _prefs.setStringList(_kUsersKey, users);
    }
  }

  // Quick demo login (convenience for development)
  Future<void> quickLoginDemo() async {
    await signInWithEmail(email: 'demo@grap.dev', password: 'password123');
  }
}
