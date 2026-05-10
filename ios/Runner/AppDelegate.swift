import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    // Firebase Analytics DebugView — binary analizinden bulunan gerçek key.
    // "-FIRAnalyticsDebugEnabled" launch argümanı bu key'i true olarak set eder.
    // flutter run Xcode scheme argümanlarını kullanmadığı için buradan set ediyoruz.
    UserDefaults.standard.set(true, forKey: "/google/measurement/debug_mode")
    #endif
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
