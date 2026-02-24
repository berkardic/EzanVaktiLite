import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @State private var showPicker = false
    @State private var showSettings = false
    @State private var showQiblaCompass = false

    var body: some View {
        ZStack {
            IslamicBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        HeaderView(showSettings: $showSettings, showQiblaCompass: $showQiblaCompass)

                        // Konum / İl-İlçe satırı
                        LocationRow(showPicker: $showPicker)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        // Seçim yapılmamışsa yönlendirme
                        if viewModel.selectedDistrict == nil && !viewModel.isLoading {
                            SelectionPrompt(showPicker: $showPicker)
                                .padding(.horizontal)
                                .padding(.top, 20)
                        }

                        // Sıradaki namaz banner
                        if let next = viewModel.nextPrayer(),
                           let cd = viewModel.timeUntilNextPrayer() {
                            NextPrayerBanner(name: next.name, time: next.time, icon: next.icon, countdown: cd)
                                .padding(.horizontal)
                                .padding(.top, 16)
                        }

                        // Vakit listesi
                        PrayerTimesGrid()
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 24)

                        // ⚙️ KONUM DEBUG PANELİ - Geliştirme aşamasında kullanılır
                        // LocationDebugPanel()
                        //     .padding(.horizontal)
                        //     .padding(.top, 12)
                    }
                }
                .refreshable { await viewModel.loadPrayerTimes() }
                
                // AdMob Banner - En altta
                BannerAdContainer()
            }
            .onAppear {
                // UIKit RefreshControl rengini parlak sarı yap
                UIRefreshControl.appearance().tintColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
            }

            if viewModel.isLoading { LoadingOverlay() }
        }
        .sheet(isPresented: $showPicker) {
            CityDistrictPickerView().environmentObject(viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $showQiblaCompass) {
            QiblaCompassView().environmentObject(viewModel)
        }
        .task {
            _ = await viewModel.notificationManager.requestPermission()
            AdMobManager.shared.initialize()
            await AdMobManager.shared.requestTrackingPermission()
        }
    }
}

// MARK: - Seçim yapılmamış yönlendirme
struct SelectionPrompt: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @Binding var showPicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 44))
                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.8))

            Text(viewModel.language == "tr"
                 ? "Ezan vakitlerini görmek için\nil ve ilçenizi seçin"
                 : "Select your province and district\nto see prayer times")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Button {
                showPicker = true
            } label: {
                Text(viewModel.language == "tr" ? "İl / İlçe Seç" : "Select Location")
                    .font(.body.bold())
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.18, green: 0.52, blue: 0.34))
                    .cornerRadius(14)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}

// MARK: - Konum Satırı
struct LocationRow: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @Binding var showPicker: Bool
    @State private var showDeniedAlert = false

    var locationBg: Color {
        if viewModel.locationAuthStatus == "denied" { return Color.red.opacity(0.7) }
        if viewModel.locationAuthStatus == "authorized" && !viewModel.isResolvingLocation {
            return Color(red: 0.18, green: 0.52, blue: 0.34)
        }
        return Color.white.opacity(0.15)
    }

    var locationIcon: String {
        if viewModel.locationAuthStatus == "denied" { return "location.slash" }
        if viewModel.locationAuthStatus == "authorized" { return "location.fill" }
        return "location"
    }

    var body: some View {
        HStack {
            // Konum butonu
            Button {
                if viewModel.locationAuthStatus == "denied" {
                    showDeniedAlert = true
                } else {
                    viewModel.enableLocationMode()
                }
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isResolvingLocation {
                        ProgressView().tint(.white).scaleEffect(0.7)
                    } else {
                        Image(systemName: locationIcon).font(.caption)
                    }
                    Text(viewModel.language == "tr" ? "Konum" : "Location")
                        .font(.caption.bold())
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(locationBg)
                .cornerRadius(20)
                .foregroundColor(.white)
            }
            .alert(
                viewModel.language == "tr" ? "Konum İzni Gerekli" : "Location Permission Required",
                isPresented: $showDeniedAlert
            ) {
                Button(viewModel.language == "tr" ? "Ayarları Aç" : "Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(viewModel.language == "tr" ? "İptal" : "Cancel", role: .cancel) {}
            } message: {
                Text(viewModel.language == "tr"
                     ? "Konum iznini Ayarlar > Gizlilik > Konum Servisleri > EzanVakti bölümünden açın."
                     : "Enable location in Settings > Privacy > Location Services > EzanVakti.")
            }

            Spacer()

            // İl / İlçe seçici butonu
            Button { showPicker = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                    Text(viewModel.locationLabel)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
            }
        }
    }
}

