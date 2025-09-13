import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/payment_confirm_sheet.dart';

import '../../../home/domain/doctor.dart';
import '../controllers/booking_controller.dart';
import '../../domain/appointment_type.dart';
import '../widgets/date_carousel.dart';

class BookAppointmentPage extends StatelessWidget {
  const BookAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    final doctor = args is Doctor ? args : null;

    return ChangeNotifierProvider(
      create: (_) => BookingController(doctor: doctor!),
      builder: (providerContext, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Consumer<BookingController>(
              builder: (ctx, c, _) => PopScope(
                canPop: c.step == 0,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  if (c.step > 0) {
                    c.prevStep();
                  } else {
                    Navigator.of(providerContext).pop();
                  }
                },
                child: const _Body(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();
  @override
  Widget build(BuildContext context) {
    final c = context.watch<BookingController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _Header(),
        const SizedBox(height: 30),
        _Stepper(step: c.step),
        const SizedBox(height: 32),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IndexedStack(
              index: c.step,
              children: const [
                _StepDateTime(),
                _StepPayment(),
                _StepSummary(),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: Builder(
                    builder: (context) {
                      final controller = context.watch<BookingController>();
                      final bool enabled = controller.step == 0
                          ? controller.canContinueFromStep0
                          : controller.step == 1
                              ? controller.canContinueFromStep1
                              : true;
                      return ElevatedButton(
                        onPressed: enabled
                            ? () {
                                final ctrl = context.read<BookingController>();
                                if (ctrl.step == 2) {
                                  String formatDate(DateTime d) {
                                    const wdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                                    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                                    final wd = wdays[(d.weekday + 6) % 7];
                                    final m = months[d.month - 1];
                                    final dd = d.day.toString().padLeft(2, '0');
                                    return '$wd, $dd $m ${d.year}';
                                  }
                                  String formatTime(TimeOfDay? t) {
                                    if (t == null) return '—';
                                    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
                                    final mm = t.minute.toString().padLeft(2, '0');
                                    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
                                    return '$h:$mm $p';
                                  }
                                  String typeLbl(AppointmentType t) {
                                    switch (t) {
                                      case AppointmentType.inPerson:
                                        return 'In Person';
                                      case AppointmentType.videoCall:
                                        return 'Video Call';
                                      case AppointmentType.phoneCall:
                                        return 'Phone Call';
                                    }
                                  }

                                  final dateStr = formatDate(ctrl.selectedDate);
                                  final timeStr = formatTime(ctrl.selectedTime);
                                  final typeStr = typeLbl(ctrl.appointmentType);
                                  String two(int n) => n.toString().padLeft(2, '0');
                                  final dt = DateTime(
                                    ctrl.selectedDate.year,
                                    ctrl.selectedDate.month,
                                    ctrl.selectedDate.day,
                                    ctrl.selectedTime?.hour ?? 0,
                                    ctrl.selectedTime?.minute ?? 0,
                                  );
                                  final startTimeString = '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => PaymentConfirmSheet(
                                      doctor: ctrl.doctor,
                                      dateString: dateStr,
                                      timeString: timeStr,
                                      typeLabel: typeStr,
                                      startTimeString: startTimeString,
                                    ),
                                  );
                                } else {
                                  ctrl.nextStep();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF247CFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF247CFF).withValues(alpha: 0.35),
                          disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          controller.step == 2 ? 'Confirm' : 'Continue',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    final bg = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SquareIconButton(
            bg: bg,
            border: border,
            child: SvgPicture.asset('assets/icons/Chevron-left2.svg', width: 18, height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
            onTap: () {
              final ctrl = context.read<BookingController>();
              if (ctrl.step > 0) {
                ctrl.prevStep();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const Spacer(),
          Text(
            'Book Appointment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
          ),
          const Spacer(),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.bg, required this.border, required this.child, required this.onTap});
  final Color bg;
  final Color border;
  final Widget child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});
  final int step;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const blue = Color(0xFF247CFF);
    const green = Color(0xFF22C55E);
    Color stepColor(int i) {
      if (i < step) return green;
      if (i == step) return blue;
      return isDark ? Colors.white.withValues(alpha: 0.24) : const Color(0xFFE9ECEF);
    }
    Color dot(int i) => stepColor(i);
    Color label(int i) {
      if (i < step) return green;
      if (i == step) return blue;
      return isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278);
    }
    const titles = ['Date & Time', 'Payment', 'Summary'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < 3; i++) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: dot(i),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titles[i],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: label(i)),
                ),
              ],
            ),
            if (i < 2)
              SizedBox(
                width: 56,
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.only(top: 28, left: 4, right: 4),
                  decoration: BoxDecoration(
                    color: i < step ? green : (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE9ECEF)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1D1E20),
        )),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StepDateTime extends StatelessWidget {
  const _StepDateTime();
  @override
  Widget build(BuildContext context) {
    final c = context.watch<BookingController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Select Date', trailing: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: c.selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (!context.mounted) return;
              if (date != null) context.read<BookingController>().setDate(date);
            },
            child: Text('Set Manual', style: TextStyle(color: const Color(0xFF247CFF), fontWeight: FontWeight.w700)),
          )),
          const SizedBox(height: 16),
          DateCarousel(selected: c.selectedDate, onChanged: (d) => context.read<BookingController>().setDate(d)),
          const SizedBox(height: 28),
          _SectionTitle(
            'Available time',
            trailing: context.watch<BookingController>().isLoadingBooked
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          _TimeGrid(
            times: c.timeSlotsForSelectedDate,
            selected: c.selectedTime,
            onSelect: (t) {
              final ctrl = context.read<BookingController>();
              if (ctrl.isLoadingBooked) {
                ctrl.clearTime();
                return;
              }
              ctrl.setTime(t);
            },
            booked: c.bookedTimesForSelectedDate,
            loading: c.isLoadingBooked,
          ),
          const SizedBox(height: 28),
          _SectionTitle('Appointment Type'),
          const SizedBox(height: 12),
          _AppointmentTypeList(
            selected: c.appointmentType,
            onChanged: (t) => context.read<BookingController>().setAppointmentType(t),
          ),
        ],
      ),
    );
  }
}

