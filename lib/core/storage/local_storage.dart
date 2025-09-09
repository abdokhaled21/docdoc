import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  // Keys
  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kAuthToken = 'auth_token'; // persistent token key

  // In-memory session token (clears when app process exits)
  static String? _sessionToken;

  Future<bool> getOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingSeen) ?? false;
    
  }

  Future<void> setOnboardingSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, value);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer session token if present, else persistent
    return _sessionToken ?? prefs.getString(_kAuthToken);
  }

  Future<void> setToken(String token, {bool remember = true}) async {
    if (remember) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAuthToken, token);
      _sessionToken = null; // prefer persistent when remember
    } else {
      // Session-only
      _sessionToken = token;
      // Do not touch persistent storage
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    _sessionToken = null;
  }
}
