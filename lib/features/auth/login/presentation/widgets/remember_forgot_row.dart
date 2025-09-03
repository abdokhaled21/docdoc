import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../controllers/login_controller.dart';

class RememberForgotRow extends StatelessWidget {
  const RememberForgotRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.70);
    return Row(
      children: [
        Consumer<LoginController>(
          builder: (context, c, _) => Transform.scale(
            scale: 1.08,
            child: Theme(
              data: theme.copyWith(
                checkboxTheme: CheckboxThemeData(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: WidgetStateBorderSide.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const BorderSide(color: AppColors.primary, width: 1.6);
                    }
                    // Grey border when not selected
                    return BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.24) : const Color(0xFFDEE2E6),
                      width: 1.4,
                    );
                  }),
                ),
              ),
              child: Checkbox(
                value: c.remember,
                onChanged: c.toggleRemember,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // Blue check to match brand
                checkColor: AppColors.primary,
                // Keep background white when selected so the blue check is clear
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    // Dark mode: use dark fill so it blends with theme, not white
                    return isDark ? const Color(0xFF1F2937) : Colors.white;
                  }
                  // Grey box when not selected
                  return isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F4F6);
                }),
                // Subtle blue hover/focus ripple
                overlayColor: WidgetStatePropertyAll(AppColors.primary.withValues(alpha: 0.08)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text('Remember me', style: theme.textTheme.bodyMedium?.copyWith(color: textColor)),
        const Spacer(),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.primary,
          ),
          child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.w600)),
        )
      ],
    );
  }
}
