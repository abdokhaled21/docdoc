import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF2F7BFF); // brand blue
  static const Color bg = Colors.white;
  static const Color faintBlue = Color(0xFF2F7BFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
      );
}
