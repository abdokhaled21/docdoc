import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF247CFF);
  static const Color bg = Colors.white;
  static const Color faintBlue = Color(0xFF247CFF);
  static const Color bgDark = Color(0xFF0F1115);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.bg,
    );
    final interText = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: interText.copyWith(
        headlineSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: 0.3,
          fontSize: interText.headlineSmall?.fontSize,
        ),
      ),
      primaryTextTheme: interText,
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
    );
    final interText = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: interText.copyWith(
        headlineSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.3,
          fontSize: interText.headlineSmall?.fontSize,
        ),
      ),
      primaryTextTheme: interText,
    );
  }
}
