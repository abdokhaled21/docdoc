import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_router.dart';
import '../controllers/specialization_controller.dart';
import '../../domain/specialization.dart';

class SpecialitySection extends StatelessWidget {
  const SpecialitySection({super.key, this.onSeeAll});
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SpecializationController()..load(),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Doctor Speciality',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1D1E20),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSeeAll ?? () => Navigator.of(context).pushNamed(AppRoutes.doctorSpeciality),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF247CFF),
                    ),
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Color(0xFF247CFF)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<SpecializationController>(
                  builder: (context, c, _) {
                    final List<_HomeSpecItem> items = _buildHomeItems(c.items);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items
                          .map(
                            (it) => _HomeSpecTile(
                              isDark: isDark,
                              icon: it.icon,
                              label: it.label,
                              onTap: () {
                                if (it.specId == null) {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.doctorsBySpecialization,
                                    arguments: {'title': it.label, 'specId': null},
                                  );
                                } else {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.doctorsBySpecialization,
                                    arguments: {'title': it.label, 'specId': it.specId},
                                  );
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSpecItem {
  final String icon;
  final String label;
  final int? specId;
  const _HomeSpecItem(this.icon, this.label, this.specId);
}

class _HomeSpecTile extends StatefulWidget {
  const _HomeSpecTile({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final bool isDark;
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_HomeSpecTile> createState() => _HomeSpecTileState();
}

class _HomeSpecTileState extends State<_HomeSpecTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final splash = const Color(0xFF247CFF).withValues(alpha: isDark ? 0.20 : 0.12);
    return SizedBox(
      width: 72,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              scale: _pressed ? 0.96 : 1.0,
              child: Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: splash,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: _pressed ? 0.08 : 0.06)
                          : (_pressed ? const Color(0xFFEAF2FF) : const Color(0xFFF4F8FF)),
                      shape: BoxShape.circle,
                      border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.06)) : null,
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: _pressed ? 0.10 : 0.06),
                            blurRadius: _pressed ? 14 : 8,
                            offset: Offset(0, _pressed ? 6 : 3),
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      widget.icon,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1D1E20),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_HomeSpecItem> _buildHomeItems(List<Specialization> apiSpecs) {
  int? idFor(String name) {
    final k = name.toLowerCase();
    for (final s in apiSpecs) {
      final n = s.name.toLowerCase();
      if (n.contains(k) || k.contains(n)) return s.id;
    }
    return null;
  }

  return [
    const _HomeSpecItem('assets/icons/Doctor Speciality/General.png', 'General', null),
    _HomeSpecItem('assets/icons/Doctor Speciality/Pediatric.png', 'Pediatrics', idFor('pediatrics')),
    _HomeSpecItem('assets/icons/Doctor Speciality/Neurology.png', 'Neurology', idFor('neurology')),
    _HomeSpecItem('assets/icons/Doctor Speciality/Urologist.png', 'Urologist', idFor('urology')),
  ];
}
