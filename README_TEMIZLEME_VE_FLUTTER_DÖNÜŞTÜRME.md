# 🕌 EzanVakti Flutter - Temizlenmiş ve Optimize Edilmiş Versiyon

Flutter ile Android ve iOS için yazılmış İslami namaz vakitleri takip uygulaması.

## 📋 Orijinal Proje Analizi

### Silinmiş Dosyalar
- ❌ `Models.swift` - Boş model dosyası
- ❌ `Item.swift` - Kullanılmayan SwiftData modeli  
- ❌ Test dosyaları (boş test cases)
- ❌ 7 Markdown dokümentasyon dosyası (AdMob/NotificationSystem rehberleri)
- ❌ Xcode konfigürasyon dosyaları (.xcuserdata, .git history)
- ❌ macOS yedekleme dosyaları (__MACOSX)

### Temizlenen Kod
- ContentView.swift'den LocationDebugPanel() kaldırıldı (~50 satır)
- AppDelegate.swift sadeleştirildi

### Tutulmuş Dosyalar
1. **DiyanetService.swift** (280L) → `lib/services/diyanet_service.dart`
2. **LocationManager.swift** (180L) → `lib/services/location_service.dart`
3. **NotificationManager.swift** (145L) → `lib/services/notification_service.dart`
4. **PrayerTimeViewModel.swift** (405L) → `lib/providers/prayer_time_provider.dart`
5. **AdMobManager.swift** (117L) → `lib/services/admob_service.dart`
6. **ContentView + UI Components** → `lib/screens/` ve `lib/widgets/`
7. **turkey-geo.json** (185KB) → `lib/assets/data/turkey-geo.json`

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                          # Uygulamanın giriş noktası
├── models/
│   ├── prayer_time.dart             # Namaz vakti modelleri
│   └── settings.dart                # Uygulama ayarları modeli
├── services/
│   ├── diyanet_service.dart         # Diyanet API entegrasyonu
│   ├── location_service.dart        # Coğrafi konum hizmetleri
│   ├── notification_service.dart    # Bildirim sistemi
│   ├── admob_service.dart          # Google AdMob reklam yönetimi
│   └── storage_service.dart         # Yerel depolama (SharedPreferences)
├── providers/
│   ├── prayer_time_provider.dart    # Namaz vakti state management
│   ├── location_provider.dart       # Konum state management
│   └── settings_provider.dart       # Ayarlar state management
├── screens/
│   ├── home_screen.dart             # Ana ekran
│   ├── city_picker_screen.dart      # Şehir/ilçe seçici
│   ├── settings_screen.dart         # Ayarlar ekranı
│   ├── qibla_screen.dart            # Kıbla pusula ekranı
│   └── splash_screen.dart           # Açılış ekranı
├── widgets/
│   ├── prayer_time_card.dart        # Namaz vakti kartı
│   ├── prayer_grid.dart             # Namaz vakitleri ızgarası
│   ├── location_row.dart            # Konum satırı widget
│   ├── next_prayer_banner.dart      # Sonraki namaz banner
│   ├── islamic_background.dart      # İslami arka plan
│   ├── qibla_compass.dart          # Kıbla pusula
│   └── loading_overlay.dart         # Yükleme göstergesi
├── utils/
│   ├── constants.dart               # Sabitler (API URL'leri, vb)
│   ├── colors.dart                  # Renk paletleri
│   ├── localization.dart            # Çoklu dil desteği (TR/EN)
│   └── helpers.dart                 # Yardımcı fonksiyonlar
├── assets/
│   ├── data/
│   │   └── turkey-geo.json         # Şehir/ilçe veri tabanı
│   ├── locales/
│   │   ├── tr.json                 # Türkçe çeviriler
│   │   └── en.json                 # İngilizce çeviriler
│   └── images/
│       └── app_icon.png            # Uygulama ikonu
└── app.dart                         # Material/Cupertino uygulama konfigürasyonu

android/
├── app/
│   ├── build.gradle                 # Android build konfigürasyonu
│   ├── src/main/
│   │   ├── AndroidManifest.xml     # İzinler, AdMob ID
│   │   └── kotlin/com/ezanvakti/   # Platform kanalları
│   └── google-services.json        # Firebase/AdMob konfigürasyonu
└── gradle.properties

ios/
├── Runner/
│   ├── Info.plist                  # iOS ayarları, izin açıklamaları
│   ├── Runner.entitlements        # iOS yetkilendirmeler
│   └── GoogleService-Info.plist    # Firebase/AdMob konfigürasyonu
└── Podfile                         # iOS bağımlılıkları

pubspec.yaml                        # Proje meta bilgileri ve bağımlılıklar
pubspec.lock                        # Bağımlılık versiyonları (otomatik)

