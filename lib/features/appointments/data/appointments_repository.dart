import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints.dart';
import '../domain/appointment.dart';

class AppointmentsRepository {
  AppointmentsRepository._();
  static final instance = AppointmentsRepository._();

  Future<List<Appointment>> index() async {
    final dio = DioClient.instance.dio;
    final res = await dio.get(Endpoints.appointmentIndex);
    final data = res.data;
    List list = _extractList(data);
    return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final keys = ['appointments', 'items', 'list', 'records', 'data', 'result'];
      for (final k in keys) {
        final v = data[k];
        if (v is List) return v;
        if (v is Map<String, dynamic>) {
          final inner = _extractList(v);
          if (inner.isNotEmpty) return inner;
        }
      }
      for (final v in data.values) {
        final inner = _extractList(v);
        if (inner.isNotEmpty) return inner;
      }
    }
    return const [];
  }
}
