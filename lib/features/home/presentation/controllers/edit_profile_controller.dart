import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart' as intl_countries;

import '../../data/home_repository.dart';
import '../../domain/user_profile.dart';
import '../../../../core/network/api_error.dart';

class EditProfileController extends ChangeNotifier {
  final _repo = HomeRepository.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  String _countryIso = 'GB';
  String _dialCode = '+44';
  String get countryIso => _countryIso;
  String get dialCode => _dialCode;
  set countryIso(String v) {
    _countryIso = v.toUpperCase();
    _recomputeDirty();
  }
  set dialCode(String v) {
    _dialCode = v;
    _recomputeDirty();
  }

  bool loading = false;
  bool saving = false;
  String? error;

  final Map<String, String?> _errors = {};
  String? errorFor(String field) => _errors[field];

  String _origEmail = '';
  String _origPhoneFull = '';
  String _gender = '';
  String _origGender = '';
  bool _ready = false;
  bool get canSubmit => _ready;

  EditProfileController() {
    nameController.addListener(_recomputeDirty);
    emailController.addListener(_recomputeDirty);
    passwordController.addListener(_recomputeDirty);
    phoneController.addListener(_recomputeDirty);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final UserProfile p = await _repo.fetchProfile();
      nameController.text = p.name;
      emailController.text = p.email;
      _applyPhoneFromFull(p.phone);
      _origEmail = emailController.text.trim();
      _origPhoneFull = _currentPhoneFull();
      _gender = p.gender;
      _origGender = p.gender;
      _ready = false;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applyPhoneFromFull(String full) {
    var digits = full.replaceAll(RegExp(r'\D'), '');
    String? matchIso;
    String? matchDial;
    for (final c in intl_countries.countries) {
      final dial = c.dialCode;
      if (digits.startsWith(dial)) {
        if (matchDial == null || dial.length > matchDial.length) {
          matchDial = dial;
          matchIso = c.code;
        }
      }
    }
    if (matchDial != null && matchIso != null) {
      final local = digits.substring(matchDial.length);
      _countryIso = matchIso.toUpperCase();
      _dialCode = '+$matchDial';
      phoneController.text = local;
    } else {
      if (digits.startsWith('20')) {
        _countryIso = 'EG';
        _dialCode = '+20';
        phoneController.text = digits.substring(2);
      } else {
        _countryIso = 'GB';
        _dialCode = '+44';
        phoneController.text = digits;
      }
    }
    _recomputeDirty();
  }

  void onPhoneChanged(String onlyDigits) {
    _recomputeDirty();
  }

  void onCountryChanged(String dial, String iso) {
    _dialCode = dial;
    _countryIso = iso.toUpperCase();
    _recomputeDirty();
  }

  bool _validate() {
    _errors.clear();
    if (nameController.text.trim().isEmpty) {
      _errors['name'] = 'Enter your name';
    }
    final email = emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^.+@.+\..+$').hasMatch(email)) {
      _errors['email'] = 'Enter a valid email';
    }
    final phoneDigits = phoneController.text.replaceAll(RegExp(r'\\D'), '');
    if (phoneDigits.isEmpty || phoneDigits.length > 11) {
      _errors['phone'] = 'Enter a valid phone';
    }
    final pass = passwordController.text.trim();
    if (pass.isNotEmpty && pass.length < 6) {
      _errors['password'] = 'Password must be at least 6 chars';
    }
    notifyListeners();
    return _errors.isEmpty;
  }

  Future<bool> submit() async {
    if (!_validate()) return false;
    final localDigits = phoneController.text.replaceAll(RegExp(r'\\D'), '');
    final Map<String, dynamic> body = {
      'name': nameController.text.trim(),
      'gender': _genderAsInt(_gender.isEmpty ? _origGender : _gender),
      'email': emailController.text.trim(),
      'phone': localDigits,
      'country_code': _dialCode.replaceAll('+', ''),
    };
    final email = emailController.text.trim();
    final phoneFull = _currentPhoneFull();
    final pass = passwordController.text.trim();

    if (pass.isNotEmpty) body['password'] = pass;

    final requiredChanged = (email != _origEmail) && (phoneFull != _origPhoneFull);
    if (!requiredChanged) return false;
    saving = true;
    error = null;
    notifyListeners();
    try {
      final updated = await _repo.updateProfilePartial(body);
      nameController.text = updated.name;
      emailController.text = updated.email;
      _applyPhoneFromFull(updated.phone);
      passwordController.clear();
      _origEmail = emailController.text.trim();
      _origPhoneFull = _currentPhoneFull();
      _origGender = _gender;
      _ready = false;
      return true;
    } catch (e) {
      _errors.clear();
      if (e is ApiError) {
        final fe = e.fieldErrors;
        if (fe != null && fe.isNotEmpty) {
          final parts = <String>[];
          fe.forEach((k, v) {
            final msg = v.isNotEmpty ? v.first : '';
            if (msg.isNotEmpty) parts.add('$k: $msg');
            if (k == 'email') _errors['email'] = msg;
            if (k == 'phone') _errors['phone'] = msg;
            if (k == 'password') _errors['password'] = msg;
            if (k == 'name') _errors['name'] = msg;
            if (k == 'gender') {}
          });
          error = parts.join(' | ');
        } else {
          error = e.message;
        }
      } else {
        error = e.toString();
      }
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  String _currentPhoneFull() {
    final localDigits = phoneController.text.replaceAll(RegExp(r'\D'), '');
    final localNoTrunk = localDigits.startsWith('0') ? localDigits.substring(1) : localDigits;
    final dial = _dialCode.replaceAll('+', '');
    return '+$dial$localNoTrunk';
  }

  void _recomputeDirty() {
    final nowEmail = emailController.text.trim();
    final nowPhone = _currentPhoneFull();
    final pass = passwordController.text.trim();
    _ready = (nowEmail != _origEmail) && (nowPhone != _origPhoneFull) &&
        (pass.isEmpty || pass.length >= 6);
    notifyListeners();
  }

  int _genderAsInt(String value) {
    final v = value.trim().toLowerCase();
    if (v == 'female' || v == 'f' || v == '1') return 1;
    if (v == 'male' || v == 'm' || v == '0' || v == '2') return 0;
    return 0;
  }
}
