import SwiftUI

@main
struct EzanVaktiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PrayerTimeViewModel())
        }
    }
}
