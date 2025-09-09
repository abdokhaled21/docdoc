import 'package:flutter/material.dart';

class SignupController extends ChangeNotifier {
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _name = '';
  String _phone = '';
  String _countryCode = '+44';
  String _countryIso = 'GB';
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  bool _phoneValid = false;
  int _phoneDigits = 0;
  int _phoneMin = 0;
  int _phoneMax = 0;
  String _gender = ''; // 'male' | 'female'
  final Map<String, String> _errors = {};
  // Controllers to persist values in fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get name => _name;
  String get phone => _phone;
  String get countryCode => _countryCode;
  String get countryIso => _countryIso;
  bool get obscure => _obscure;
  bool get obscureConfirm => _obscureConfirm;
  bool get submitting => _submitting;
  bool get phoneValid => _phoneValid;
  int get phoneDigits => _phoneDigits;
  int get phoneMin => _phoneMin;
  int get phoneMax => _phoneMax;
  String get gender => _gender;
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

  void setConfirmPassword(String v) {
    _confirmPassword = v;
    _errors.remove('password_confirmation');
    notifyListeners();
  }

  void setName(String v) {
    _name = v.trim();
    _errors.remove('name');
    notifyListeners();
  }

  void setPhone(String v) {
    _phone = v.trim();
    _errors.remove('phone');
    notifyListeners();
  }

  void setPhoneValid(bool v) {
    _phoneValid = v;
    notifyListeners();
  }

  void setPhoneInfo({required int digits, required int min, required int max, required bool valid}) {
    _phoneDigits = digits;
    _phoneMin = min;
    _phoneMax = max;
    _phoneValid = valid;
    notifyListeners();
  }

  void setCountryCode(String v) {
    _countryCode = v;
    notifyListeners();
  }

  void setCountryIso(String iso) {
    _countryIso = iso.toUpperCase();
    notifyListeners();
  }

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void setGender(String v) {
    _gender = v;
    _errors.remove('gender');
    notifyListeners();
  }

  bool get passwordsMatch => _password.isNotEmpty && _password == _confirmPassword;

  Future<void> submit({
    required Future<void> Function(String name, String email, String password, String phone, String countryCode, String gender) onSignup,
  }) async {
    if (_submitting) return;
    _submitting = true;
    notifyListeners();
    try {
      // Ensure we submit current controller values
      _email = emailController.text.trim();
      _password = passwordController.text;
      await onSignup(_name, _email, _password, _phone, _countryCode, _gender);
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
    phoneController.dispose();
    super.dispose();
  }
}