class _StepPayment extends StatelessWidget {
  const _StepPayment();
  @override
  Widget build(BuildContext context) {
    final c = context.watch<BookingController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Payment Option'),
          const SizedBox(height: 14),
          _PaymentOptionList(
            selectedKey: c.paymentMethod,
            onChanged: (key) => context.read<BookingController>().setPaymentMethod(key),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionList extends StatelessWidget {
  const _PaymentOptionList({required this.selectedKey, required this.onChanged});
  final String? selectedKey;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final key = selectedKey ?? '';
    final group = key.startsWith('credit') ? 'credit' : key;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaymentGroupRadioTile(
          title: 'Credit Card',
          selected: group == 'credit',
          onTap: () => onChanged('credit'),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 35, top: 8, bottom: 8),
            child: _BrandList(
              selectedKey: key,
              onSelect: (brand) => onChanged('credit:$brand'),
            ),
          ),
          crossFadeState: group == 'credit' ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
        const SizedBox(height: 20),
        _PaymentGroupRadioTile(
          title: 'Bank Transfer',
          selected: group == 'bank',
          onTap: () => onChanged('bank'),
        ),
        const SizedBox(height: 20),
        _PaymentGroupRadioTile(
          title: 'Paypal',
          selected: group == 'paypal',
          onTap: () => onChanged('paypal'),
        ),
      ],
    ));
  }
}

class _PaymentGroupRadioTile extends StatelessWidget {
  const _PaymentGroupRadioTile({required this.title, required this.selected, required this.onTap});
  final String title;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          _Radio(selected: selected),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }
}

class _BrandList extends StatelessWidget {
  const _BrandList({required this.selectedKey, required this.onSelect});
  final String selectedKey;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('master', 'Master Card'),
      ('amex', 'American Express'),
      ('capital', 'Capital One'),
      ('barclays', 'Barclays'),
    ];
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _BrandItem(
            title: items[i].$2,
            brandKey: items[i].$1,
            selected: selectedKey == 'credit:${items[i].$1}',
            onTap: () => onSelect(items[i].$1),
          ),
          if (i < items.length - 1)
            const Divider(height: 18, thickness: 1),
        ],
        const Divider(height: 18, thickness: 1),
      ],
    );
  }
}

