import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/app_router.dart';

import '../../../home/domain/doctor.dart';

class BookingConfirmResultPage extends StatelessWidget {
  const BookingConfirmResultPage({super.key, required this.doctor, required this.dateString, required this.timeString, required this.typeLabel});

  final Doctor doctor;
  final String dateString;
  final String timeString;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final divider = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF);
    final iconColor = isDark ? Colors.white : const Color(0xFF1D1E20);

    void goToDoctorDetails() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = Navigator.of(context);
        bool reachedDoctorDetails = false;
        nav.popUntil((route) {
          final isTarget = route.settings.name == AppRoutes.doctorDetails;
          if (isTarget) reachedDoctorDetails = true;
          return isTarget;
        });
        if (!reachedDoctorDetails) {
          nav.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
        }
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PopScope(
        canPop: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    _SquareIconButton(
                      bg: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                      border: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF),
                      onTap: goToDoctorDetails,
                      child: SvgPicture.asset('assets/icons/Chevron-left2.svg', width: 18, height: 18,
                          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
                    ),
                    const Spacer(),
                    Text('Details', style: theme.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: iconColor)),
                    const Spacer(),
                    const SizedBox(width: 42),
                  ],
                ),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/icons/done.svg', width: 96, height: 96),
                      const SizedBox(height: 16),
                      const Text('Booking Confirmed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Text('Booking Information', style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: iconColor)),
                const SizedBox(height: 14),
                _SummaryTile(
                  icon: 'assets/icons/calendar-2.svg',
                  title: 'Date & Time',
                  subtitle: '$dateString\n$timeString',
                  iconBg: isDark ? const Color(0x1A247CFF) : const Color(0xFFEAF2FF),
                  iconColor: const Color(0xFF247CFF),
                ),
                const SizedBox(height: 16),
                Divider(height: 18, thickness: 1, color: divider),
                const SizedBox(height: 16),
                _SummaryTile(
                  icon: 'assets/icons/Appointment_Type.svg',
                  title: 'Appointment Type',
                  subtitle: typeLabel,
                  iconBg: isDark ? const Color(0x1A22C55E) : const Color(0xFFE8F9EE),
                  iconColor: const Color(0xFF22C55E),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF247CFF),
                      side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFBFD6FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Get Location'),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 18, thickness: 1, color: divider),
                const SizedBox(height: 20),
                Text('Doctor Information', style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: iconColor)),
                const SizedBox(height: 14),
                _DoctorCard(doctor: doctor),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: goToDoctorDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF247CFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.icon, required this.title, required this.subtitle, this.iconBg, this.iconColor, this.trailing});
  final String icon;
  final String title;
  final String subtitle;
  final Color? iconBg;
  final Color? iconColor;
  final Widget? trailing;
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
          child: SvgPicture.asset(icon, width: 26, height: 26, colorFilter: ColorFilter.mode(iconColor ?? textColor, BlendMode.srcIn)),
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
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Center(child: trailing!),
        ],
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});
  final Doctor doctor;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final sub = isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6C7278);

    final fallbackIx = ((doctor.id) % 5) + 1;
    final fallbackAsset = fallbackIx == 5 ? 'assets/images/doctor5.jpg' : 'assets/images/doctor$fallbackIx.png';

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 64,
            height: 64,
            child: () {
              final url = (doctor.photoUrl ?? '').trim();
              final looksHttp = url.startsWith('http://') || url.startsWith('https://');
              final isPlaceholder = url.contains('via.placeholder.com');
              if (looksHttp && !isPlaceholder) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stack) => Image.asset(fallbackAsset, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
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
              Text('Dr. ${doctor.name}', style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(child: Text(doctor.specializationName ?? '—', style: TextStyle(color: sub))),
                  const SizedBox(width: 8),
                  Text(' | ', style: TextStyle(color: sub)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(doctor.cityName ?? (doctor.hospitalName ?? '—'), style: TextStyle(color: sub))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
