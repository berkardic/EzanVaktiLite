# 🕌 Ezan Vakti - iOS Namaz Vakitleri Uygulaması

Modern ve kullanıcı dostu iOS namaz vakitleri uygulaması. Diyanet İşleri Başkanlığı verilerine dayanır.

## ✨ Özellikler

- 📍 **Otomatik Konum Tespiti** - GPS ile bulunduğunuz yerin vakitlerini gösterir
- 🏙️ **81 İl, Tüm İlçeler** - Türkiye'nin her yerinden namaz vakitleri
- 🔔 **Akıllı Bildirimler** - Her vakit için özelleştirilebilir bildirimler
- 🧭 **Kıble Pusulası** - Gerçek zamanlı pusula ile kıble yönü
- 🌙 **İslami Tasarım** - Göz yormayan, zarif arayüz
- 🌍 **Çok Dilli** - Türkçe ve İngilizce destek
- 💰 **AdMob Entegrasyonu** - Gelir modeli için banner reklamlar

## 📱 Gereksinimler

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+

## 🛠️ Kurulum

### 1. Projeyi Klonlayın

```bash
git clone git@github.com:KULLANICIADI/EzanVakti.git
cd EzanVakti
```

### 2. Swift Packages Yükleyin

Xcode projeyi açtığında otomatik yükleyecektir:
- Google Mobile Ads SDK

Veya manuel:
```
File > Add Package Dependencies...
URL: https://github.com/googleads/swift-package-manager-google-mobile-ads
```

### 3. Info.plist Ayarları

Gerekli izinler otomatik eklenmiştir:
- ✅ NSUserTrackingUsageDescription (AdMob ATT)
- ✅ NSLocationWhenInUseUsageDescription
- ✅ SKAdNetworkItems

### 4. AdMob Setup

`AdMobManager.swift` dosyasında:

```swift
// TEST (Geliştirme)
private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

// PRODUCTION (Yayın)
// private let bannerAdUnitID = "ca-app-pub-XXXXX/YYYYY"
```

## 📂 Proje Yapısı

```
EzanVakti/
├── EzanVaktiApp.swift          # App entry point
├── ContentView.swift            # Ana ekran
├── PrayerTimeViewModel.swift   # Business logic
├── DiyanetService.swift        # API servisi
├── LocationManager.swift       # Konum yönetimi
├── NotificationManager.swift   # Bildirim sistemi
├── AdMobManager.swift          # Reklam yönetimi
├── SettingsView.swift          # Ayarlar ekranı
├── QiblaCompassView.swift      # Kıble pusulası
└── CityDistrictPickerView.swift # Şehir/İlçe seçici
```

## 🎨 Ekran Görüntüleri

_(Buraya App Store screenshot'ları ekleyebilirsiniz)_

## 📊 Kullanılan Teknolojiler

- **SwiftUI** - Modern UI framework
- **Combine** - Reactive programming
- **CoreLocation** - GPS ve konum servisleri
- **UserNotifications** - Local bildirimler
- **Google AdMob** - Banner reklamlar
- **App Tracking Transparency** - iOS 14.5+ reklam izinleri

## 🔧 Geliştirme

### Debug Modu

`ContentView.swift` içinde debug panelini açın:

```swift
// LocationDebugPanel()
//     .padding(.horizontal)
//     .padding(.top, 12)
```

Yorumu kaldırarak konum debug bilgilerini görebilirsiniz.

### API Endpoint

Diyanet API:
```
https://ezanvakti.emushaf.net
```

Endpoints:
- `GET /sehirler/{ulkeId}` - Şehir listesi
- `GET /ilceler/{sehirId}` - İlçe listesi  
- `GET /vakitler/{ilceId}` - Namaz vakitleri

## 📝 Lisans

Bu proje özel (private) bir repository'dir.

## 👤 Geliştirici

Geliştirici: **[Adınız]**

## 🙏 Teşekkürler

- Diyanet İşleri Başkanlığı - Namaz vakitleri verisi
- Google AdMob - Monetization platform

---

**Not:** Production'a geçmeden önce AdMob test ID'lerini gerçek ID'lerle değiştirmeyi unutmayın!
