import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String tempSpec;
  late String tempCity;

  @override
  void initState() {
    super.initState();
    final controller = context.read<HomeController>();
    tempSpec = controller.selectedSpec ?? 'All';
    tempCity = controller.selectedCity ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        final specs = ['All', ...controller.getSpecializations()];
        final cities = ['All', ...controller.getCities()];
        
        final dividerColor = isDark 
            ? Colors.white.withValues(alpha: 0.08) 
            : const Color(0xFFEAECEF);
        
        final textColor = isDark 
            ? Colors.white 
            : const Color(0xFF1D1E20);
            
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
                        FilterChip(
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
                        FilterChip(
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
                    onPressed: () {
                      controller.setSpecializationFilter(tempSpec);
                      controller.setCityFilter(tempCity);
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = selected
        ? const Color(0xFF247CFF)
        : (isDark 
            ? Colors.white.withValues(alpha: 0.04) 
            : const Color(0xFFF8F9FA));
        
    final borderColor = selected
        ? const Color(0xFF247CFF)
        : (isDark 
            ? Colors.white.withValues(alpha: 0.08) 
            : const Color(0xFFE9ECEF));
            
    final textColor = selected
        ? Colors.white
        : (isDark 
            ? Colors.white.withValues(alpha: 0.4) 
            : const Color(0xFFADB5BD));
            
    final iconColor = selected
        ? Colors.white
        : (isDark 
            ? Colors.white.withValues(alpha: 0.3) 
            : const Color(0xFFADB5BD));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
