import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/storage/local_storage.dart';

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
  static const _holdDuration = Duration(milliseconds: 2000);
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

    _logoController.forward();

    Timer(_holdDuration + _introDuration, () async {
      await _exitController.forward();
      if (!mounted) return;
      final token = await LocalStorage.instance.getToken();
      String next;
      if (token != null && token.isNotEmpty) {
        next = AppRoutes.home;
      } else {
        final seen = await LocalStorage.instance.getOnboardingSeen();
        next = seen ? AppRoutes.login : AppRoutes.onboarding;
      }
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(next, (route) => false);
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
          const _LogoWatermark(),
          Positioned(
            left: 56,
            top: 370,
            child: AnimatedBuilder(
              animation: Listenable.merge([_logoController, _exitController]),
              builder: (context, _) {
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
        angle: math.pi,
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
