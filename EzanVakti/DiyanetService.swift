import Foundation

// MARK: - API Response Models

struct DiyanetCountry: Codable, Identifiable, Hashable {
    let id: Int
    let ulkeAdi: String
    let ulkeAdiEn: String
    enum CodingKeys: String, CodingKey {
        case id = "UlkeID"
        case ulkeAdi = "UlkeAdi"
        case ulkeAdiEn = "UlkeAdiEn"
    }
}

struct DiyanetCity: Codable, Identifiable, Hashable {
    let id: Int
    let sehirAdi: String
    let sehirAdiEn: String

    enum CodingKeys: String, CodingKey {
        case id = "SehirID"
        case sehirAdi = "SehirAdi"
        case sehirAdiEn = "SehirAdiEn"
    }

    // API "SehirID" alanını STRING olarak döner ("500" gibi).
    // JSONDecoder bunu Int olarak okuyamaz; bu init bunu çözer.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        sehirAdi    = try c.decode(String.self, forKey: .sehirAdi)
        sehirAdiEn  = try c.decode(String.self, forKey: .sehirAdiEn)
        if let intVal = try? c.decode(Int.self, forKey: .id) {
            id = intVal
        } else {
            let strVal = try c.decode(String.self, forKey: .id)
            guard let parsed = Int(strVal) else {
                throw DecodingError.dataCorruptedError(forKey: .id, in: c,
                    debugDescription: "SehirID Int'e dönüştürülemedi: \(strVal)")
            }
            id = parsed
        }
    }
}

struct DiyanetDistrict: Codable, Identifiable, Hashable {
    let id: Int
    let ilceAdi: String
    let ilceAdiEn: String

    enum CodingKeys: String, CodingKey {
        case id = "IlceID"
        case ilceAdi = "IlceAdi"
        case ilceAdiEn = "IlceAdiEn"
    }

    // API "IlceID" alanını STRING olarak döner ("9146" gibi).
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ilceAdi    = try c.decode(String.self, forKey: .ilceAdi)
        ilceAdiEn  = try c.decode(String.self, forKey: .ilceAdiEn)
        if let intVal = try? c.decode(Int.self, forKey: .id) {
            id = intVal
        } else {
            let strVal = try c.decode(String.self, forKey: .id)
            guard let parsed = Int(strVal) else {
                throw DecodingError.dataCorruptedError(forKey: .id, in: c,
                    debugDescription: "IlceID Int'e dönüştürülemedi: \(strVal)")
            }
            id = parsed
        }
    }
}

struct DiyanetPrayerEntry: Codable {
    let imsak: String
    let gunes: String
    let ogle: String
    let ikindi: String
    let aksam: String
    let yatsi: String
    let miladiTarihKisa: String
    enum CodingKeys: String, CodingKey {
        case imsak = "Imsak"; case gunes = "Gunes"; case ogle = "Ogle"
        case ikindi = "Ikindi"; case aksam = "Aksam"; case yatsi = "Yatsi"
        case miladiTarihKisa = "MiladiTarihKisa"
    }
}

// MARK: - App Model

struct TodayPrayers {
    let cityName: String
    let districtName: String
    let imsak: String
    let gunes: String
    let ogle: String
    let ikindi: String
    let aksam: String
    let yatsi: String
    let date: String

    var allTimes: [(name: String, nameEn: String, time: String, icon: String)] {[
        ("İmsak",  "Fajr",    imsak,  "moon.stars.fill"),
        ("Güneş",  "Sunrise", gunes,  "sunrise.fill"),
        ("Öğle",   "Dhuhr",   ogle,   "sun.max.fill"),
        ("İkindi", "Asr",     ikindi, "cloud.sun.fill"),
        ("Akşam",  "Maghrib", aksam,  "sunset.fill"),
        ("Yatsı",  "Isha",    yatsi,  "moon.fill")
    ]}

    func nextPrayer() -> (name: String, nameEn: String, time: String, icon: String)? {
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
        let now = fmt.string(from: Date())
        for p in allTimes { if p.time > now { return p } }
        return allTimes.first
    }
}

// MARK: - Service

class DiyanetService {
    static let shared = DiyanetService()
    private let base = "https://ezanvakti.emushaf.net"
    let turkeyCountryId = 2

    // MARK: Şehirleri çek
    func fetchCities() async throws -> [DiyanetCity] {
        let data = try await get("\(base)/sehirler/\(turkeyCountryId)")
        return try JSONDecoder().decode([DiyanetCity].self, from: data)
    }

    // MARK: İlçeleri çek
    func fetchDistricts(cityId: Int) async throws -> [DiyanetDistrict] {
        let data = try await get("\(base)/ilceler/\(cityId)")
        return try JSONDecoder().decode([DiyanetDistrict].self, from: data)
    }

    // MARK: Vakitleri çek
    func fetchPrayerTimes(districtId: Int, cityName: String, districtName: String) async throws -> TodayPrayers {
        let data = try await get("\(base)/vakitler/\(districtId)")
        let entries = try JSONDecoder().decode([DiyanetPrayerEntry].self, from: data)

        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy"
        fmt.locale = Locale(identifier: "en_US_POSIX")
        let today = fmt.string(from: Date())
        guard let entry = entries.first(where: { $0.miladiTarihKisa == today }) ?? entries.first
        else { throw APIError.noData }

        return TodayPrayers(
            cityName: cityName, districtName: districtName,
            imsak: entry.imsak, gunes: entry.gunes, ogle: entry.ogle,
            ikindi: entry.ikindi, aksam: entry.aksam, yatsi: entry.yatsi,
            date: entry.miladiTarihKisa
        )
    }

