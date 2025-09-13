import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../home/domain/doctor.dart';
import '../pages/booking_confirm_result_page.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/endpoints.dart';

class PaymentConfirmSheet extends StatelessWidget {
  const PaymentConfirmSheet({super.key, required this.doctor, required this.dateString, required this.timeString, required this.typeLabel, required this.startTimeString});

  final Doctor doctor;
  final String dateString;
  final String timeString;
  final String typeLabel;
  final String startTimeString;

  num get subtotal => doctor.appointPrice ?? 0;
  num get tax => (subtotal * 0.053).round();
  num get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1E22) : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.30,
      maxChildSize: 0.70,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -8))],
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE9ECEF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Info',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _KVRow('Subtotal', '\$$subtotal'),
                      const SizedBox(height: 12),
                      _KVRow('Tax', '\$$tax'),
                      const SizedBox(height: 16),
                      Divider(color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF)),
                      const SizedBox(height: 16),
                      _KVRow('Payment Total', '\$$total', bold: true, big: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    String? errorMsg;
                    try {
                      final dio = DioClient.instance.dio;
                      await dio.post(
                        Endpoints.appointmentStore,
                        data: FormData.fromMap({
                          'doctor_id': doctor.id.toString(),
                          'start_time': startTimeString,
                          'notes': typeLabel,
                        }),
                      );
                    } catch (e) {
                      errorMsg = 'Failed to create appointment. Please try again.';
                    } finally {
                      navigator.pop();
                    }

                    if (errorMsg != null) {
                      messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
                      return;
                    }

                    navigator.pop();
                    navigator.popUntil((route) => route.settings.name == AppRoutes.doctorDetails);
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmResultPage(
                          doctor: doctor,
                          dateString: dateString,
                          timeString: timeString,
                          typeLabel: typeLabel,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF247CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow(this.label, this.value, {this.bold = false, this.big = false});
  final String label;
  final String value;
  final bool bold;
  final bool big;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6C7278);
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.w600, fontSize: big ? 16 : 15))),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            fontSize: big ? 18 : 16,
          ),
        ),
      ],
    );
  }
}
