import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../home/domain/doctor.dart';
import '../../../booking/domain/appointment_type.dart';

class BookingController extends ChangeNotifier {
  BookingController({required this.doctor}) {
    _generateInitialData();
    _loadBookedAppointments();
  }

  final Doctor doctor;

  int _step = 0;
  int get step => _step;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  final Map<DateTime, List<TimeOfDay>> _timeSlots = {};
  List<TimeOfDay> get timeSlotsForSelectedDate =>
      _timeSlots[_dateKey(_selectedDate)] ?? const [];

  final Map<DateTime, Set<TimeOfDay>> _bookedTimes = {};
  Set<TimeOfDay> get bookedTimesForSelectedDate =>
      _bookedTimes[_dateKey(_selectedDate)] ?? <TimeOfDay>{};

  bool _loadingBooked = true;
  bool get isLoadingBooked => _loadingBooked;

  TimeOfDay? _selectedTime;
  TimeOfDay? get selectedTime => _selectedTime;

  AppointmentType _appointmentType = AppointmentType.inPerson;
  AppointmentType get appointmentType => _appointmentType;

  bool _manualTime = false;
  bool get manualTime => _manualTime;

  String? _paymentMethod;
  String? get paymentMethod => _paymentMethod;

  void _generateInitialData() {
    for (int i = 0; i < 7; i++) {
      final d = DateTime.now().add(Duration(days: i));
      final key = _dateKey(d);
      final List<TimeOfDay> slots = [];
      for (int h = 14; h <= 20; h++) {
        slots.add(TimeOfDay(hour: h, minute: 0));
        if (h < 20) slots.add(TimeOfDay(hour: h, minute: 30));
      }
      _timeSlots[key] = slots;
    }
  }

  DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

  void setDate(DateTime d) {
    _selectedDate = d;
    _selectedTime = null;
    notifyListeners();
  }

  void setTime(TimeOfDay t) {
    _selectedTime = t;
    notifyListeners();
  }

  void clearTime() {
    _selectedTime = null;
    notifyListeners();
  }

  void setManualTime(bool v) {
    _manualTime = v;
    notifyListeners();
  }

  void setAppointmentType(AppointmentType type) {
    _appointmentType = type;
    notifyListeners();
  }

  void setPaymentMethod(String? method) {
    _paymentMethod = method;
    notifyListeners();
  }

  bool get canContinueFromStep0 => _selectedTime != null;
  bool get canContinueFromStep1 {
    final m = _paymentMethod ?? '';
    if (m.isEmpty) return false;
    if (m == 'credit') return false;
    if (m.startsWith('credit') && !m.contains(':')) return false;
    return true;
  }

  void nextStep() {
    if (_step == 0 && !canContinueFromStep0) return;
    if (_step == 1 && !canContinueFromStep1) return;
    if (_step < 2) {
      _step += 1;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_step > 0) {
      _step -= 1;
      notifyListeners();
    }
  }

  String get summaryString {
    final dateStr = _formatDate(_selectedDate);
    final timeStr = _selectedTime != null
        ? _formatTime(_selectedTime!)
        : '—';
    return '$dateStr, $timeStr • ${appointmentType.label}';
  }

  String _formatDate(DateTime d) {
    final w = _weekdayShort(d.weekday);
    final dd = d.day.toString().padLeft(2, '0');
    return '$w $dd';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    final hh = h.toString().padLeft(2, '0');
    return '$hh.$m $suffix';
  }

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday + 5) % 7];
  }

  Future<void> _loadBookedAppointments() async {
    try {
      _loadingBooked = true;
      notifyListeners();
      final dio = DioClient.instance.dio;
      final res = await dio.get(Endpoints.appointmentIndex);
      final data = res.data;
      if (data is Map && data['data'] is List) {
        final List list = data['data'];
        for (final item in list) {
          if (item is Map) {
            final doc = item['doctor'];
            final int? docId = (doc is Map) ? (doc['id'] as int?) : null;
            if (docId != null && docId == doctor.id) {
              final String? appt = item['appointment_time'] as String?;
              final dt = _parseAppointmentTime(appt);
              if (dt != null) {
                final key = _dateKey(dt);
                final set = _bookedTimes.putIfAbsent(key, () => <TimeOfDay>{});
                set.add(TimeOfDay(hour: dt.hour, minute: dt.minute));
              }
            }
          }
        }
        _loadingBooked = false;
        notifyListeners();
      }
    } catch (_) {
      _loadingBooked = false;
      notifyListeners();
    }
  }

  DateTime? _parseAppointmentTime(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final parts = s.split(',');
      if (parts.length < 3) return null;
      final monthDay = parts[1].trim();
      final rest = parts[2].trim();
      final md = monthDay.split(' ');
      if (md.length < 2) return null;
      final monthName = md[0];
      final day = int.parse(md[1]);
      final restParts = rest.split(' ');
      if (restParts.length < 3) return null;
      final year = int.parse(restParts[0]);
      final time = restParts[1];
      final period = restParts[2];
      final hm = time.split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      final months = {
        'January': 1,
        'February': 2,
        'March': 3,
        'April': 4,
        'May': 5,
        'June': 6,
        'July': 7,
        'August': 8,
        'September': 9,
        'October': 10,
        'November': 11,
        'December': 12,
      };
      final month = months[monthName];
      if (month == null) return null;
      final isPM = period.toUpperCase().startsWith('P');
      if (hour == 12) {
        hour = isPM ? 12 : 0;
      } else if (isPM) {
        hour += 12;
      }
      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }
}
