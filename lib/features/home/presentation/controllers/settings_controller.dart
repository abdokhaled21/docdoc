import 'package:flutter/material.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/auth_repository.dart';

class SettingsController extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> logout() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await AuthRepository.instance.logout();
    } catch (e) {
      _error = e.toString();
    }
    await LocalStorage.instance.clearToken();
    _loading = false;
    notifyListeners();
    return true;
  }
}
