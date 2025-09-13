import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DateCarousel extends StatelessWidget {
  const DateCarousel({super.key, required this.selected, required this.onChanged, this.daysCount = 7});
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final int daysCount;

  @override
  Widget build(BuildContext context) {
    final days = List<DateTime>.generate(daysCount, (i) => DateTime.now().add(Duration(days: i)));
    return SizedBox(
      height: 106,
      child: Row(
        children: [
          _ArrowButton(
            icon: 'assets/icons/Chevron-left2.svg',
            onTap: () {
              final prev = selected.subtract(const Duration(days: 1));
              if (prev.isAfter(DateTime.now().subtract(const Duration(days: 1)))) onChanged(prev);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final d = days[i];
                final sel = d.year == selected.year && d.month == selected.month && d.day == selected.day;
                return SizedBox(
                  height: 106,
                  child: Center(
                    child: _DateChip(date: d, selected: sel, onTap: () => onChanged(d)),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: days.length,
            ),
          ),
          const SizedBox(width: 8),
          _ArrowButton(
            icon: 'assets/icons/Chevron-left2.svg',
            rotate: true,
            onTap: () {
              final next = selected.add(const Duration(days: 1));
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, this.rotate = false, required this.onTap});
  final String icon;
  final bool rotate;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Transform.rotate(
          angle: rotate ? 3.14159 : 0,
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date, required this.selected, required this.onTap});
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected ? const Color(0xFF247CFF) : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F3F5));
    final fg = selected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.60) : const Color(0xFF8F969D));
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE9ECEF);
    final w = _weekdayShort(date.weekday);
    final dd = date.day.toString().padLeft(2, '0');

    final double width = selected ? 66 : 50;
    final double height = selected ? 74 : 56;
    final double radius = 15;
    final double titleSize = selected ? 14 : 12.5;
    final double numberSize = selected ? 20 : 16;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: selected ? null : Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            if (selected && !isDark)
              const BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 6)),
            if (selected && isDark)
              BoxShadow(color: Colors.black.withValues(alpha: 0.24), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              w,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: selected ? 0.95 : 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dd,
              style: TextStyle(
                fontSize: numberSize,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday + 5) % 7];
  }
}
