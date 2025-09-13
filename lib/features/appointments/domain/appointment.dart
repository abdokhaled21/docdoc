import 'package:flutter/material.dart';

class Appointment {
  final int id;
  final String doctorName;
  final String? doctorPhotoUrl;
  final String specialization;
  final String dateLabel;
  final String timeLabel;
  final DateTime startTime;
  final String status;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specialization,
    required this.dateLabel,
    required this.timeLabel,
    required this.startTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) {
    final id = int.tryParse('${j['id'] ?? j['appointment_id'] ?? ''}') ?? 0;
    final doctor = ((j['doctor'] ?? j['doctor_data'] ?? {}) as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final docName = (doctor['name'] ?? j['doctor_name'] ?? j['name'] ?? '-').toString();
    final photo = (doctor['photo'] ?? doctor['photo_url'] ?? doctor['image'] ?? j['doctor_photo'] ?? j['photo_url'])?.toString();
    String spec;
    final specRaw = (doctor['specialization_name'] ?? doctor['specialization'] ?? j['specialization_name'] ?? j['specialization']);
    if (specRaw is Map) {
      spec = (specRaw['name'] ?? 'General').toString();
    } else {
      spec = (specRaw ?? 'General').toString();
    }

    String? startStr;
    if (j['start_time'] != null && j['start_time'].toString().isNotEmpty) {
      startStr = j['start_time'].toString();
    } else if (j['date'] != null) {
      final d = j['date'].toString();
      final t = (j['time'] ?? '').toString();
      startStr = (t.isNotEmpty) ? '$d $t' : d;
    } else if (j['appointment_time'] != null) {
      startStr = j['appointment_time'].toString();
    }
    DateTime start = _parseFlexibleDate(startStr) ?? DateTime.now();

    String formatDate(DateTime d) {
      const wdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final wd = wdays[(d.weekday + 6) % 7];
      final m = months[d.month - 1];
      return '$wd, ${d.day} $m';
    }

    String formatTime(DateTime d) {
      final t = TimeOfDay.fromDateTime(d);
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final mm = t.minute.toString().padLeft(2, '0');
      final p = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '${h.toString().padLeft(2, '0')}.$mm $p';
    }

    String status = (j['status'] ?? j['state'] ?? '').toString().toLowerCase();
    if (status == '1' || status == 'upcoming' || status == 'scheduled' || status == 'pending') status = 'upcoming';
    if (status == '2' || status == 'done' || status == 'completed' || status == 'complete') status = 'completed';
    if (status == '0' || status == 'cancel' || status == 'cancelled' || status == 'canceled') status = 'cancelled';
    if (status.isEmpty) {
      final now = DateTime.now();
      if (start.isBefore(now.subtract(const Duration(minutes: 1)))) {
        status = 'completed';
      } else {
        status = 'upcoming';
      }
      if (j['is_cancelled'] == true || j['cancelled'] == true) status = 'cancelled';
    }

    return Appointment(
      id: id,
      doctorName: docName,
      doctorPhotoUrl: photo,
      specialization: spec,
      dateLabel: formatDate(start),
      timeLabel: formatTime(start),
      startTime: start,
      status: status,
    );
  }

  static DateTime? _parseFlexibleDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final native = DateTime.tryParse(s);
    if (native != null) return native;
    try {
      var str = s.trim();
      final firstComma = str.indexOf(',');
      if (firstComma != -1) {
        str = str.substring(firstComma + 1).trim();
      }
      final parts = str.split(' ');
      if (parts.length >= 5) {
        final monthName = parts[0];
        final dayStr = parts[1].replaceAll(',', '');
        final yearStr = parts[2].replaceAll(',', '');
        final timeStr = parts[3];
        final ampm = (parts.length >= 5 ? parts[4] : '').toUpperCase();

        final month = _monthFromName(monthName);
        final day = int.tryParse(dayStr) ?? 1;
        final year = int.tryParse(yearStr) ?? DateTime.now().year;
        final hm = timeStr.split(':');
        var hour = int.tryParse(hm[0]) ?? 0;
        final minute = (hm.length > 1) ? int.tryParse(hm[1]) ?? 0 : 0;
        if (ampm.startsWith('P') && hour < 12) hour += 12;
        if (ampm.startsWith('A') && hour == 12) hour = 0;
        return DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}
    return null;
  }

  static int _monthFromName(String name) {
    const months = [
      'january','february','march','april','may','june','july','august','september','october','november','december'
    ];
    final ix = months.indexOf(name.toLowerCase());
    return (ix == -1) ? DateTime.now().month : ix + 1;
  }
}
