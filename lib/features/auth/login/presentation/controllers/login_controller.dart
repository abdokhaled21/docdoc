import 'package:flutter/foundation.dart';

class LoginController extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _remember = false;
  bool _obscure = true;
  bool _submitting = false;

  String get email => _email;
  String get password => _password;
  bool get remember => _remember;
  bool get obscure => _obscure;
  bool get submitting => _submitting;

  void setEmail(String v) {
    _email = v.trim();
    notifyListeners();
  }

  void setPassword(String v) {
    _password = v;
    notifyListeners();
  }

  void toggleRemember(bool? v) {
    _remember = v ?? false;
    notifyListeners();
  }

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  Future<void> submit({required Future<void> Function(String email, String password, bool remember) onLogin}) async {
    if (_submitting) return;
    _submitting = true;
    notifyListeners();
    try {
      await onLogin(_email, _password, _remember);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
