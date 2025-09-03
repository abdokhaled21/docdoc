import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../home/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _exitController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _exitScale;
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

    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack);
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);

    _exitScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    // play intro
    _logoController.forward();

    // after a short delay, play exit then navigate
    Timer(_holdDuration + _introDuration, () async {
      await _exitController.forward();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeInOut);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(scale: Tween(begin: 0.98, end: 1.0).animate(curved), child: child),
            );
          },
        ),
      );
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: faint shapes directly from your logo.svg
          _LogoWatermark(size: size),
          // Center logo + brand
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_logoController, _exitController]),
              builder: (context, _) {
                return Transform.scale(
                  scale: _logoScale.value * _exitScale.value,
                  child: Opacity(
                    opacity: _logoFade.value * _exitFade.value,
                    child: _ForegroundLogo(),
                  ),
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
  @override
  Widget build(BuildContext context) {
    // Use the combined logo image and make it a bit larger.
    return Image.asset(
      'assets/images/logo_docdo.png',
      height: 68, // larger per request
      fit: BoxFit.contain,
    );
  }
}

class _LogoWatermark extends StatelessWidget {
  const _LogoWatermark({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    // Single large centered watermark from logo.svg
    final double targetHeight = size.height * 0.72; // big but with nice margins
    return Center(
      child: _WatermarkSvg(width: targetHeight, opacity: 0.06),
    );
  }
}

class _WatermarkSvg extends StatelessWidget {
  const _WatermarkSvg({required this.width, required this.opacity});
  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        width: width,
        fit: BoxFit.contain,
        // If you want to enforce a single tint, uncomment the colorFilter below
        // colorFilter: const ColorFilter.mode(Color(0xFF2F7BFF), BlendMode.srcIn),
      ),
    );
  }
}
