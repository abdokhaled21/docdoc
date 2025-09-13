import 'package:flutter/material.dart';

import '../../data/home_repository.dart';
import '../../domain/specialization.dart';

class SpecializationController extends ChangeNotifier {
  final _repo = HomeRepository.instance;

  bool _loading = true;
  String? _error;
  List<Specialization> _items = const [];
  static List<Specialization>? _cache;
  static DateTime? _cacheAt;
  static const Duration _maxAge = Duration(minutes: 10);

  bool get loading => _loading;
  String? get error => _error;
  List<Specialization> get items => _items;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      if (_cache != null && _cacheAt != null && now.difference(_cacheAt!) < _maxAge) {
        _items = _cache!;
      } else {
        _items = await _repo.fetchSpecializations();
        _cache = _items;
        _cacheAt = now;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
