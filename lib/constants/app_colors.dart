import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  static const Color bgColor = Color(0xFF000000);
  static const Color p1Color = Color(0xFF10B981); // Player
  static const Color p2Color = Color(0xFFF97316); // Computer
  static const Color mutedColor = Color(0xFF94A3B8);
  static const Color canvasBgColor = Color(0xFF07112A);
  static const Color canvasBorderColor = Color(0x4D22C55E); // rgba(34, 197, 94, 0.3)
  
  // Wall colors - more distinct and visible
  static const Color p1WallColor = Color(0xFF3B82F6); // Bright blue for player 1 walls
  static const Color p2WallColor = Color(0xFFEAB308); // Bright yellow for player 2 walls
  static const Color emptyWallColor = Color(0x4D22C55E); // Dim green for empty walls
  
  // Home screen colors - dark blue theme with neon accents
  static const Color homeBgDark = Color(0xFF041738); // Dark blue base
  static const Color homeBgMedium = Color(0xFF052045); // Medium dark blue
  static const Color homeBgLight = Color(0xFF062A5A); // Lighter dark blue
  static const Color homeAccent = Color(0xFF00EA98); // Bright green theme color
  static const Color homeAccentGlow = Color(0xFF00EA98); // Theme color for glows
  static const Color homeCardBg = Color(0xFF0A2E5C); // Card background
  static const Color homeCardBorder = Color(0xFF1A4A7F); // Card border
  
  // Private constructor to prevent instantiation
  AppColors._();
}
