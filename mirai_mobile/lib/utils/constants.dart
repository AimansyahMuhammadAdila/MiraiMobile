import 'package:flutter/material.dart';

// API Base URL Configuration
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost/MiraiMobile/api/v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // MiraiFest Event Details
  static const String eventName = 'MiraiFest 2025';
  static const String eventLocation = 'Jakarta Convention Center';
  static final DateTime eventDate = DateTime(2025, 12, 20);
  static const String eventDescription =
      'Festival cosplay tahunan terbesar di Indonesia yang menghadirkan '
      'guest stars, cosplay competition, live performance, dan berbagai aktivitas menarik!';

  // App Colors - Japanese Pop Culture Inspired
  static const Color primaryPurple = Color(0xFF9333EA);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFF59E0B);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textGray = Color(0xFF94A3B8);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryCyan, primaryPurple],
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
