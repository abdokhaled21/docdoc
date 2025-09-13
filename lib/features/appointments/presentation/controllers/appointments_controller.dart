import 'package:flutter/material.dart';
import '../../data/appointments_repository.dart';
import '../../domain/appointment.dart';

class AppointmentsController extends ChangeNotifier {
  final _repo = AppointmentsRepository.instance;
  bool loading = false;
  String? error;
  int tabIndex = 0;
  List<Appointment> _items = [];

  List<Appointment> get all => _sorted(_items, asc: true);
  List<Appointment> get upcoming {
    final now = DateTime.now().subtract(const Duration(minutes: 1));
    return _sorted(
      _items.where((a) => a.status == 'upcoming' && a.startTime.isAfter(now)),
      asc: true,
    );
  }
  List<Appointment> get completed {
    final now = DateTime.now().subtract(const Duration(minutes: 1));
    return _sorted(
      _items.where((a) => a.status == 'completed' || a.startTime.isBefore(now)),
      asc: false,
    );
  }
  List<Appointment> get cancelled => _sorted(_items.where((a) => a.status == 'cancelled'), asc: true);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _items = await _repo.index();
      _items.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      error = 'Failed to load appointments';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setTab(int i) {
    if (tabIndex == i) return;
    tabIndex = i;
    notifyListeners();
  }

  List<Appointment> _sorted(Iterable<Appointment> list, {required bool asc}) {
    final arr = list.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return asc ? arr : arr.reversed.toList();
  }
}
