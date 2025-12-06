import 'package:flutter/material.dart';

// API Base URL Configuration
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // MiraiFest Event Details
  static const String eventName = 'MiraiFest 2025';
  static const String eventLocation = 'Gedung Serbaguna ULM Banjarbaru';
  static final DateTime eventDate = DateTime(2025, 12, 13);
  static const String eventDescription =
      'Festival cosplay tahunan terbesar di Indonesia yang menghadirkan '
      'guest stars, cosplay competition, live performance, dan berbagai aktivitas menarik!';

  // App Colors - New Brand Palette
  static const Color primaryDarkPurple = Color(0xFF1E0359);
  static const Color primaryPurple = Color(0xFF724EBF);
  static const Color accentGold = Color(0xFFF2B807);
  static const Color secondaryGold = Color(0xFFA67926);
  static const Color lightGray = Color(0xFFF2F2F2);

  // Legacy compatibility
  static const Color primaryPink = accentGold;
  static const Color primaryCyan = accentGold;
  static const Color accentOrange = secondaryGold;
  static const Color backgroundDark = primaryDarkPurple;
  static const Color cardDark = Color(0xFF2A0959);
  static const Color textLight = lightGray;
  static const Color textGray = Color(0xFFB8B8B8);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryDarkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentGold, secondaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
}
