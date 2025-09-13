import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/home_repository.dart';
import '../../domain/doctor.dart';

class DoctorsController extends ChangeNotifier {
  final _repo = HomeRepository.instance;

  bool _loading = true;
  String? _error;
  List<Doctor> _baseDoctors = const [];
  List<Doctor> _doctors = const [];
  String _searchQuery = '';
  String? _selectedSpec;
  String? _selectedCity;
  List<String> _allSpecs = const [];
  List<String> _allCities = const [];
  Map<String, int> _cityNameToId = const {};
  Map<String, int> _specNameToId = const {};
  bool _generalMode = false;
  Timer? _debounce;
  
  int _page = 1;
  int _limit = 8;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get loading => _loading;
  String? get error => _error;
  List<Doctor> get doctors => _doctors;
  String? get selectedSpec => _selectedSpec;
  String? get selectedCity => _selectedCity;
  int? get selectedCityId => _selectedCity == null ? null : _cityNameToId[_selectedCity!.toLowerCase()];
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  void setPageSize(int size) {
    if (size <= 0) return;
    if (_limit != size) {
      _limit = size;
    }
  }

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    _resetPagination();
    notifyListeners();
    try {
      _baseDoctors = await _repo.fetchAllDoctors(page: _page, limit: _limit);
      _rebuildStableOptions();
      _applyFilter();
      _hasMore = _baseDoctors.length == _limit;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadBySpecialization(int specializationId) async {
    _loading = true;
    _error = null;
    _resetPagination();
    notifyListeners();
    try {
      _baseDoctors = await _repo.fetchDoctorsBySpecialization(specializationId, page: _page, limit: _limit);
      _rebuildStableOptions();
      _applyFilter();
      _hasMore = _baseDoctors.length == _limit;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String q) {
    _searchQuery = q.trim();
    if (_generalMode) {
      _resetPagination();
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        _searchGeneral(_searchQuery);
      });
    } else {
      _applyFilter();
      notifyListeners();
    }
  }

  Future<void> setCityFilter(String? cityName) async {
    _selectedCity = (cityName == null || cityName.isEmpty || cityName.toLowerCase() == 'all') ? null : cityName;
    if (_selectedCity == null) {
      await loadAll();
      return;
    }
    final id = _cityNameToId[_selectedCity!.toLowerCase()];
    if (id != null) {
      _loading = true;
      _resetPagination();
      notifyListeners();
      try {
        _baseDoctors = await _repo.fetchDoctorsByCity(id, page: _page, limit: _limit);
      } catch (e) {
        _error = e.toString();
      } finally {
        _loading = false;
        _applyFilter();
        _hasMore = _baseDoctors.length == _limit;
        notifyListeners();
      }
    } else {
      _applyFilter();
      notifyListeners();
    }
  }

  void setSpecializationFilter(String? spec) {
    _selectedSpec = (spec == null || spec.isEmpty || spec.toLowerCase() == 'all') ? null : spec;
    _resetPagination();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var list = _baseDoctors;
    if (_selectedSpec != null) {
      list = list
          .where((d) => (d.specializationName ?? '').toLowerCase() == _selectedSpec!.toLowerCase())
          .toList(growable: false);
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      bool contains(String? s) => (s ?? '').toLowerCase().contains(q);
      list = list
          .where((d) => contains(d.name) || contains(d.specializationName) || contains(d.hospitalName) || contains(d.cityName))
          .toList(growable: false);
    }
    _doctors = list;
  }

  List<String> getSpecializations() => ['All', ..._allSpecs];

  List<String> getCities() => ['All', ..._allCities];

