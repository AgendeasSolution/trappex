import 'package:flutter/material.dart';

/// Utility class for responsive design across different screen sizes
/// 
/// Provides helper methods to calculate responsive values based on screen width
/// Breakpoints:
/// - Small: width < 360px (e.g., small phones)
/// - Medium: 360px <= width < 480px (e.g., regular phones)
/// - Large: width >= 480px (e.g., large phones, tablets)
class ResponsiveUtils {
  // Breakpoint constants
  static const double _smallBreakpoint = 360.0;
  static const double _mediumBreakpoint = 480.0;

  /// Gets responsive value based on screen width
  /// 
  /// Returns different values for small, medium, and large screens
  /// 
  /// [context] - BuildContext to access MediaQuery
  /// [small] - Value for small screens (< 360px)
  /// [medium] - Value for medium screens (360px - 479px)
  /// [large] - Value for large screens (>= 480px)
  static double getResponsiveValue(
    BuildContext context,
    double small,
    double medium,
    double large,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < _smallBreakpoint) return small;
    if (width < _mediumBreakpoint) return medium;
    return large;
  }

  /// Gets responsive padding value
  /// 
  /// Returns 16.0 for small, 20.0 for medium, 24.0 for large screens
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _smallBreakpoint) return 16.0;
    if (width < _mediumBreakpoint) return 20.0;
    return 24.0;
  }

  /// Gets responsive font size
  /// 
  /// Returns different font sizes based on screen width
  /// 
  /// [context] - BuildContext to access MediaQuery
  /// [small] - Font size for small screens
  /// [medium] - Font size for medium screens
  /// [large] - Font size for large screens
  static double getResponsiveFontSize(
    BuildContext context,
    double small,
    double medium,
    double large,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < _smallBreakpoint) return small;
    if (width < _mediumBreakpoint) return medium;
    return large;
  }

  /// Gets responsive logo font size
  /// 
  /// Calculates font size based on screen width to ensure logo stays on one line
  /// Uses 12% of screen width, clamped between 32 and 52
  static double getResponsiveLogoFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Ensure logo fits on one line by calculating based on screen width
    // Uses a formula that scales with width
    final baseSize = width * 0.12; // 12% of screen width
    // Clamp between min and max values
    if (baseSize < 32) return 32;
    if (baseSize > 52) return 52;
    return baseSize;
  }

  /// Gets responsive spacing value
  /// 
  /// Returns different spacing values based on screen width
  /// 
  /// [context] - BuildContext to access MediaQuery
  /// [small] - Spacing for small screens
  /// [medium] - Spacing for medium screens
  /// [large] - Spacing for large screens
  static double getResponsiveSpacing(
    BuildContext context,
    double small,
    double medium,
    double large,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < _smallBreakpoint) return small;
    if (width < _mediumBreakpoint) return medium;
    return large;
  }

  /// Gets screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Checks if screen is small (< 360px)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _smallBreakpoint;
  }

  /// Checks if screen is medium (360px - 479px)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _smallBreakpoint && width < _mediumBreakpoint;
  }

  /// Checks if screen is large (>= 480px)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _mediumBreakpoint;
  }
}

