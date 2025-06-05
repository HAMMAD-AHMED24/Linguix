import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Custom colors
  static const Color primaryNavy = Color(0xFF1A2A44);
  static const Color accentGold = Color(0xFFD4A017);
  static const Color softWhite = Color(0xFFF5F5F5);
  static const Color accentTeal = Color(0xFF4A919E); // New teal accent

  // Gradient for backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryNavy, Colors.black],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    return ThemeData(
      // Color scheme
      primaryColor: primaryNavy,
      scaffoldBackgroundColor: softWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: accentGold,
        tertiary: accentTeal, // New teal for icons/buttons
        surface: softWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onTertiary: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.lora(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryNavy,
        ),
        headlineMedium: GoogleFonts.lora(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryNavy,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black54,
        ),
      ),

      // Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Secondary button style (using teal)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentTeal,
          side: const BorderSide(color: accentTeal, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Card styling
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black38, // Slightly darker shadow for contrast
      ),

      // Dropdown menu styling
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: primaryNavy,
        ),
      ),

      // AppBar styling
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // Icon styling
      iconTheme: const IconThemeData(
        color: accentTeal,
        size: 24,
      ),
    );
  }
}