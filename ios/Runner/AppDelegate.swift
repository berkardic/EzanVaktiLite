import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    // Enable Firebase Analytics DebugView for debug builds.
    // Must be set before FirebaseApp.configure() so the SDK picks it up immediately.
    UserDefaults.standard.set(true, forKey: "/google/measurement/debug_mode")
    #else
    UserDefaults.standard.removeObject(forKey: "/google/measurement/debug_mode")
    #endif

    // Configure Firebase natively before Flutter initializes so the debug key
    // is already in place when firebase_core's initializeApp() runs in Dart.
    FirebaseApp.configure()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
