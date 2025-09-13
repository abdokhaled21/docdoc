import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialSection extends StatelessWidget {
  const SocialSection({super.key});

  Widget _social(BuildContext context, String asset, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isApple = asset.contains('apple');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          asset,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          colorFilter: isApple && isDark
              ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _social(context, 'assets/icons/social_google.svg', () {}),
        const SizedBox(width: 36),
        _social(context, 'assets/icons/social_facebook.svg', () {}),
        const SizedBox(width: 36),
        _social(context, 'assets/icons/social_apple.svg', () {}),
      ],
    );
  }
}
