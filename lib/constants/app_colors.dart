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
  
  // Private constructor to prevent instantiation
  AppColors._();
}
