import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notification service
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static OneSignalService get instance => _instance;

  bool _isInitialized = false;
  bool _isEnabled = true;

  /// Check if OneSignal is initialized
  bool get isInitialized => _isInitialized;

  /// Check if notifications are enabled
  bool get isEnabled => _isEnabled;

  /// Initialize OneSignal with App ID
  Future<void> initialize({required String appId}) async {
    if (_isInitialized) {
      debugPrint('OneSignal already initialized');
      return;
    }

    try {
      // Set App ID (synchronous call)
      OneSignal.initialize(appId);

      // Set up notification handlers first
      _setupNotificationHandlers();

      // Request permission to show notifications (iOS/Android)
      // This is async and will prompt user on first call
      await OneSignal.Notifications.requestPermission(true);

      _isInitialized = true;
      debugPrint('OneSignal initialized successfully');
    } catch (e) {
      debugPrint('OneSignal initialization error: $e');
      // Don't throw - app should still work without push notifications
    }
  }

  /// Set up notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification received when app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('OneSignal notification received in foreground: ${event.notification.notificationId}');
      // You can customize notification display here
      // To show the notification, don't call event.notification.display()
      // To prevent showing, call event.preventDefault()
    });

    // Handle notification clicked/tapped
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('OneSignal notification clicked: ${event.notification.notificationId}');
      // Handle notification click action here
      // You can navigate to specific screens based on notification data
      final notification = event.notification;
      if (notification.additionalData != null) {
        debugPrint('Notification additional data: ${notification.additionalData}');
      }
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((hasPermission) {
      debugPrint('OneSignal permission changed: $hasPermission');
      _isEnabled = hasPermission;
    });
  }

  /// Enable or disable notifications
  Future<void> setEnabled(bool enabled) async {
    if (!_isInitialized) return;

    try {
      if (enabled) {
        await OneSignal.Notifications.requestPermission(true);
      } else {
        // Note: OneSignal doesn't have a direct disable method
        // You can set user subscription to false
        await OneSignal.User.pushSubscription.optOut();
      }
      _isEnabled = enabled;
    } catch (e) {
      debugPrint('OneSignal setEnabled error: $e');
    }
  }

  /// Get the current push subscription ID
  Future<String?> getPushSubscriptionId() async {
    if (!_isInitialized) return null;

    try {
      final subscription = OneSignal.User.pushSubscription;
      return subscription.id;
    } catch (e) {
      debugPrint('OneSignal getPushSubscriptionId error: $e');
      return null;
    }
  }

  /// Set user tag
  Future<void> setTag(String key, String value) async {
    if (!_isInitialized) return;

    try {
      await OneSignal.User.addTagWithKey(key, value);
    } catch (e) {
      debugPrint('OneSignal setTag error: $e');
    }
  }

  /// Set multiple user tags
  Future<void> setTags(Map<String, String> tags) async {
    if (!_isInitialized) return;

    try {
      await OneSignal.User.addTags(tags);
    } catch (e) {
      debugPrint('OneSignal setTags error: $e');
    }
  }

  /// Remove user tag
  Future<void> removeTag(String key) async {
    if (!_isInitialized) return;

    try {
      await OneSignal.User.removeTags([key]);
    } catch (e) {
      debugPrint('OneSignal removeTag error: $e');
    }
  }

  /// Set user email
  Future<void> setEmail(String email) async {
    if (!_isInitialized) return;

    try {
      await OneSignal.User.addEmail(email);
    } catch (e) {
      debugPrint('OneSignal setEmail error: $e');
    }
  }

  /// Set user ID (external user ID)
  Future<void> setExternalUserId(String userId) async {
    if (!_isInitialized) return;

    try {
      await OneSignal.login(userId);
    } catch (e) {
      debugPrint('OneSignal setExternalUserId error: $e');
    }
  }

  /// Logout user (clear external user ID)
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await OneSignal.logout();
    } catch (e) {
      debugPrint('OneSignal logout error: $e');
    }
  }

  /// Send a test notification (for testing purposes)
  /// Note: This requires OneSignal REST API access
  Future<void> sendTestNotification() async {
    // This would typically be done via OneSignal REST API
    // Not directly from the Flutter SDK
    debugPrint('Use OneSignal REST API to send test notifications');
  }
}

