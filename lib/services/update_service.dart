import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Service to check for app updates from Play Store and App Store
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // Store URLs
  // Note: Update these URLs if your app's package name or App Store ID changes
  static const String _playStorePackageName = 'com.fgtp.trappex';
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=$_playStorePackageName';
  static const String _appStoreId = '6754655051';
  static const String _appStoreUrl = 'https://apps.apple.com/us/app/trappex/id$_appStoreId';
  
  // Method channel for getting app version
  static const MethodChannel _channel = MethodChannel('app_info');

  /// Get current app version using platform channels
  Future<String> getCurrentVersion() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final String version = await _channel.invokeMethod('getVersion');
        return version;
      }
      // Fallback: read from pubspec.yaml version
      return '1.0.2';
    } catch (e) {
      return '1.0.2'; // Fallback version
    }
  }

  /// Get package name / bundle ID
  Future<String> getPackageName() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final String packageName = await _channel.invokeMethod('getPackageName');
        return packageName;
      }
      return Platform.isAndroid ? _playStorePackageName : 'com.fgtp.trappex';
    } catch (e) {
      return Platform.isAndroid ? _playStorePackageName : 'com.fgtp.trappex';
    }
  }

  /// Check if update is available
  Future<bool> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      String? storeVersion;

      if (Platform.isAndroid) {
        storeVersion = await _getPlayStoreVersion();
      } else if (Platform.isIOS) {
        storeVersion = await _getAppStoreVersion();
      }

      if (storeVersion == null) {
        return false;
      }

      return _compareVersions(storeVersion, currentVersion) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Get Play Store version
  Future<String?> _getPlayStoreVersion() async {
    try {
      final response = await http.get(
        Uri.parse(_playStoreUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = response.body;
        
        // Try to find version in the HTML
        // Play Store shows version in various places, try multiple patterns
        final patterns = [
          RegExp(r'Current Version</div><span[^>]*>([^<]+)</span>', caseSensitive: false),
          RegExp(r'"version":"([^"]+)"', caseSensitive: false),
          RegExp(r'Version[^>]*>([^<]+)</', caseSensitive: false),
          RegExp(r'([0-9]+\.[0-9]+\.[0-9]+)', caseSensitive: false),
        ];

        for (final pattern in patterns) {
          final match = pattern.firstMatch(body);
          if (match != null && match.groupCount >= 1) {
            final version = match.group(1)?.trim();
            if (version != null && version.isNotEmpty) {
              return version;
            }
          }
        }
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }

  /// Get App Store version using iTunes API
  Future<String?> _getAppStoreVersion() async {
    try {
      // Use iTunes API to get app info
      final itunesUrl = 'https://itunes.apple.com/lookup?id=$_appStoreId';
      final response = await http.get(
        Uri.parse(itunesUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['results'] != null && jsonData['results'].isNotEmpty) {
          final version = jsonData['results'][0]['version'] as String?;
          return version;
        }
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }

  /// Compare two version strings
  /// Returns: 1 if version1 > version2, -1 if version1 < version2, 0 if equal
  int _compareVersions(String version1, String version2) {
    try {
      final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      // Pad with zeros to make same length
      while (v1Parts.length < v2Parts.length) v1Parts.add(0);
      while (v2Parts.length < v1Parts.length) v2Parts.add(0);

      for (int i = 0; i < v1Parts.length; i++) {
        if (v1Parts[i] > v2Parts[i]) return 1;
        if (v1Parts[i] < v2Parts[i]) return -1;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get store URL for current platform
  String getStoreUrl() {
    if (Platform.isAndroid) {
      return _playStoreUrl;
    } else if (Platform.isIOS) {
      return _appStoreUrl;
    }
    return '';
  }
}

