import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var enabledPrayers: Set<String> = ["imsak", "gunes", "ogle", "ikindi", "aksam", "yatsi"]
    
    private let enabledKey = "enabledPrayers"
    
    init() {
        loadEnabledPrayers()
        checkStatus()
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { self.isAuthorized = granted }
            return granted
        } catch {
            return false
        }
    }
    
    func checkStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func schedulePrayerNotifications(prayers: TodayPrayers, language: String = "tr") {
        // Önce eski bildirimleri temizle
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let prayerKeys = ["imsak", "gunes", "ogle", "ikindi", "aksam", "yatsi"]
        let prayerTimes = [prayers.imsak, prayers.gunes, prayers.ogle, prayers.ikindi, prayers.aksam, prayers.yatsi]
        let prayerNamesTR = ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"]
        let prayerNamesEN = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
        let icons = ["🌙", "🌅", "☀️", "⛅", "🌇", "🌃"]
        
        for (index, key) in prayerKeys.enumerated() {
            guard enabledPrayers.contains(key) else { continue }
            
            let timeStr = prayerTimes[index]
            let components = timeStr.split(separator: ":").compactMap { Int($0) }
            guard components.count >= 2 else { continue }
            
            var dateComponents = DateComponents()
            dateComponents.hour = components[0]
            dateComponents.minute = components[1]
            
            let content = UNMutableNotificationContent()
            let prayerName = language == "tr" ? prayerNamesTR[index] : prayerNamesEN[index]
            content.title = "\(icons[index]) \(prayerName) Vakti"
            content.body = language == "tr"
                ? "\(prayers.cityName) için \(prayerName.lowercased()) vakti girdi. (\(timeStr))"
                : "\(prayerName) time has come for \(prayers.cityName). (\(timeStr))"
            content.sound = .default
            content.badge = 1
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "prayer_\(key)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func togglePrayer(_ key: String) {
        if enabledPrayers.contains(key) {
            enabledPrayers.remove(key)
        } else {
            enabledPrayers.insert(key)
        }
        saveEnabledPrayers()
        // UI'ı anında güncelle
        objectWillChange.send()
    }
    
    private func saveEnabledPrayers() {
        UserDefaults.standard.set(Array(enabledPrayers), forKey: enabledKey)
    }
    
    private func loadEnabledPrayers() {
        if let saved = UserDefaults.standard.array(forKey: enabledKey) as? [String] {
            enabledPrayers = Set(saved)
        }
    }
}
