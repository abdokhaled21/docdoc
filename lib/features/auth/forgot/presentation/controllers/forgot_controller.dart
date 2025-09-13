import 'package:flutter/foundation.dart';

class ForgotController extends ChangeNotifier {
  String _input = '';
  bool _submitting = false;

  String get input => _input;
  bool get submitting => _submitting;

  void setInput(String v) {
    _input = v.trim();
    notifyListeners();
  }

  bool get isValid {
    if (_input.isEmpty) return false;
    final isEmail = RegExp(r'^\S+@\S+\.\S+$').hasMatch(_input);
    final digits = _input.replaceAll(RegExp(r'\D'), '');
    final isPhone = digits.length >= 7;
    return isEmail || isPhone;
  }

  Future<void> submit({required Future<void> Function(String input) onSubmit}) async {
    if (_submitting) return;
    _submitting = true;
    notifyListeners();
    try {
      await onSubmit(_input);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
