/// App-wide constants
class AppConstants {
  static const String appName = 'Trappex';
  static const String appDescription = 'The Ultimate Dots & Boxes Game';
  
  // Game modes
  static const String vsComputerMode = 'vsComputer';
  static const String oneVsOneMode = '1v1';
  
  // Grid sizes
  static const int easyGridSize = 4;
  static const int classicGridSize = 5;
  static const int hardGridSize = 6;
  
  // External links
  static const String webGamesUrl = 'https://freegametoplay.com';

  // UI constants
  static const double edgeThickness = 8.0;
  static const double touchTolerance = 15.0;
  static const double cellPadding = 20.0;
  
  // Private constructor to prevent instantiation
  AppConstants._();
}