// MARK: - Header (aynı)
struct HeaderView: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @Binding var showSettings: Bool
    @Binding var showQiblaCompass: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.language == "tr" ? "Ezan Vakitleri" : "Prayer Times")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(formattedDate())
                    .font(.subheadline).foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            
            // Pusula butonu
            ZStack {
                Circle().fill(Color.white.opacity(0.1)).frame(width: 48, height: 48)
                Image(systemName: "location.north.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.6))
            }
            .onTapGesture { showQiblaCompass = true }
            
            // Ayarlar butonu
            ZStack {
                Circle().fill(Color.white.opacity(0.1)).frame(width: 48, height: 48)
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
            }
            .onTapGesture { showSettings = true }
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    func formattedDate() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: viewModel.language == "tr" ? "tr_TR" : "en_US")
        f.dateFormat = viewModel.language == "tr" ? "d MMMM yyyy, EEEE" : "EEEE, MMMM d"
        return f.string(from: Date())
    }
}

// MARK: - Next Prayer Banner (aynı)
struct NextPrayerBanner: View {
    let name: String; let time: String; let icon: String; let countdown: String
    @EnvironmentObject var viewModel: PrayerTimeViewModel

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: icon).font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.language == "tr" ? "Sıradaki Namaz" : "Next Prayer")
                    .font(.caption).foregroundColor(.white.opacity(0.7))
                Text(name).font(.title3.bold()).foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(time).font(.title2.bold())
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                Text(countdown).font(.caption).foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.4), lineWidth: 1))
        )
    }
}

// MARK: - Prayer Times Grid
struct PrayerTimesGrid: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel

    var body: some View {
        VStack(spacing: 0) {
            if let prayers = viewModel.todayPrayers {
                let entries = prayers.allTimes
                ForEach(0..<entries.count, id: \.self) { i in
                    PrayerRow(
                        name: viewModel.language == "tr" ? entries[i].name : entries[i].nameEn,
                        time: entries[i].time,
                        icon: entries[i].icon,
                        isNext: prayers.nextPrayer()?.time == entries[i].time,
                        isLast: i == entries.count - 1
                    )
                }
            } else if !viewModel.isLoading && viewModel.selectedDistrict != nil {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash").font(.largeTitle).foregroundColor(.white.opacity(0.5))
                    Text(viewModel.errorMessage ?? (viewModel.language == "tr" ? "Vakitler yüklenemedi" : "Could not load times"))
                        .foregroundColor(.white.opacity(0.7)).multilineTextAlignment(.center)
                    Button {
                        Task { await viewModel.loadPrayerTimes() }
                    } label: {
                        Text(viewModel.language == "tr" ? "Tekrar Dene" : "Retry")
                            .padding(.horizontal, 24).padding(.vertical, 10)
                            .background(Color(red: 0.18, green: 0.52, blue: 0.34))
                            .cornerRadius(12).foregroundColor(.white)
                    }
                }
                .padding(32).frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.08)).cornerRadius(16)
            }
        }
        .background(viewModel.todayPrayers != nil ? Color.white.opacity(0.08) : Color.clear)
        .cornerRadius(16)
    }
}

struct PrayerRow: View {
    let name: String; let time: String; let icon: String
    let isNext: Bool; let isLast: Bool
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @ObservedObject private var notificationManager = NotificationManager.shared

    var prayerKey: String {
        ["İmsak":"imsak","Güneş":"gunes","Öğle":"ogle","İkindi":"ikindi","Akşam":"aksam","Yatsı":"yatsi",
         "Fajr":"imsak","Sunrise":"gunes","Dhuhr":"ogle","Asr":"ikindi","Maghrib":"aksam","Isha":"yatsi"][name] ?? name.lowercased()
    }
    var isEnabled: Bool { notificationManager.enabledPrayers.contains(prayerKey) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isNext ? Color(red:1.0,green:0.85,blue:0.4).opacity(0.2) : Color.white.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16))
                    .foregroundColor(isNext ? Color(red:1.0,green:0.85,blue:0.4) : Color.white.opacity(0.7))
            }
            Text(name).font(.body.weight(isNext ? .bold : .regular))
                .foregroundColor(isNext ? .white : .white.opacity(0.85))
            Spacer()
            Button { 
                withAnimation(.easeInOut(duration: 0.2)) {
                    notificationManager.togglePrayer(prayerKey)
                }
            } label: {
                Image(systemName: isEnabled ? "bell.fill" : "bell.slash").font(.caption)
                    .foregroundColor(isEnabled ? Color(red:0.4,green:0.8,blue:0.6) : Color.white.opacity(0.3))
            }.padding(.trailing, 4)
            Text(time)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(isNext ? Color(red:1.0,green:0.85,blue:0.4) : .white)
                .frame(width: 58, alignment: .trailing)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(isNext ? Color(red:1.0,green:0.85,blue:0.4).opacity(0.08) : Color.clear)
        .overlay(alignment: .bottom) {
            if !isLast { Divider().background(Color.white.opacity(0.1)).padding(.leading, 70) }
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView().tint(.white).scaleEffect(1.3)
                Text(viewModel.language == "tr" ? "Vakitler yükleniyor..." : "Loading...")
                    .foregroundColor(.white).font(.subheadline)
            }
            .padding(28)
            .background(Color(red:0.08,green:0.15,blue:0.30))
            .cornerRadius(16)
        }
    }
}

