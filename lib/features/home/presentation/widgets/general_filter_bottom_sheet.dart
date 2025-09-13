import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/doctors_controller.dart';

class GeneralFilterBottomSheet extends StatelessWidget {
  const GeneralFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<DoctorsController>(
      builder: (context, c, _) {
        String tempSpec = c.selectedSpec ?? 'All';
        String tempCity = c.selectedCity ?? 'All';
        final specs = c.getSpecializations();
        final cities = c.getCities();

        return StatefulBuilder(
          builder: (context, setState) {
            final dividerColor = isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEAECEF);
            final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
            final sectionTitleColor = isDark
                ? Colors.white.withValues(alpha: 0.9)
                : const Color(0xFF1D1E20);

            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: dividerColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Sort By',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Speciality',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: sectionTitleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          for (int i = 0; i < specs.length; i++) ...[
                            _AppChoiceChip(
                              label: specs[i],
                              selected: tempSpec.toLowerCase() == specs[i].toLowerCase(),
                              onTap: () => setState(() => tempSpec = specs[i]),
                            ),
                            if (i < specs.length - 1) const SizedBox(width: 12),
                          ]
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'City',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: sectionTitleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          for (int i = 0; i < cities.length; i++) ...[
                            _AppChoiceChip(
                              label: cities[i],
                              selected: tempCity.toLowerCase() == cities[i].toLowerCase(),
                              onTap: () => setState(() => tempCity = cities[i]),
                            ),
                            if (i < cities.length - 1) const SizedBox(width: 12),
                          ]
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF247CFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          c.setSpecializationFilter(tempSpec);
                          await c.setCityFilter(tempCity);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppChoiceChip extends StatelessWidget {
  const _AppChoiceChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = selected
        ? const Color(0xFF247CFF)
        : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F9FA));
    final Color border = selected
        ? const Color(0xFF247CFF)
        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE9ECEF));
    final Color fg = selected
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFFADB5BD));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
