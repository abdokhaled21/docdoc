import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_router.dart';
import '../controllers/specialization_controller.dart';
import '../../domain/specialization.dart';

class DoctorSpecialityPage extends StatelessWidget {
  const DoctorSpecialityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SpecializationController()..load(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _BackButton(isDark: isDark, onTap: () => Navigator.of(context).maybePop()),
                    const Spacer(),
                    Text(
                      'Doctor Speciality',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1D1E20),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<SpecializationController>(
                  builder: (context, c, _) {
                    if (c.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = _buildItems(c.items);
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 50,
                        crossAxisSpacing: 18,
                        mainAxisExtent: 116,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final it = items[index];
                        return InkWell(
                          onTap: () {
                            if (it.id == 0) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.doctorsBySpecialization,
                                arguments: {'title': 'General', 'specId': null},
                              );
                            } else {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.doctorsBySpecialization,
                                arguments: {'title': it.label, 'specId': it.id},
                              );
                            }
                          },
                          child: _SpecialityTile(item: it, isDark: isDark),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_SpecItem> _buildItems(List<Specialization> apiItems) {
    final list = <_SpecItem>[
      const _SpecItem(0, 'General', 'assets/icons/Doctor Speciality/General.png'),
    ];
    for (final s in apiItems) {
      list.add(_SpecItem(s.id, s.name, _iconFor(s.name)));
    }
    return list;
  }

  String _iconFor(String name) {
    final key = name.toLowerCase();
    if (key.contains('cardio')) return 'assets/icons/Doctor Speciality/cardiologist.png';
    if (key.contains('derma')) return 'assets/icons/Doctor Speciality/dermatology.png';
    if (key.contains('neuro')) return 'assets/icons/Doctor Speciality/Neurology.png';
    if (key.contains('ortho')) return 'assets/icons/Doctor Speciality/orthopedics.png';
    if (key.contains('pedia')) return 'assets/icons/Doctor Speciality/Pediatric.png';
    if (key.contains('gyne')) return 'assets/icons/Doctor Speciality/gynecology.png';
    if (key.contains('ophthal') || key.contains('opto')) return 'assets/icons/Doctor Speciality/Optometry.png';
    if (key.contains('uro')) return 'assets/icons/Doctor Speciality/Urologist.png';
    if (key.contains('gastro')) return 'assets/icons/Doctor Speciality/intestine.png';
    if (key.contains('psych')) return 'assets/icons/Doctor Speciality/Psychiatry.png';
    return 'assets/icons/Doctor Speciality/General.png';
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final border = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEAECEF);
    final bg = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
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
        child: SvgPicture.asset(
          'assets/icons/Chevron-left2.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(isDark ? Colors.white : const Color(0xFF1D1E20), BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _SpecialityTile extends StatelessWidget {
  const _SpecialityTile({required this.item, required this.isDark});
  final _SpecItem item;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppColors.primary.withValues(alpha: 0.05);
    final border = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: circleColor,
            borderRadius: BorderRadius.circular(160),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: _AssetIcon(path: item.icon),
        ),
        const SizedBox(height: 10),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1D1E20),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AssetIcon extends StatelessWidget {
  const _AssetIcon({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.contain);
    }
    return Image.asset(path, fit: BoxFit.contain, filterQuality: FilterQuality.medium);
  }
}

class _SpecItem {
  final int id;
  final String label;
  final String icon;
  const _SpecItem(this.id, this.label, this.icon);
}
