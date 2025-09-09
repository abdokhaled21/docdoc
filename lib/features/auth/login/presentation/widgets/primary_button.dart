import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.onDisabledPressed,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;
  final VoidCallback? onDisabledPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Stack(
        children: [
          Positioned.fill(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppColors.primary, width: 1),
                elevation: 0,
              ),
              onPressed: enabled && !loading
                  ? () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      onPressed?.call();
                    }
                  : null,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(
                      text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          if (!enabled && !loading && onDisabledPressed != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onDisabledPressed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
