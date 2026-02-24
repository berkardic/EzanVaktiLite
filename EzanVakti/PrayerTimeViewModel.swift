import Foundation
import Combine
import CoreLocation

class PrayerTimeViewModel: ObservableObject {

    // MARK: - Published
    @Published var todayPrayers: TodayPrayers?
    @Published var isLoading = false
    @Published var isLoadingCities = false
    @Published var isLoadingDistricts = false
    @Published var errorMessage: String?
    @Published var currentTime = Date()
    @Published var language: String = "tr"
    @Published var useLocation = false
    @Published var isResolvingLocation = false

    @Published var cities: [DiyanetCity] = []
    @Published var districts: [DiyanetDistrict] = []
    @Published var selectedCity: DiyanetCity? = nil
    @Published var selectedDistrict: DiyanetDistrict? = nil
    @Published var locationAuthStatus: String = "unknown"

    let locationManager = LocationManager()
    let notificationManager = NotificationManager.shared

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    private let langKey   = "appLanguage"
    private let cityIdKey = "selectedCityId"
    private let distIdKey = "selectedDistrictId"
    private let useLocKey = "useLocation"

    // MARK: - Init
    init() {
        loadPreferences()
        startTimer()

        // İzin durumunu takip et.
        // İzin yeni verilirse ve konum bekleniyorsa (isResolvingLocation) otomatik devam et.
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationAuthStatus = "authorized"
                    // İzin az önce verildi ve kullanıcı "Konum" butonuna basmıştı
                    if self.isResolvingLocation {
                        self.startLocationRequest()
                    }
                case .denied, .restricted:
                    self.locationAuthStatus = "denied"
                    self.isResolvingLocation = false
                default:
                    self.locationAuthStatus = "unknown"
                }
            }
            .store(in: &cancellables)

        // NOT: locationManager.$location Combine sink'i KASITLI OLARAK kaldırıldı.
        // Konum artık completion handler aracılığıyla alınıyor (daha güvenilir).

        Task { await loadCitiesAndRestore() }
    }

    deinit { timer?.invalidate() }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }

    // MARK: - Şehirleri yükle + kayıtlı tercihi geri yükle
    @MainActor
    func loadCitiesAndRestore() async {
        isLoadingCities = true
        errorMessage = nil
        do {
            let list = try await DiyanetService.shared.fetchCities()
            self.cities = list
            isLoadingCities = false

            let savedCityId = UserDefaults.standard.integer(forKey: cityIdKey)
            let savedDistId = UserDefaults.standard.integer(forKey: distIdKey)

            if savedCityId > 0, let city = list.first(where: { $0.id == savedCityId }) {
                self.selectedCity = city
                isLoadingDistricts = true
                let distList = try await DiyanetService.shared.fetchDistricts(cityId: city.id)
                self.districts = distList
                isLoadingDistricts = false

                if savedDistId > 0, let dist = distList.first(where: { $0.id == savedDistId }) {
                    self.selectedDistrict = dist
                    await loadPrayerTimes()
                }
            }
        } catch {
            isLoadingCities = false
            errorMessage = "Şehirler yüklenemedi. İnternet bağlantınızı kontrol edin."
        }
    }

    // MARK: - İlçeleri yükle
    @MainActor
    func loadDistricts(for city: DiyanetCity) async {
        isLoadingDistricts = true
        districts = []
        selectedDistrict = nil
        do {
            let list = try await DiyanetService.shared.fetchDistricts(cityId: city.id)
            self.districts = list
            isLoadingDistricts = false
        } catch {
            isLoadingDistricts = false
            errorMessage = "İlçeler yüklenemedi."
        }
    }

    // MARK: - Vakitleri yükle
    @MainActor
    func loadPrayerTimes() async {
        guard let district = selectedDistrict, let city = selectedCity else { return }
        isLoading = true
        errorMessage = nil
        do {
            let cityName = language == "tr" ? city.sehirAdi : city.sehirAdiEn
            let distName = language == "tr" ? district.ilceAdi : district.ilceAdiEn
            let prayers = try await DiyanetService.shared.fetchPrayerTimes(
                districtId: district.id,
                cityName: cityName,
                districtName: distName
            )
            todayPrayers = prayers
            isLoading = false
            notificationManager.schedulePrayerNotifications(prayers: prayers, language: language)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    // MARK: - Şehir seç
    @MainActor
    func selectCity(_ city: DiyanetCity) async {
        selectedCity = city
        selectedDistrict = nil
        todayPrayers = nil
        UserDefaults.standard.set(city.id, forKey: cityIdKey)
        UserDefaults.standard.removeObject(forKey: distIdKey)
        await loadDistricts(for: city)
    }

    // MARK: - İlçe seç
    @MainActor
    func selectDistrict(_ district: DiyanetDistrict) async {
        selectedDistrict = district
        UserDefaults.standard.set(district.id, forKey: distIdKey)
        await loadPrayerTimes()
    }

    // MARK: - Konum butonu
    @MainActor
    func enableLocationMode() {
        print("📍 ViewModel: enableLocationMode called")
        guard !isResolvingLocation else { 
            print("📍 ViewModel: Already resolving location, skipping")
            return 
        }

        useLocation = true
        isResolvingLocation = true
        UserDefaults.standard.set(true, forKey: useLocKey)

        let status = locationManager.authorizationStatus
        print("📍 ViewModel: Current authorization status: \(status.rawValue)")

        switch status {
        case .notDetermined:
            print("📍 ViewModel: Authorization not determined, requesting permission...")
            // İzin iste; verilince $authorizationStatus sink startLocationRequest()'i çağıracak
            locationManager.requestPermission()

        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 ViewModel: Already authorized, starting location request...")
            locationAuthStatus = "authorized"
            startLocationRequest()

        case .denied, .restricted:
            print("📍 ViewModel: Location access denied or restricted")
            locationAuthStatus = "denied"
            isResolvingLocation = false

        @unknown default:
            print("📍 ViewModel: Unknown authorization status, requesting permission...")
            locationManager.requestPermission()
        }
    }

    /// Completion handler tabanlı, güvenilir tek seferlik konum isteği.
    /// enableLocationMode() ve $authorizationStatus sink tarafından çağrılır.
    @MainActor
    private func startLocationRequest() {
        print("📍 ViewModel: startLocationRequest called")
        
        locationManager.requestCurrentLocation { [weak self] result in
            guard let self else { return }
            print("📍 ViewModel: Location request completed")
            
            // Completion handler zaten main thread'de geliyor (LocationManager.swift'te .main dispatch yapıldı)
            Task { @MainActor in
                switch result {
                case .success(let loc):
                    print("📍 ViewModel: Location success: \(loc.coordinate)")
                    await self.resolveLocation(
                        lat: loc.coordinate.latitude,
                        lon: loc.coordinate.longitude,
                        rawLocation: loc
                    )
                case .failure(let error):
                    print("📍 ViewModel: Location failure: \(error.localizedDescription)")
                    self.isResolvingLocation = false
                    let isUnknown = (error as? CLError)?.code == .locationUnknown
                    self.errorMessage = self.language == "tr"
                        ? (isUnknown
                            ? "Konum alınamadı. Açık alanda tekrar deneyin."
                            : "Konum hatası. Tekrar deneyin.")
                        : (isUnknown
                            ? "Location unavailable. Try in an open area."
                            : "Location error. Try again.")
                }
            }
        }
    }

    // MARK: - Konumu çöz
    @MainActor
    private func resolveLocation(lat: Double, lon: Double, rawLocation: CLLocation) async {
        defer { isResolvingLocation = false }

        // Şehirler yüklü değilse yükle
        if cities.isEmpty {
            if let list = try? await DiyanetService.shared.fetchCities() {
                self.cities = list
            }
        }
        guard !cities.isEmpty else {
            errorMessage = language == "tr" ? "Şehirler yüklenemedi." : "Cities unavailable."
            return
        }

        // ── Adım 1: CLGeocoder ile reverse geocoding ──────────────────────────
        var province = ""
        var district = ""

        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(rawLocation)
            if let p = placemarks.first {
                province = p.administrativeArea ?? ""   // "İstanbul", "Ankara" ...
                district = p.subAdministrativeArea      // "Kadıköy", "Çankaya" ...
                         ?? p.locality                  // bazı cihazlarda burada gelir
                         ?? ""

                // Debug panelini güncelle (main thread'deyiz)
                locationManager.applyPlacemark(p, location: rawLocation)
            }
        } catch {
            // Geocoding başarısız olabilir, koordinat fallback'e düşeceğiz
        }

        // ── Adım 2: Geocoding il adı vermezse koordinat tabanlı fallback ──────
        if province.isEmpty {
            province = DiyanetService.shared.findNearestProvince(lat: lat, lon: lon)
        }

        guard !province.isEmpty else { return }

        // ── Adım 3: İli Diyanet şehir listesiyle eşleştir ────────────────────
        let normProv = normalize(province)

        guard let city = cities.first(where: {
            let n = normalize($0.sehirAdi)
            return n == normProv
                || n.contains(normProv) || normProv.contains(n)
                || (normProv.count >= 4 && n.hasPrefix(String(normProv.prefix(4))))
                || (n.count >= 4 && normProv.hasPrefix(String(n.prefix(4))))
        }) else { return }

        // Şehir değiştiyse ilçeleri yeniden yükle
        if selectedCity?.id != city.id {
            selectedCity = city
            UserDefaults.standard.set(city.id, forKey: cityIdKey)
            isLoadingDistricts = true
            districts = []
            if let distList = try? await DiyanetService.shared.fetchDistricts(cityId: city.id) {
                districts = distList
            }
            isLoadingDistricts = false
        }

        guard !districts.isEmpty else { return }

        // ── Adım 4: İlçeyi eşleştir ──────────────────────────────────────────
        if !district.isEmpty {
            let normDist = normalize(district)
            if let dist = districts.first(where: {
                let n = normalize($0.ilceAdi)
                return n == normDist
                    || n.contains(normDist) || normDist.contains(n)
                    || (normDist.count >= 4 && n.hasPrefix(String(normDist.prefix(4))))
                    || (n.count >= 4 && normDist.hasPrefix(String(n.prefix(4))))
            }) {
                await selectDistrict(dist)
                return
            }
        }

        // İlçe bulunamadıysa merkez ilçeyi seç (genellikle ilk sırada gelir)
        if let first = districts.first {
            await selectDistrict(first)
        }
    }

    // MARK: - Dil değiştir
    func switchLanguage(to lang: String) {
        language = lang
        UserDefaults.standard.set(lang, forKey: langKey)
        if let prayers = todayPrayers {
            notificationManager.schedulePrayerNotifications(prayers: prayers, language: lang)
        }
        Task { await loadPrayerTimes() }
    }

    // MARK: - Sonraki namaz
    func nextPrayer() -> (name: String, time: String, icon: String)? {
        guard let p = todayPrayers, let n = p.nextPrayer() else { return nil }
        return (language == "tr" ? n.name : n.nameEn, n.time, n.icon)
    }

    func timeUntilNextPrayer() -> String? {
        guard let p = todayPrayers, let n = p.nextPrayer() else { return nil }
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
        guard let nextDate = fmt.date(from: n.time) else { return nil }
        let cal = Calendar.current
        var c = cal.dateComponents([.year, .month, .day], from: Date())
        let t = cal.dateComponents([.hour, .minute], from: nextDate)
        c.hour = t.hour; c.minute = t.minute
        guard var target = cal.date(from: c) else { return nil }
        if target < Date() { target = cal.date(byAdding: .day, value: 1, to: target)! }
        let diff = cal.dateComponents([.hour, .minute], from: Date(), to: target)
        let h = diff.hour ?? 0; let m = diff.minute ?? 0
        return language == "tr"
            ? (h > 0 ? "\(h) saat \(m) dk" : "\(m) dakika")
            : (h > 0 ? "\(h)h \(m)m" : "\(m)m")
    }

    var locationLabel: String {
        if let d = selectedDistrict, let c = selectedCity {
            return "\(language == "tr" ? c.sehirAdi : c.sehirAdiEn) / \(language == "tr" ? d.ilceAdi : d.ilceAdiEn)"
        }
        if let c = selectedCity { return language == "tr" ? c.sehirAdi : c.sehirAdiEn }
        return language == "tr" ? "Konum seç" : "Select location"
    }

    private func loadPreferences() {
        // Kullanıcı daha önce dil seçmişse onu kullan, yoksa sistem dilini algıla
        if let savedLanguage = UserDefaults.standard.string(forKey: langKey) {
            language = savedLanguage
        } else {
            // Sistem dilini kontrol et
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            language = systemLanguage.hasPrefix("tr") ? "tr" : "en"
            // İlk kez belirlenen dili kaydet
            UserDefaults.standard.set(language, forKey: langKey)
        }
        useLocation = UserDefaults.standard.bool(forKey: useLocKey)
    }

    // MARK: - Türkçe karakter normalize
    // ÖNEMLİ: Büyük Türkçe harfler (İ, Ş, Ğ...) lowercased() ile sorunlu dönüşür.
    // Örnek: "İ".lowercased() = "i̇" (iki karakter), "i" değil.
    // Bu yüzden önce büyük harfleri değiştirip SONRA lowercased() çağırıyoruz.
    func normalize(_ s: String) -> String {
        s
            // Önce büyük Türkçe harfleri ASCII büyük harf karşılıklarına çevir
            .replacingOccurrences(of: "İ", with: "I")
            .replacingOccurrences(of: "Ğ", with: "G")
            .replacingOccurrences(of: "Ş", with: "S")
            .replacingOccurrences(of: "Ç", with: "C")
            .replacingOccurrences(of: "Ö", with: "O")
            .replacingOccurrences(of: "Ü", with: "U")
            // Şimdi lowercased() güvenli
            .lowercased()
            // Küçük Türkçe harfleri normalize et
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ç", with: "c")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ü", with: "u")
    }
}