class _BrandItem extends StatelessWidget {
  const _BrandItem({required this.title, required this.brandKey, required this.selected, required this.onTap});
  final String title;
  final String brandKey;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _BrandBadge(brandKey: brandKey),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
            if (selected)
              const Icon(Icons.check, color: Color(0xFF247CFF), size: 18),
          ],
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.brandKey});
  final String brandKey;
  @override
  Widget build(BuildContext context) {
    String asset;
    switch (brandKey) {
      case 'master':
        asset = 'assets/icons/mastercard.svg';
        break;
      case 'amex':
        asset = 'assets/icons/American_Express.svg';
        break;
      case 'capital':
        asset = 'assets/icons/Capital_One.svg';
        break;
      default:
        asset = 'assets/icons/Barclays.svg';
    }
    return SvgPicture.asset(
      asset,
      width: 48,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}

class _StepSummary extends StatelessWidget {
  const _StepSummary();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.watch<BookingController>();
    final divider = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF);

    String formatDate(DateTime d) {
      const wdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      final wd = wdays[(d.weekday + 6) % 7];
      final m = months[d.month - 1];
      final dd = d.day.toString().padLeft(2, '0');
      return '$wd, $dd $m ${d.year}';
    }

    String formatTime(TimeOfDay? t) {
      if (t == null) return '—';
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final mm = t.minute.toString().padLeft(2, '0');
      final p = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$h:$mm $p';
    }

    String typeLabel(AppointmentType t) {
      switch (t) {
        case AppointmentType.inPerson:
          return 'In Person';
        case AppointmentType.videoCall:
          return 'Video Call';
        case AppointmentType.phoneCall:
          return 'Phone Call';
      }
    }

    String paymentTitle(String? key) {
      if (key == null || key.isEmpty) return '—';
      if (key.startsWith('credit:')) {
        final b = key.split(':').last;
        switch (b) {
          case 'master':
            return 'Master Card';
          case 'amex':
            return 'American Express';
          case 'capital':
            return 'Capital One';
          case 'barclays':
            return 'Barclays';
        }
      }
      if (key == 'bank') return 'Bank Transfer';
      if (key == 'paypal') return 'Paypal';
      return '—';
    }

    final date = c.selectedDate;
    final time = c.selectedTime;
    final type = c.appointmentType;
    final titlePayment = paymentTitle(c.paymentMethod);
    final brandKey = (c.paymentMethod ?? '').replaceFirst('credit:', '');

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const _SectionTitle('Booking Information'),
          const SizedBox(height: 20),
          _SummaryTile(
            icon: 'assets/icons/calendar-2.svg',
            title: 'Date & Time',
            subtitle: '${formatDate(date)}\n${formatTime(time)}',
            iconBg: isDark ? const Color(0x1A247CFF) : const Color(0xFFEAF2FF),
            iconColor: const Color(0xFF247CFF),
          ),
          const SizedBox(height: 16),
          Divider(height: 18, thickness: 1, color: divider),
          const SizedBox(height: 16),
          _SummaryTile(
            icon: 'assets/icons/Appointment_Type.svg',
            title: 'Appointment Type',
            subtitle: typeLabel(type),
            iconBg: isDark ? const Color(0x1A22C55E) : const Color(0xFFE8F9EE),
            iconColor: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 16),
          Divider(height: 18, thickness: 1, color: divider),

          const SizedBox(height: 16),
          const _SectionTitle('Doctor Information'),
          const SizedBox(height: 20),
          _DoctorCard(
            id: c.doctor.id,
            name: c.doctor.name,
            speciality: c.doctor.specializationName ?? '—',
            city: c.doctor.cityName ?? '—',
            phone: c.doctor.phone ?? '-',
            image: c.doctor.photoUrl,
          ),

          const SizedBox(height: 16),
          const _SectionTitle('Payment Information'),
          const SizedBox(height: 12),
          _PaymentSummaryRow(
            title: titlePayment,
            brandKey: brandKey.isEmpty ? (c.paymentMethod ?? '') : brandKey,
            onChange: () => context.read<BookingController>().prevStep(),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.icon, required this.title, required this.subtitle, this.iconBg, this.iconColor});
  final String icon;
  final String title;
  final String subtitle;
  final Color? iconBg;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final sub = isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6C7278);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg ?? (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F3F5)),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(icon, width: 26, height: 26,
              colorFilter: ColorFilter.mode(iconColor ?? textColor, BlendMode.srcIn)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: textColor)),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: sub, height: 1.3, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.id, required this.name, required this.speciality, required this.city, required this.phone, this.image});
  final int id;
  final String name;
  final String speciality;
  final String city;
  final String phone;
  final String? image;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final sub = isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6C7278);
    final fallbackIx = ((id) % 5) + 1;
    final fallbackAsset = fallbackIx == 5 ? 'assets/images/doctor5.jpg' : 'assets/images/doctor$fallbackIx.png';

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 64,
            height: 64,
            child: () {
              final url = image?.trim() ?? '';
              final looksHttp = url.startsWith('http://') || url.startsWith('https://');
              final isPlaceholder = url.contains('via.placeholder.com');
              if (looksHttp && !isPlaceholder) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stack) {
                    return Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium);
                  },
                );
              }
              return Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium);
            }(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dr. $name', style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(child: Text(speciality, style: TextStyle(color: sub))),
                  const SizedBox(width: 8),
                  Text(' | ', style: TextStyle(color: sub)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(city, style: TextStyle(color: sub))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SvgPicture.asset('assets/icons/send-2.svg', width: 18, height: 18,
                      colorFilter: const ColorFilter.mode(Color(0xFF6C7278), BlendMode.srcIn)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      phone,
                      style: TextStyle(color: sub, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentSummaryRow extends StatelessWidget {
  const _PaymentSummaryRow({required this.title, required this.onChange, required this.brandKey});
  final String title;
  final VoidCallback onChange;
  final String brandKey;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF);
    Widget logo() {
      switch (brandKey) {
        case 'master':
        case 'amex':
        case 'capital':
        case 'barclays':
          return _BrandBadge(brandKey: brandKey);
        case 'paypal':
          return Image.asset('assets/images/paypal.png', width: 48, height: 24, fit: BoxFit.contain);
        case 'bank':
          return Image.asset('assets/images/Bank_Transfer.png', width: 48, height: 24, fit: BoxFit.contain);
        default:
          return _BrandBadge(brandKey: 'barclays');
      }
    }

    return Column(
      children: [
        Row(
          children: [
            logo(),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF247CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFBFD6FF)),
                ),
              ),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(height: 18, thickness: 1, color: divider),
      ],
    );
  }
}
class _TimeGrid extends StatelessWidget {
  const _TimeGrid({required this.times, required this.selected, required this.onSelect, required this.booked, this.loading = false});
  final List<TimeOfDay> times;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onSelect;
  final Set<TimeOfDay> booked;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final spacing = 14.0;
        final itemW = (width - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (final t in times)
              _TimeChip(
                width: itemW,
                label: _formatTime(t),
                selected: selected == t,
                disabled: loading || booked.contains(t),
                onTap: () => onSelect(t),
              ),
          ],
        );
      },
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    final hh = h.toString().padLeft(2, '0');
    return '$hh.$m $suffix';
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.width, required this.label, required this.selected, required this.onTap, this.disabled = false});
  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBg = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F3F5);
    final disabledBg = isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFE9ECEF);
    final bg = disabled ? disabledBg : (selected ? const Color(0xFF247CFF) : baseBg);
    final baseFg = isDark ? Colors.white.withValues(alpha: 0.60) : const Color(0xFFB0B6BC);
    final fg = disabled ? (isDark ? Colors.white.withValues(alpha: 0.30) : const Color(0xFFADB5BD)) : (selected ? Colors.white : baseFg);
    final border = disabled
        ? (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE0E3E7))
        : (selected ? const Color(0xFF247CFF) : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE9ECEF)));
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: [
                if (!isDark && selected)
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (disabled)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFDEE2E6)),
                  ),
                  child: Text(
                    'Booked',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF495057)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentTypeList extends StatelessWidget {
  const _AppointmentTypeList({required this.selected, required this.onChanged});
  final AppointmentType selected;
  final ValueChanged<AppointmentType> onChanged;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF);
    final personBg = isDark ? const Color(0x1A247CFF) : const Color(0xFFEAF2FF);
    final personIcon = const Color(0xFF247CFF);
    final videoBg = isDark ? const Color(0x1A22C55E) : const Color(0xFFE8F9EE);
    final videoIcon = const Color(0xFF22C55E);
    final phoneIcon = const Color(0xFFFF3B30);
    return Column(
      children: [
        _TypeTile(
          icon: 'assets/icons/person.svg',
          title: 'In Person',
          selected: selected == AppointmentType.inPerson,
          onTap: () => onChanged(AppointmentType.inPerson),
          iconBg: personBg,
          iconColor: personIcon,
        ),
        Divider(height: 12, thickness: 1, color: divider),
        _TypeTile(
          icon: 'assets/icons/video3.svg',
          title: 'Video Call',
          selected: selected == AppointmentType.videoCall,
          onTap: () => onChanged(AppointmentType.videoCall),
          iconBg: videoBg,
          iconColor: videoIcon,
        ),
        Divider(height: 12, thickness: 1, color: divider),
        _TypeTile(
          icon: 'assets/icons/call.svg',
          title: 'Phone Call',
          selected: selected == AppointmentType.phoneCall,
          onTap: () => onChanged(AppointmentType.phoneCall),
          iconBg: Colors.transparent,
          iconColor: phoneIcon,
        ),
        Divider(height: 12, thickness: 1, color: divider),
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.icon, required this.title, required this.selected, required this.onTap, this.iconBg, this.iconColor});
  final String icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconBg;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                icon,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(iconColor ?? (isDark ? Colors.white : const Color(0xFF1D1E20)), BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: textColor))),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final border = selected ? const Color(0xFF247CFF) : const Color(0xFFBFD6FF);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? const Color(0xFF247CFF) : Colors.transparent,
        ),
      ),
    );
  }
}
