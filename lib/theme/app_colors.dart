import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Signature AirMail Brand Palette
  static const primary = Color(0xFF2563EB); // Vibrant Royal Blue
  static const primaryLightMode = Color(0xFF1D4ED8); // Deep Blue for accents
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryAccent = Color(0xFF38BDF8); // Sky Cyan accent
  static const primaryContainerLight = Color(0xFFEFF6FF); // Soft blue tint
  static const primaryContainerDark = Color(0xFF1E293B);

  // Gradient definitions
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const skyGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Palette (Obsidian & Deep Slate)
  static const darkBg = Color(0xFF0B0F19);
  static const darkSurface = Color(0xFF111827);
  static const darkRaised = Color(0xFF1E293B);
  static const darkSurfaceContainer = Color(0xFF151C2C);
  static const darkText = Color(0xFFF8FAFC);
  static const darkMuted = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF1E293B);
  static const darkOnline = Color(0xFF10B981);
  static const darkError = Color(0xFFEF4444);

  // Light Theme Palette (Clean Airy Slate)
  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightRaised = Color(0xFFF1F5F9);
  static const lightSurfaceContainer = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF0F172A);
  static const lightMuted = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightOnline = Color(0xFF10B981);
  static const lightError = Color(0xFFEF4444);
}
