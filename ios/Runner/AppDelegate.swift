import Flutter
import UIKit
import FBSDKCoreKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize Facebook SDK
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    
    // Set UNUserNotificationCenter delegate for OneSignal
    UNUserNotificationCenter.current().delegate = self
    
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Set up method channel after window is initialized
    DispatchQueue.main.async {
      if let controller = self.window?.rootViewController as? FlutterViewController {
        let appInfoChannel = FlutterMethodChannel(name: "app_info",
                                                  binaryMessenger: controller.binaryMessenger)
        
        appInfoChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if call.method == "getVersion" {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
              result(version)
            } else {
              result(FlutterError(code: "UNAVAILABLE", message: "Version not available", details: nil))
            }
          } else if call.method == "getPackageName" {
            if let bundleId = Bundle.main.bundleIdentifier {
              result(bundleId)
            } else {
              result(FlutterError(code: "UNAVAILABLE", message: "Package name not available", details: nil))
            }
          } else {
            result(FlutterMethodNotImplemented)
          }
        })
      }
    }
    
    return result
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle Facebook SDK URL schemes
    if ApplicationDelegate.shared.application(app, open: url, options: options) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
  
  // Handle notification received while app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Call super first to let Flutter/OneSignal plugin handle it
    super.userNotificationCenter(center, willPresent: notification) { options in
      // Show notification even when app is in foreground
      if #available(iOS 14.0, *) {
        completionHandler([.badge, .sound, .banner, .list])
      } else {
        completionHandler([.badge, .sound, .alert])
      }
    }
  }
  
  // Handle notification tapped/opened
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // Call super first to let Flutter/OneSignal plugin handle it
    super.userNotificationCenter(center, didReceive: response) {
      completionHandler()
    }
  }
}