test/                               # Unit ve widget testleri
```

## 📦 Bağımlılıklar

### State Management
- `provider: ^6.0.0` - Basit ve etkili state yönetimi

### Konum & Haritalar
- `geolocator: ^9.0.0` - GPS konum hizmetleri
- `geocoding: ^2.1.0` - Reverse geocoding

### Bildirimler
- `flutter_local_notifications: ^14.1.0` - Yerel bildirimler
- `timezone: ^0.9.0` - Zaman dilimi desteği

### Reklamlar
- `google_mobile_ads: ^4.0.0` - Google AdMob entegrasyonu

### Pusula & Sensörler
- `sensors_plus: ^4.0.0` - Pusula ve açı hesapları
- `flutter_compass: ^0.6.0` - Pusula rotasyonu

### Diğer
- `http: ^1.1.0` - HTTP istekleri
- `intl: ^0.18.0` - Uluslararası tarih/saat formatı
- `shared_preferences: ^2.2.0` - Yerel depolama
- `flutter_localization: ^0.1.0` - Çoklu dil desteği

## 🚀 Başlangıç

### Gereksinimler
- Flutter 3.2.0+
- Android SDK 21+
- iOS 12.0+
- Xcode 14.0+ (iOS geliştirme için)
- Android Studio (Android geliştirme için)

### Kurulum

```bash
# Bağımlılıkları yükle
flutter pub get

# Kod üretme (JSON serialization için)
flutter pub run build_runner build

# Uygulamayı çalıştır
flutter run

# Web için (opsiyonel)
flutter run -d chrome

# iOS build
flutter build ios

# Android build
flutter build apk
flutter build appbundle
```

## ⚙️ Platform-Spesifik Ayarlar

### Android Konfigürasyonu (android/app/build.gradle)
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        targetSdk 34
        
        // AdMob App ID
        manifestPlaceholders = [
            'com.google.android.gms.ads.APPLICATION_ID': 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy'
        ]
    }
}
```

### iOS Konfigürasyonu (ios/Runner/Info.plist)
```xml
<dict>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>
    
    <key>NSLocalNetworkUsageDescription</key>
    <string>Yerel ağ izni gereklidir.</string>
    
    <key>NSBonjourServiceTypes</key>
    <array>
        <string>_services._dns-sd._udp</string>
    </array>
</dict>
```

### AndroidManifest.xml İzinleri
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## 🎨 UI/UX Özellikleri

- ✅ İslami tasarım (gradient arka planlar, geometrik desenler)
- ✅ Karanlık mod desteği
- ✅ Smooth animasyonlar
- ✅ Responsive tasarım (tüm cihaz boyutlarına uyumlu)
- ✅ İki dil desteği (Türkçe/İngilizce)
- ✅ Geri çekilebilir bildirim sistemi

## 🔔 Bildirim Sistemi

- Şehir seçildikten sonra namaz vakitleri için bildirimler
- Kullanıcı her bir namaz vakti için bildirimleri ayrı ayrı açabilir/kapatabilir
- Sistem zamanı değiştiğinde otomatik olarak bildirimleri yeniden planla

## 🗺️ Konum Servisleri

- GPS tabanlı otomatik konum belirleme
- Reverse geocoding ile şehir/ilçe bulma
- Manuel şehir/ilçe seçimi
- İzin yönetimi ve error handling

## 📱 Kıbla Pusula

- Cihazın pusula sensörü ile Kıbla yönünü göster
- Açılı gösterge
- İslami tasarım

## 💰 AdMob Entegrasyonu

- Banner reklamlar (ana ekranın altında)
- Interstitial reklamlar (şehir seçiminden sonra)
- Reward reklamlar (premium özellikler için)

## 🌐 API Entegrasyonları

### Diyanet Vakitler API
```
https://vakit.rnvzr.io/api/timezoneByCity/{cityId}/{districtId}
```

- Şehir listesi
- İlçe listesi
- Günlük namaz vakitleri
- Hicri takvim tarihi

## 📊 Versiyon Geçmişi

### v1.0.0 (İlk Sürüm)
- Temel namaz vakitleri gösterimi
- Konum tabanlı otomatik belirleme
- Manuel şehir/ilçe seçimi
- Bildirim sistemi
- Kıbla pusula
- Ayarlar (dil, bildirimleri toggle)
- AdMob reklam entegrasyonu

## 🐛 Bilinen Sorunlar

Şu an hiçbir bilinen sorun yoktur.

## 🤝 Katkıda Bulunma

Bu proje açık kaynak değildir. Sorunlar ve öneriler için lütfen issue açın.

## 📄 Lisans

Tüm hakları saklıdır.

## 👨‍💻 Geliştirici

Proje Flutter'a dönüştürülmüş ve optimize edilmiştir.

---

## 🎯 Temizleme Özeti

**Orijinal SwiftUI Projesi:**
- 2,300+ satır kod
- 18 dosya (Swift + Config)
- 7 dokümantasyon dosyası
- ~14MB boyut

**Temizlenen Flutter Projesi:**
- Tüm gereksiz dosyalar kaldırıldı
- İlgili Swift kodları Flutter'a çevrildi
- Modüler, ölçeklenebilir yapı
- Platform-agnostik (Android + iOS)
- ~2MB boyut (sadece kaynak kod)

---

**Son Güncelleme:** 03 Mart 2026
