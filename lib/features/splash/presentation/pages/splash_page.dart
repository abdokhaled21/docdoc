import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Navigates to onboarding via named route

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _exitController;
  late final Animation<double> _logoFade;
  late final Animation<double> _exitFade;
  static const _introDuration = Duration(milliseconds: 1000);
  static const _holdDuration = Duration(milliseconds: 2000); // keep splash longer
  static const _exitDuration = Duration(milliseconds: 550);

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: _introDuration,
    );
    _exitController = AnimationController(
      vsync: this,
      duration: _exitDuration,
    );

    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    // play intro
    _logoController.forward();

    // after a short delay, play exit then navigate
    Timer(_holdDuration + _introDuration, () async {
      await _exitController.forward();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: faint shapes directly from your logo.svg
          const _LogoWatermark(),
          // Foreground logo positioned per spec (Left: 53, Top: 370)
          Positioned(
            left: 56,
            top: 370,
            child: AnimatedBuilder(
              animation: Listenable.merge([_logoController, _exitController]),
              builder: (context, _) {
                // Keep fade only to preserve exact dimensions
                return Opacity(
                  opacity: _logoFade.value * _exitFade.value,
                  child: const _ForegroundLogo(width: 268.29, height: 72),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ForegroundLogo extends StatelessWidget {
  const _ForegroundLogo({this.width = 268.29, this.height = 72});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? 'assets/images/logo_docdo_dark.svg'
        : 'assets/images/logo_docdo.svg';
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _LogoWatermark extends StatelessWidget {
  const _LogoWatermark();

  @override
  Widget build(BuildContext context) {
    // Positioned per spec: Left -34, Top 183.93, 180° rotation, opacity 5%
    return const Positioned(
      left: -34,
      top: 183.93,
      child: _RotatedWatermark(),
    );
  }
}

class _RotatedWatermark extends StatelessWidget {
  const _RotatedWatermark();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.05,
      child: Transform.rotate(
        angle: math.pi, // 180°
        child: SizedBox(
          width: 443,
          height: 443.07,
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
