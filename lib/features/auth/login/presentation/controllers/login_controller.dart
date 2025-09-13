import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _remember = false;
  bool _obscure = true;
  bool _submitting = false;
  final Map<String, String> _errors = {};

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String get email => _email;
  String get password => _password;
  bool get remember => _remember;
  bool get obscure => _obscure;
  bool get submitting => _submitting;
  String? errorFor(String key) => _errors[key];

  void setEmail(String v) {
    _email = v.trim();
    _errors.remove('email');
    notifyListeners();
  }

  void setPassword(String v) {
    _password = v;
    _errors.remove('password');
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
      _email = emailController.text.trim();
      _password = passwordController.text;
      await onLogin(_email, _password, _remember);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void setFieldErrors(Map<String, List<String>>? fieldErrors) {
    _errors.clear();
    if (fieldErrors != null) {
      fieldErrors.forEach((k, v) {
        if (v.isNotEmpty) _errors[k] = v.first;
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
