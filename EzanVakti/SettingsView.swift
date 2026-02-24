import SwiftUI
import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @Environment(\.dismiss) var dismiss
    
    // Build tarihi - App'in derleme tarihini gösterir
    var buildDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: viewModel.language == "tr" ? "tr_TR" : "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        // Önce executable dosyasının oluşturulma tarihini dene
        if let executableURL = Bundle.main.executableURL,
           let attributes = try? FileManager.default.attributesOfItem(atPath: executableURL.path),
           let modificationDate = attributes[.modificationDate] as? Date {
            return formatter.string(from: modificationDate)
        }
        
        // İkinci yöntem: Info.plist dosyasının tarihini dene
        if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let attributes = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let modificationDate = attributes[.modificationDate] as? Date {
            return formatter.string(from: modificationDate)
        }
        
        // Hiçbiri çalışmazsa bugünkü tarihi göster
        return formatter.string(from: Date())
    }
    
    // App versiyonu - Bundle'dan otomatik alınır
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.1"
        return version
    }
    
    var locationIcon: String {
        switch viewModel.locationAuthStatus {
        case "denied": return "location.slash.fill"
        case "authorized": return "location.fill"
        default: return "location"
        }
    }
    
    var locationColor: Color {
        switch viewModel.locationAuthStatus {
        case "denied": return .red
        case "authorized": return Color(red: 0.4, green: 0.8, blue: 0.6)
        default: return .orange
        }
    }
    
    var locationStatusText: String {
        switch viewModel.locationAuthStatus {
        case "denied":
            return viewModel.language == "tr" ? "Konum İzni Reddedildi" : "Location Access Denied"
        case "authorized":
            let status = viewModel.locationManager.authorizationStatus
            if status == .authorizedAlways {
                return viewModel.language == "tr" ? "Her Zaman İzinli" : "Always Allowed"
            } else {
                return viewModel.language == "tr" ? "Uygulama Kullanımda İzinli" : "While Using App"
            }
        default:
            return viewModel.language == "tr" ? "İzin Verilmedi" : "Not Authorized"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.06, green: 0.13, blue: 0.27).ignoresSafeArea()
                
                List {
                    // Language Section
                    Section {
                        HStack {
                            Label(
                                viewModel.language == "tr" ? "Dil" : "Language",
                                systemImage: "globe"
                            )
                            .foregroundColor(.white)
                            Spacer()
                            Picker("", selection: Binding(
                                get: { viewModel.language },
                                set: { viewModel.switchLanguage(to: $0) }
                            )) {
                                Text("Türkçe").tag("tr")
                                Text("English").tag("en")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }
                    } header: {
                        Text(viewModel.language == "tr" ? "Genel" : "General")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    
                    // Location Section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: locationIcon)
                                    .foregroundColor(locationColor)
                                    .frame(width: 24)
                                Text(locationStatusText)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            if viewModel.locationAuthStatus == "denied" {
                                Button {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text(viewModel.language == "tr" 
                                         ? "Ayarları Aç" 
                                         : "Open Settings")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 0.18, green: 0.52, blue: 0.34))
                                        .cornerRadius(8)
                                }
                            } else if viewModel.locationAuthStatus == "authorized" {
                                VStack(spacing: 6) {
                                    Button {
                                        viewModel.locationManager.requestAlwaysPermission()
                                    } label: {
                                        HStack {
                                            Image(systemName: "location.fill")
                                            Text(viewModel.language == "tr" 
                                                 ? "Her Zaman Konum İzni İste" 
                                                 : "Request Always Permission")
                                        }
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 0.18, green: 0.52, blue: 0.34))
                                        .cornerRadius(8)
                                    }
                                    
                                    Text(viewModel.language == "tr"
                                         ? "Arka planda da bildirimler için konum bazlı özellikler kullanılabilir."
                                         : "Enable background location for enhanced notification features.")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                    } header: {
                        Text(viewModel.language == "tr" ? "Konum İzinleri" : "Location Permissions")
                            .foregroundColor(.white.opacity(0.6))
                    } footer: {
                        Text(viewModel.language == "tr"
                             ? "Konum izni, bulunduğunuz yere göre otomatik olarak namaz vakitlerini göstermek için kullanılır."
                             : "Location permission is used to automatically show prayer times for your location.")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.caption)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    
                    // Notification Section
                    Section {
                        let prayers = viewModel.language == "tr"
                            ? ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"]
                            : ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
                        let keys = ["imsak", "gunes", "ogle", "ikindi", "aksam", "yatsi"]
                        let icons = ["moon.stars.fill", "sunrise.fill", "sun.max.fill", "cloud.sun.fill", "sunset.fill", "moon.fill"]
                        
                        ForEach(0..<prayers.count, id: \.self) { i in
                            HStack {
                                Image(systemName: icons[i])
                                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                                    .frame(width: 24)
                                Text(prayers[i])
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { viewModel.notificationManager.enabledPrayers.contains(keys[i]) },
                                    set: { _ in viewModel.notificationManager.togglePrayer(keys[i]) }
                                ))
                                .tint(Color(red: 0.18, green: 0.52, blue: 0.34))
                            }
                        }
                    } header: {
                        Text(viewModel.language == "tr" ? "Bildirimler" : "Notifications")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    .listRowSeparatorTint(Color.white.opacity(0.1))
                    
                    // About
                    Section {
                        HStack {
                            Label(
                                viewModel.language == "tr" ? "Veri Kaynağı" : "Data Source",
                                systemImage: "info.circle"
                            )
                            .foregroundColor(.white)
                            Spacer()
                            Text("Diyanet İşleri Başkanlığı")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Label("Version", systemImage: "app.badge")
                                .foregroundColor(.white)
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack {
                            Label(
                                viewModel.language == "tr" ? "Güncelleme Tarihi" : "Last Updated",
                                systemImage: "calendar.badge.clock"
                            )
                            .foregroundColor(.white)
                            Spacer()
                            Text(buildDate)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    } header: {
                        Text(viewModel.language == "tr" ? "Hakkında" : "About")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    .listRowSeparatorTint(Color.white.opacity(0.1))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(viewModel.language == "tr" ? "Ayarlar" : "Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.language == "tr" ? "Tamam" : "Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
