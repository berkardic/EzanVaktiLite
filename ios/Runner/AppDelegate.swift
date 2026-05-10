import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    // Enable Firebase Analytics DebugView for debug builds.
    // Must be set before Firebase initializes (which happens in Dart's main()).
    UserDefaults.standard.set(true, forKey: "/google/measurement/debug_mode")
    #else
    UserDefaults.standard.removeObject(forKey: "/google/measurement/debug_mode")
    #endif

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
