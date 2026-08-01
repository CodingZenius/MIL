import 'package:flutter/material.dart';

/// FitPulse visual identity:
/// bold typography + dynamic Material 3 color, bright blue / red / near-black.
class AppColors {
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color pulseRed = Color(0xFFFF1744);
  static const Color emberRed = Color(0xFFB71C1C);
  static const Color voidBlack = Color(0xFF0A0A0C);
  static const Color surfaceBlack = Color(0xFF141417);
  static const Color cardBlack = Color(0xFF1C1C21);
  static const Color mist = Color(0xFFEAEAF0);
}

class AppTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.electricBlue,
      brightness: Brightness.dark,
      primary: AppColors.electricBlue,
      secondary: AppColors.pulseRed,
      surface: AppColors.surfaceBlack,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.voidBlack,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            fontFamily: 'Roboto',
            bodyColor: AppColors.mist,
            displayColor: AppColors.mist,
          )
          .copyWith(
            displayLarge: const TextStyle(
              fontSize: 57,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
            headlineMedium: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            titleLarge: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBlack,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.mist,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Smooth fluid fade+scale transition used across the app (Android 16 style
/// "fade through" motion) since flutter's built-in FadeThroughTransition
/// requires the animations package; this is a lightweight local reimplementation.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