    // MARK: HTTP GET
    private func get(_ urlStr: String) async throws -> Data {
        guard let url = URL(string: urlStr) else { throw APIError.invalidURL }
        var req = URLRequest(url: url)
        req.timeoutInterval = 15
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }
        return data
    }

    // MARK: - Koordinat tabanlı il tahmini (geocoding başarısız olduğunda fallback)
    // Normalize edilmiş il adı döner — normalize() fonksiyonuyla eşleşecek şekilde
    func findNearestProvince(lat: Double, lon: Double) -> String {
        var best = ("istanbul", Double.infinity)
        for p in Self.provinceCoordinates {
            let d = (lat - p.1) * (lat - p.1) + (lon - p.2) * (lon - p.2)
            if d < best.1 { best = (p.0, d) }
        }
        return best.0
    }

    // 81 il — normalize edilmiş ASCII isimleri ve koordinatları
    // normalize("İSTANBUL") == "istanbul" olacak şekilde hazırlandı
    static let provinceCoordinates: [(String, Double, Double)] = [
        ("adana",            37.0000, 35.3213),
        ("adiyaman",         37.7648, 38.2786),
        ("afyonkarahisar",   38.7507, 30.5567),
        ("agri",             39.7191, 43.0503),
        ("amasya",           40.6499, 35.8353),
        ("ankara",           39.9334, 32.8597),
        ("antalya",          36.8969, 30.7133),
        ("artvin",           41.1828, 41.8183),
        ("aydin",            37.8444, 27.8458),
        ("balikesir",        39.6484, 27.8826),
        ("bilecik",          40.1506, 29.9792),
        ("bingol",           38.8854, 40.4983),
        ("bitlis",           38.4006, 42.1095),
        ("bolu",             40.7359, 31.6069),
        ("burdur",           37.7200, 30.2900),
        ("bursa",            40.1885, 29.0610),
        ("canakkale",        40.1553, 26.4142),
        ("cankiri",          40.6013, 33.6134),
        ("corum",            40.5506, 34.9556),
        ("denizli",          37.7765, 29.0864),
        ("diyarbakir",       37.9144, 40.2306),
        ("edirne",           41.6818, 26.5623),
        ("elazig",           38.6748, 39.2225),
        ("erzincan",         39.7500, 39.5000),
        ("erzurum",          39.9043, 41.2679),
        ("eskisehir",        39.7767, 30.5206),
        ("gaziantep",        37.0662, 37.3833),
        ("giresun",          40.9128, 38.3895),
        ("gumushane",        40.4386, 39.5086),
        ("hakkari",          37.5744, 43.7408),
        ("hatay",            36.4018, 36.3498),
        ("isparta",          37.7648, 30.5566),
        ("mersin",           36.8000, 34.6333),
        ("istanbul",         41.0082, 28.9784),
        ("izmir",            38.4189, 27.1287),
        ("kars",             40.6013, 43.0975),
        ("kastamonu",        41.3887, 33.7827),
        ("kayseri",          38.7225, 35.4875),
        ("kirklareli",       41.7333, 27.2167),
        ("kirsehir",         39.1425, 34.1709),
        ("kocaeli",          40.8533, 29.8815),
        ("konya",            37.8667, 32.4833),
        ("kutahya",          39.4167, 29.9833),
        ("malatya",          38.3552, 38.3095),
        ("manisa",           38.6191, 27.4289),
        ("kahramanmaras",    37.5858, 36.9371),
        ("mardin",           37.3212, 40.7245),
        ("mugla",            37.2153, 28.3636),
        ("mus",              38.7462, 41.4942),
        ("nevsehir",         38.6939, 34.6857),
        ("nigde",            37.9667, 34.6833),
        ("ordu",             40.9862, 37.8797),
        ("rize",             41.0201, 40.5234),
        ("sakarya",          40.6940, 30.4358),
        ("samsun",           41.2867, 36.3300),
        ("siirt",            37.9333, 41.9500),
        ("sinop",            42.0231, 35.1531),
        ("sivas",            39.7477, 37.0179),
        ("tekirdag",         41.0000, 27.5167),
        ("tokat",            40.3167, 36.5500),
        ("trabzon",          41.0015, 39.7178),
        ("tunceli",          39.1079, 39.5461),
        ("sanliurfa",        37.1591, 38.7969),
        ("usak",             38.6823, 29.4082),
        ("van",              38.4891, 43.4089),
        ("yozgat",           39.8181, 34.8147),
        ("zonguldak",        41.4564, 31.7987),
        ("aksaray",          38.3552, 34.0370),
        ("bayburt",          40.2552, 40.2249),
        ("karaman",          37.1759, 33.2287),
        ("kirikkale",        39.8468, 33.5153),
        ("batman",           37.8812, 41.1351),
        ("sirnak",           37.5164, 42.4611),
        ("bartin",           41.6344, 32.3375),
        ("ardahan",          41.1105, 42.7022),
        ("igdir",            39.9237, 44.0450),
        ("yalova",           40.6500, 29.2667),
        ("karabuk",          41.2061, 32.6204),
        ("kilis",            36.7184, 37.1212),
        ("osmaniye",         37.0742, 36.2464),
        ("duzce",            40.8438, 31.1565),
    ]
}

enum APIError: LocalizedError {
    case invalidURL, serverError, noData, decodingError
    var errorDescription: String? {
        switch self {
        case .invalidURL:    return "Geçersiz URL"
        case .serverError:   return "Sunucu hatası"
        case .noData:        return "Veri bulunamadı"
        case .decodingError: return "Veri işleme hatası"
        }
    }
}
