import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics service to track app activity and user events
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();

  static FirebaseAnalyticsService get instance => _instance;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isEnabled = true;

  /// Get the FirebaseAnalytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Check if analytics is enabled
  bool get isEnabled => _isEnabled;

  /// Enable or disable analytics tracking
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Silently handle analytics errors - don't crash the app
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      // Silently handle analytics errors
    }
  }

  /// Log app open event
  Future<void> logAppOpen() async {
    if (!_isEnabled) return;

    try {
      await _analytics.logAppOpen();
    } catch (e) {
      // Silently handle analytics errors
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      // Silently handle analytics errors
    }
  }

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      // Silently handle analytics errors
    }
  }

  // Game-specific tracking methods

  /// Log game start event
  Future<void> logGameStart({
    required String gameMode,
    int? difficulty,
  }) async {
    await logEvent(
      name: 'game_start',
      parameters: {
        'game_mode': gameMode,
        if (difficulty != null) 'difficulty': difficulty,
      },
    );
  }

  /// Log game end event
  Future<void> logGameEnd({
    required String gameMode,
    required String result,
    int? score,
    int? moves,
    int? duration,
  }) async {
    await logEvent(
      name: 'game_end',
      parameters: {
        'game_mode': gameMode,
        'result': result,
        if (score != null) 'score': score,
        if (moves != null) 'moves': moves,
        if (duration != null) 'duration_seconds': duration,
      },
    );
  }

  /// Log move made event
  Future<void> logMoveMade({
    required String gameMode,
    int? moveNumber,
  }) async {
    await logEvent(
      name: 'move_made',
      parameters: {
        'game_mode': gameMode,
        if (moveNumber != null) 'move_number': moveNumber,
      },
    );
  }

  /// Log screen navigation
  Future<void> logScreenNavigation({
    required String fromScreen,
    required String toScreen,
  }) async {
    await logEvent(
      name: 'screen_navigation',
      parameters: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
      },
    );
  }

  /// Log button click
  Future<void> logButtonClick({
    required String buttonName,
    String? screenName,
  }) async {
    await logEvent(
      name: 'button_click',
      parameters: {
        'button_name': buttonName,
        if (screenName != null) 'screen_name': screenName,
      },
    );
  }

  /// Log ad event
  Future<void> logAdEvent({
    required String adType,
    required String eventType,
    String? adUnitId,
  }) async {
    await logEvent(
      name: 'ad_event',
      parameters: {
        'ad_type': adType,
        'event_type': eventType,
        if (adUnitId != null) 'ad_unit_id': adUnitId,
      },
    );
  }
}