// MARK: - Islamic Background (aynı)
struct IslamicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red:0.05,green:0.12,blue:0.25),
                    Color(red:0.08,green:0.18,blue:0.38),
                    Color(red:0.12,green:0.22,blue:0.30)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()
            GeometricPattern().opacity(0.07).ignoresSafeArea()
            StarsView()
        }
    }
}

struct GeometricPattern: View {
    var body: some View {
        Canvas { ctx, size in
            let sp: CGFloat = 60
            for row in 0...Int(size.height/sp)+2 {
                for col in 0...Int(size.width/sp)+2 {
                    let x = CGFloat(col)*sp + (row.isMultiple(of:2) ? 0 : sp/2)
                    let y = CGFloat(row)*sp*0.866
                    let c = CGPoint(x:x,y:y); let s: CGFloat = 18
                    var p = Path()
                    p.move(to: CGPoint(x:c.x,y:c.y-s))
                    p.addLine(to: CGPoint(x:c.x+s*0.7,y:c.y-s*0.3))
                    p.addLine(to: CGPoint(x:c.x+s*0.7,y:c.y+s*0.3))
                    p.addLine(to: CGPoint(x:c.x,y:c.y+s))
                    p.addLine(to: CGPoint(x:c.x-s*0.7,y:c.y+s*0.3))
                    p.addLine(to: CGPoint(x:c.x-s*0.7,y:c.y-s*0.3))
                    p.closeSubpath()
                    ctx.stroke(p, with: .color(.white), lineWidth: 0.5)
                }
            }
        }
    }
}

struct StarsView: View {
    let stars: [(CGFloat,CGFloat,CGFloat)] = (0..<40).map { _ in
        (CGFloat.random(in:0...1), CGFloat.random(in:0...0.4), CGFloat.random(in:1...3))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id:\.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in:0.3...0.8)))
                    .frame(width:stars[i].2,height:stars[i].2)
                    .position(x:stars[i].0*geo.size.width,y:stars[i].1*geo.size.height)
            }
        }.ignoresSafeArea()
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🐛 DEBUG: Konum Debug Paneli
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bu panel geliştirme aşamasında konum bilgilerini test etmek için kullanılır.
// Aktif hale getirmek için yukarıdaki LocationDebugPanel() satırını uncomment edin.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: - Debug Konum Paneli
struct LocationDebugPanel: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    @State private var isExpanded = false

    var debug: LocationDebugInfo { viewModel.locationManager.debugInfo }

    var body: some View {
        VStack(spacing: 0) {
            // Başlık — tıklayınca aç/kapat
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: "ant.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                    Text("Konum Debug")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.4))
                .cornerRadius(isExpanded ? 12 : 12)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    if let err = debug.error {
                        debugRow("❌ Hata", err, color: .red)
                    }
                    debugRow("📍 Koordinat", "\(debug.latitude), \(debug.longitude)")
                    Divider().background(Color.white.opacity(0.1))
                    debugRow("name", debug.name)
                    debugRow("locality", debug.locality, note: "→ Şehir/İlçe")
                    debugRow("subLocality", debug.subLocality, note: "→ Mahalle")
                    debugRow("administrativeArea", debug.administrativeArea, note: "→ İL ✅")
                    debugRow("subAdministrativeArea", debug.subAdministrativeArea, note: "→ İLÇE?")
                    debugRow("thoroughfare", debug.thoroughfare, note: "→ Cadde")
                    debugRow("postalCode", debug.postalCode)
                    debugRow("country", debug.country)
                    Divider().background(Color.white.opacity(0.1))
                    // Geo JSON eşleşme sonucu
                    debugRow("🗺 Geo eşleşme",
                             viewModel.locationLabel == "Konum seç" ? "Eşleşme yok" : viewModel.locationLabel,
                             color: viewModel.locationLabel == "Konum seç" ? .orange : .green)
                    // Buton
                    Button {
                        viewModel.enableLocationMode()
                    } label: {
                        Text("🔄 Konumu Yenile")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.18, green: 0.52, blue: 0.34))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 4)
                }
                .padding(12)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
            }
        }
    }

    func debugRow(_ key: String, _ value: String, note: String = "", color: Color = .white) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(key)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 130, alignment: .leading)
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            if !note.isEmpty {
                Text(note)
                    .font(.system(size: 9))
                    .foregroundColor(.yellow.opacity(0.7))
            }
        }
    }
}
