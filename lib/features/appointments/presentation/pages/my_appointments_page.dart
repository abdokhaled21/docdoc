import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../controllers/appointments_controller.dart';
import '../../domain/appointment.dart';

class MyAppointmentsPage extends StatelessWidget {
  const MyAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => AppointmentsController()..load(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const MyAppointmentsBody(),
        bottomNavigationBar: AppBottomNav(
          selectedIndex: 2,
          onHome: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
          onChat: () {},
          onCalendar: () {},
          onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          onSearch: () => Navigator.of(context).pushNamed(AppRoutes.search),
        ),
      ),
    );
  }
}
class MyAppointmentsBody extends StatelessWidget {
  const MyAppointmentsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: const [
          SizedBox(height: 16),
          _Header(),
          SizedBox(height: 16),
          _TabsAndPager(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    final bg = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset('assets/icons/Chevron-left2.svg', width: 18, height: 18,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
            ),
          ),
          const Spacer(),
          Text('My Appointment', style: theme.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: iconColor)),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset('assets/icons/search-normal.svg', width: 22, height: 22,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const blue = Color(0xFF247CFF);
    final divider = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E3E7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalW = constraints.maxWidth;
          final sectionW = totalW / 3;
          return Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        _TabButton(label: 'Upcoming', index: 0, selected: selected == 0, onTap: () => onSelect(0)),
                        _TabButton(label: 'Completed', index: 1, selected: selected == 1, onTap: () => onSelect(1)),
                        _TabButton(label: 'Cancelled', index: 2, selected: selected == 2, onTap: () => onSelect(2)),
                      ],
                    ),
                  ),
                  Container(height: 2, color: divider),
                ],
              ),
              Positioned(
                bottom: 0,
                left: selected * sectionW,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  width: sectionW,
                  height: 2,
                  color: blue,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.index, required this.selected, required this.onTap});
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = const Color(0xFF247CFF);
    final base = isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF6C7278);
    
    final textStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: selected ? blue : base,
    );

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(label, style: textStyle),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsAndPager extends StatefulWidget {
  const _TabsAndPager();
  @override
  State<_TabsAndPager> createState() => _TabsAndPagerState();
}

class _TabsAndPagerState extends State<_TabsAndPager> {
  late final PageController _page = PageController(initialPage: context.read<AppointmentsController>().tabIndex);

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppointmentsController>();
    void onSelect(int i) {
      c.setTab(i);
      _page.animateToPage(i, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tabs(selected: c.tabIndex, onSelect: onSelect),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _page,
              onPageChanged: (i) => c.setTab(i),
              children: [
                _AppointmentsList(itemsSelector: (ctrl) => ctrl.upcoming),
                _AppointmentsList(itemsSelector: (ctrl) => ctrl.completed),
                _AppointmentsList(itemsSelector: (ctrl) => ctrl.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({required this.itemsSelector});
  final List<Appointment> Function(AppointmentsController) itemsSelector;
  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppointmentsController>();
    if (c.loading) return const Center(child: CircularProgressIndicator());
    final items = itemsSelector(c);
    if (items.isEmpty) return const Center(child: Text('No appointments'));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemBuilder: (_, i) => _AppointmentCard(a: items[i]),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: items.length,
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.a});
  final Appointment a;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white;
    final divider = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF);
    final green = const Color(0xFF22C55E);
    final fallbackIx = ((a.id) % 5) + 1;
    final fallbackAsset = fallbackIx == 5 ? 'assets/images/doctor5.jpg' : 'assets/images/doctor$fallbackIx.png';

    final nowPast = a.startTime.isBefore(DateTime.now().subtract(const Duration(minutes: 1)));
    final isCompleted = a.status == 'completed' || nowPast;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompleted) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appointment done', style: TextStyle(color: green, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/calendar-2.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(Color(0xFF6C7278), BlendMode.srcIn)),
                          const SizedBox(width: 6),
                          Text(a.dateLabel, style: const TextStyle(color: Color(0xFF6C7278), fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 16, color: const Color(0xFFDADDE1)),
                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/icons/clock.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(Color(0xFF6C7278), BlendMode.srcIn)),
                          const SizedBox(width: 6),
                          Text(a.timeLabel, style: const TextStyle(color: Color(0xFF6C7278), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SvgPicture.asset(
                    'assets/icons/Vector.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFFADB5BD),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 20, thickness: 1, color: divider),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: () {
                      final url = (a.doctorPhotoUrl ?? '').trim();
                      final looksHttp = url.startsWith('http://') || url.startsWith('https://');
                      final isPlaceholder = url.contains('via.placeholder.com');
                      if (looksHttp && !isPlaceholder) {
                        return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover));
                      }
                      return Image.asset(fallbackAsset, fit: BoxFit.cover);
                    }(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(a.doctorName),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1D1E20)),
                      ),
                      const SizedBox(height: 4),
                      Text(a.specialization, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: () {
                      final url = (a.doctorPhotoUrl ?? '').trim();
                      final looksHttp = url.startsWith('http://') || url.startsWith('https://');
                      final isPlaceholder = url.contains('via.placeholder.com');
                      if (looksHttp && !isPlaceholder) {
                        return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover));
                      }
                      return Image.asset(fallbackAsset, fit: BoxFit.cover);
                    }(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _displayName(a.doctorName),
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1D1E20)),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/message-text.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(Color(0xFF247CFF), BlendMode.srcIn),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(a.specialization, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/calendar-2.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(Color(0xFF6C7278), BlendMode.srcIn)),
                          const SizedBox(width: 6),
                          Text(a.dateLabel, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278), fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 16, color: isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFDADDE1)),
                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/icons/clock.svg', width: 18, height: 18, colorFilter: const ColorFilter.mode(Color(0xFF6C7278), BlendMode.srcIn)),
                          const SizedBox(width: 6),
                          Text(a.timeLabel, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6C7278), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (!isCompleted && a.status == 'upcoming') ...[
            const SizedBox(height: 12),
            Divider(height: 20, thickness: 1, color: divider),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF247CFF), width: 1.5),
                      foregroundColor: const Color(0xFF247CFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text(
                      'Cancel Appointment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF247CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text(
                      'Reschedule',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _displayName(String raw) {
    final name = raw.trim();
    final hasTitle = RegExp(r'^(dr|mr|mrs|ms|prof|professor)\.?\s', caseSensitive: false).hasMatch(name.toLowerCase());
    return hasTitle ? name : 'Dr. $name';
  }
}
