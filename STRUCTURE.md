# Trappex - Project Structure

This document outlines the organized file and folder structure for the Trappex Flutter project.

## 📁 Project Structure

```
lib/
├── constants/           # App-wide constants and configuration
│   ├── app_colors.dart     # Color definitions and theme colors
│   └── app_constants.dart  # App constants (names, sizes, etc.)
├── models/             # Data models and classes
│   └── game_edge.dart     # GameEdge model for board edges
├── services/           # Business logic and data services
│   └── game_service.dart  # Game logic and AI implementation
├── screens/            # Main screen widgets
│   ├── game_screen.dart   # Main game screen
│   └── home_screen.dart   # Welcome/home screen
├── widgets/            # Reusable UI components
│   ├── common/            # Common/shared widgets
│   │   ├── glassmorphic_container.dart
│   │   └── popup_overlay.dart
│   ├── game/              # Game-specific widgets
│   │   ├── game_board.dart
│   │   ├── game_painter.dart
│   │   ├── home_button.dart
│   │   ├── score_card.dart
│   │   └── turn_indicator.dart
│   └── home/              # Home screen widgets
│       ├── game_mode_chip.dart
│       └── grid_chip.dart
└── main.dart          # App entry point
```

## 🎯 Key Improvements

### 1. **Separation of Concerns**

- **Models**: Pure data classes (`GameEdge`)
- **Services**: Business logic (`GameService`)
- **Screens**: Main UI screens (`GameScreen`, `HomeScreen`)
- **Widgets**: Reusable UI components

### 2. **Constants Management**

- **AppColors**: Centralized color definitions
- **AppConstants**: App-wide constants (grid sizes, game modes, etc.)

### 3. **Modular Widgets**

- **Common Widgets**: Reusable components like `GlassmorphicContainer`
- **Game Widgets**: Game-specific UI components
- **Home Widgets**: Home screen specific components

### 4. **Service Layer**

- **GameService**: Handles all game logic, AI, and state management
- Clean separation between UI and business logic

## 🔧 Benefits

1. **Maintainability**: Each file has a single responsibility
2. **Reusability**: Widgets can be easily reused across screens
3. **Testability**: Services and models can be unit tested independently
4. **Scalability**: Easy to add new features without cluttering existing files
5. **Readability**: Code is organized logically and easy to navigate

## 📝 File Descriptions

### Constants

- `app_colors.dart`: All color definitions used throughout the app
- `app_constants.dart`: App name, game modes, grid sizes, and other constants

### Models

- `game_edge.dart`: Represents a game edge with type, row, and column

### Services

- `game_service.dart`: Complete game logic including AI, move validation, and scoring

### Screens

- `game_screen.dart`: Main game interface with board and controls
- `home_screen.dart`: Welcome screen with game setup options

### Widgets

- **Common**: Reusable UI components
- **Game**: Game-specific widgets (board, scores, etc.)
- **Home**: Home screen specific widgets (mode selection, etc.)

## 🚀 Usage

The app maintains the same functionality as before but with a much cleaner, more maintainable structure. All imports are properly organized and the code follows Flutter best practices.

## 🔄 Migration Notes

- Original `game_screen.dart` (1300+ lines) has been broken down into focused, manageable files
- All functionality preserved with improved organization
- Constants extracted to prevent magic numbers and strings
- Game logic separated from UI for better testability