  void _rebuildStableOptions() {
    final specSet = <String>{};
    final citySet = <String>{};
    final cityMap = <String, int>{};
    final specMap = <String, int>{};
    for (final d in _baseDoctors) {
      final s = d.specializationName?.trim();
      if (s != null && s.isNotEmpty) {
        specSet.add(s);
        if (d.specializationId != null) specMap[s.toLowerCase()] = d.specializationId!;
      }
      final c = d.cityName?.trim();
      if (c != null && c.isNotEmpty) {
        citySet.add(c);
        if (d.cityId != null) cityMap[c.toLowerCase()] = d.cityId!;
      }
    }
    final specs = specSet.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final cities = citySet.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _allSpecs = specs;
    _allCities = cities;
    _cityNameToId = cityMap;
    _specNameToId = specMap;
  }

  void setGeneralMode(bool value) {
    _generalMode = value;
  }

  Future<void> _searchGeneral(String q) async {
    if (q.isEmpty) {
      await loadAll();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      List<Doctor> byName = await _repo.fetchDoctorsSearch(q, page: _page, limit: _limit);
      if (_selectedCity != null && selectedCityId != null) {
        final byCityOnly = await _repo.fetchDoctorsByCity(selectedCityId!, page: 1, limit: _limit);
        final cityIds = byCityOnly.map((e) => e.id).toSet();
        byName = byName.where((d) => cityIds.contains(d.id)).toList(growable: false);
      }
      List<Doctor> byCity = const [];
      List<Doctor> bySpec = const [];
      if (_page == 1) {
        final cityIds = _cityIdsMatchingQuery(q);
        final specIds = _specIdsMatchingQuery(q);
        for (final id in cityIds.take(2)) {
          final list = await _repo.fetchDoctorsByCity(id, page: 1, limit: _limit);
          byCity = [...byCity, ...list];
        }
        for (final id in specIds.take(2)) {
          final list = await _repo.fetchDoctorsBySpecialization(id, page: 1, limit: _limit);
          bySpec = [...bySpec, ...list];
        }
      }
      final map = <int, Doctor>{};
      for (final d in [...byName, ...byCity, ...bySpec]) {
        map[d.id] = d;
      }
      _baseDoctors = map.values.toList(growable: false);
      _applyFilter();
      _hasMore = byName.length == _limit;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<int> _cityIdsMatchingQuery(String q) {
    final query = q.toLowerCase();
    final ids = <int>{};
    for (final entry in _cityNameToId.entries) {
      final name = entry.key;
      if (name.contains(query) || query.contains(name)) {
        ids.add(entry.value);
      }
    }
    return ids.toList(growable: false);
  }

  List<int> _specIdsMatchingQuery(String q) {
    final query = q.toLowerCase();
    final ids = <int>{};
    for (final entry in _specNameToId.entries) {
      final name = entry.key;
      if (name.contains(query) || query.contains(name)) {
        ids.add(entry.value);
      }
    }
    return ids.toList(growable: false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> loadMore({int? specId, int? cityId}) async {
    if (!_hasMore || _loadingMore) return;
    _loadingMore = true;
    _page += 1;
    try {
      List<Doctor> next = const [];
      if (_generalMode) {
        if (_searchQuery.isNotEmpty) {
          next = await _repo.fetchDoctorsSearch(_searchQuery, page: _page, limit: _limit);
        } else if (_selectedCity != null && cityId != null) {
          next = await _repo.fetchDoctorsByCity(cityId, page: _page, limit: _limit);
        } else {
          next = await _repo.fetchAllDoctors(page: _page, limit: _limit);
        }
      } else if (specId != null) {
        next = await _repo.fetchDoctorsBySpecialization(specId, page: _page, limit: _limit);
      }
      if (next.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = _baseDoctors.map((e) => e.id).toSet();
        final toAppend = <Doctor>[];
        for (final d in next) {
          if (!existingIds.contains(d.id)) {
            toAppend.add(d);
            existingIds.add(d.id);
          }
        }
        if (toAppend.isEmpty) {
          _hasMore = false;
        } else {
          _baseDoctors = [..._baseDoctors, ...toAppend];
          _applyFilter();
          _hasMore = toAppend.length == _limit;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  void _resetPagination() {
    _page = 1;
    _hasMore = true;
    _loadingMore = false;
  }
}
