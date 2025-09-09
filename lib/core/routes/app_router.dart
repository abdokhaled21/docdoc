import 'package:flutter/material.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/signup/presentation/pages/signup_page.dart';
import '../../features/auth/forgot/presentation/pages/forgot_password_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String signup = '/signup';
  static const String forgot = '/forgot-password';
}

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.onboarding: (_) => const OnboardingPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.home: (_) => const HomePage(),
    AppRoutes.signup: (_) => const SignupPage(),
    AppRoutes.forgot: (_) => const ForgotPasswordPage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    return _unknownRoute();
  }

  static Route<dynamic> _unknownRoute() {
    // Fallback to splash if route is unknown
    return MaterialPageRoute(builder: (_) => const SplashPage());
  }
}
