import 'package:flutter/material.dart';

import '../../data/home_repository.dart';
import '../../domain/user_profile.dart';

class ProfileController extends ChangeNotifier {
  final _repo = HomeRepository.instance;

  bool _loading = false;
  String? _error;
  UserProfile? _profile;

  bool get loading => _loading;
  String? get error => _error;
  UserProfile? get profile => _profile;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final p = await _repo.fetchProfile();
      _profile = p;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
