import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/storage/local_storage.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const baseW = 375.0;
    const baseH = 812.0;
    final sw = size.width / baseW;
    final sh = size.height / baseH;
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _BackgroundWatermark(sw: sw, sh: sh),

          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).padding.top + 20 * sh,
            child: const _TopBrand(),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        left: 0,
                        top: 120.5 * sh,
                        child: ClipRect(
                          child: SizedBox(
                            width: 375 * sw,
                            height: 491 * sh,
                            child: Image.asset(
                              'assets/images/onboarding.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 372.5 * sh,
                        child: IgnorePointer(
                          child: Container(
                            width: 375 * sw,
                            height: 239 * sh,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  bgColor,
                                  bgColor,
                                  bgColor.withValues(alpha: 0.80),
                                  bgColor.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.20, 0.40, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 504.5 * sh,
                        child: const _Title(),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 608.5 * sh,
                        child: const _Subtitle(),
                      ),
                    ],
                  ),
                ),

                const SizedBox.shrink(),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 703 * sh,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 327 * sw, height: 56),
                child: _PrimaryButton(
                  text: 'Get Started',
                  onPressed: () async {
                    await LocalStorage.instance.setOnboardingSeen(true);
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBrand extends StatelessWidget {
  const _TopBrand();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const baseW = 375.0;
    const baseH = 812.0;
    final sw = size.width / baseW;
    final sh = size.height / baseH;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/images/logo_docdo_dark.svg'
        : 'assets/images/logo_docdo.svg';
    return SizedBox(
      width: 160 * sw,
      height: 43 * sh,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _BackgroundWatermark extends StatelessWidget {
  const _BackgroundWatermark({required this.sw, required this.sh});
  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -87 * sw,
      top: 144.93 * sh,
      child: Opacity(
        opacity: 0.06,
        child: Transform.rotate(
          angle: math.pi,
          child: SizedBox(
            width: 443 * sw,
            height: 443.07 * sh,
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Color(0xFF247CFF), BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const baseW = 375.0;
    final sw = size.width / baseW;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 315 * sw),
        child: Text(
          'Best Doctor\nAppointment App',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 32,
                height: 1.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const baseW = 375.0;
    final sw = size.width / baseW;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.70);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 312 * sw),
        child: Text(
          'Manage and schedule all of your medical appointments easily with Docdoc to get a new experience.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: color,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: AppColors.primary, width: 1),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
