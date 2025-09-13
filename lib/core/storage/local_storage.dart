import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  static const String _kOnboardingSeen = 'onboarding_seen';
  static const String _kAuthToken = 'auth_token';
  static const String _kRecentSearches = 'recent_searches';
  static const String _kReviewsDoctorIds = 'reviews_doctor_ids';

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
    return _sessionToken ?? prefs.getString(_kAuthToken);
  }

  Future<void> setToken(String token, {bool remember = true}) async {
    if (remember) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAuthToken, token);
      _sessionToken = null;
    } else {
      _sessionToken = token;
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    _sessionToken = null;
  }

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentSearches) ?? <String>[];
    return List<String>.from(list);
  }

  Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentSearches) ?? <String>[];
    final existing = list.where((e) => e.toLowerCase() == q.toLowerCase()).toList();
    for (final e in existing) {
      list.remove(e);
    }
    list.insert(0, q);
    if (list.length > 10) list.removeRange(10, list.length);
    await prefs.setStringList(_kRecentSearches, list);
  }

  Future<void> removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentSearches) ?? <String>[];
    list.removeWhere((e) => e.toLowerCase() == query.trim().toLowerCase());
    await prefs.setStringList(_kRecentSearches, list);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentSearches);
  }
  String _reviewsKeyForDoctor(int doctorId) => 'reviews_$doctorId';

  Future<List<int>> getDoctorIdsWithReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kReviewsDoctorIds) ?? <String>[];
    return list.map((e) => int.tryParse(e) ?? -1).where((e) => e > 0).toList();
  }

  Future<void> _addDoctorIdIndex(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kReviewsDoctorIds) ?? <String>[];
    final idStr = doctorId.toString();
    if (!list.contains(idStr)) {
      list.add(idStr);
      await prefs.setStringList(_kReviewsDoctorIds, list);
    }
  }

  Future<String?> getReviewsRaw(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_reviewsKeyForDoctor(doctorId));
  }

  Future<void> setReviewsRaw(int doctorId, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reviewsKeyForDoctor(doctorId), json);
    await _addDoctorIdIndex(doctorId);
  }

  Future<void> clearReviews(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reviewsKeyForDoctor(doctorId));
    final list = prefs.getStringList(_kReviewsDoctorIds) ?? <String>[];
    list.remove(doctorId.toString());
    await prefs.setStringList(_kReviewsDoctorIds, list);
  }
}
