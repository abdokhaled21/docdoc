import 'package:flutter/material.dart';

import '../../data/home_repository.dart';
import '../../domain/user_profile.dart';
import '../../domain/doctor.dart';

class HomeController extends ChangeNotifier {
  final _repo = HomeRepository.instance;

  bool _loading = true;
  String? _error;
  UserProfile? _profile;
  List<Doctor> _doctors = const [];
  List<Doctor> _filteredDoctors = const [];
  String _searchQuery = '';
  String? _selectedSpec;
  String? _selectedCity;

  bool get loading => _loading;
  String? get error => _error;
  UserProfile? get profile => _profile;
  String get displayName => _profile?.name.isNotEmpty == true ? _profile!.name : 'Guest';
  List<Doctor> get doctors => _doctors;
  List<Doctor> get filteredDoctors =>
      (_searchQuery.isEmpty && _selectedSpec == null && _selectedCity == null)
          ? _doctors
          : _filteredDoctors;
  String? get selectedSpec => _selectedSpec;
  String? get selectedCity => _selectedCity;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repo.fetchProfile();
      _doctors = await _repo.fetchRecommendedDoctors();
      if (_searchQuery.isNotEmpty || _selectedSpec != null || _selectedCity != null) {
        _applyFilter();
      } else {
        _filteredDoctors = const [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final hasQuery = _searchQuery.isNotEmpty;
    final q = _searchQuery.toLowerCase();
    _filteredDoctors = _doctors.where((d) {
      if (_selectedSpec != null && (d.specializationName ?? '').toLowerCase() != _selectedSpec!.toLowerCase()) {
        return false;
      }
      if (_selectedCity != null && (d.cityName ?? '').toLowerCase() != _selectedCity!.toLowerCase()) {
        return false;
      }
      if (!hasQuery) return true;
      bool contains(String? s) => (s ?? '').toLowerCase().contains(q);
      return contains(d.name) ||
          contains(d.specializationName) ||
          contains(d.cityName) ||
          contains(d.hospitalName) ||
          contains(d.phone) ||
          contains(d.email);
    }).toList(growable: false);
  }

  void setSpecializationFilter(String? spec) {
    _selectedSpec = (spec == null || spec.isEmpty || spec.toLowerCase() == 'all') ? null : spec;
    _applyFilter();
    notifyListeners();
  }

  void setCityFilter(String? city) {
    _selectedCity = (city == null || city.isEmpty || city.toLowerCase() == 'all') ? null : city;
    _applyFilter();
    notifyListeners();
  }

  List<String> getSpecializations() {
    final set = <String>{};
    for (final d in _doctors) {
      final s = d.specializationName?.trim();
      if (s != null && s.isNotEmpty) set.add(s);
    }
    final list = set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> getCities() {
    final set = <String>{};
    for (final d in _doctors) {
      final s = d.cityName?.trim();
      if (s != null && s.isNotEmpty) set.add(s);
    }
    final list = set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }
}
