# 🚀 EzanVakti Flutter - Kurulum ve Çalıştırma Adımları

## 📋 HIZLI BAŞLANGIIÇ (5 dakika)

```bash
# 1. Flutter projesi oluştur
flutter create ezanvakti_flutter
cd ezanvakti_flutter

# 2. VSCode'da aç
code .

# 3. main.dart dosyasını değiştir (sağlanan main.dart dosyasını kopyala)

# 4. pubspec.yaml'ı güncelle (aşağıdaki bölüme bak)

# 5. Bağımlılıkları yükle
flutter pub get

# 6. Emülatörü/Simulator'ı başlat

# 7. Çalıştır
flutter run
```

---

## 📦 pubspec.yaml (Tam Içerik)

`pubspec.yaml` dosyasında aşağıdaki içeriği olması gerekir:

```yaml
name: ezanvakti_flutter
description: "İslam İbadetlerinin Vakitlerini Takip Etmek İçin Flutter Uygulaması"
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.0.0
  geolocator: ^9.0.0
  geocoding: ^2.1.0
  flutter_local_notifications: ^14.1.0
  timezone: ^0.9.0
  http: ^1.1.0
  intl: ^0.18.0
  shared_preferences: ^2.2.0
  sensors_plus: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/data/
    - assets/locales/
```

---

## 🤖 ANDROID EMÜLATÖRÜ BAŞLATMA

### Seçenek 1: Android Studio kullanarak (Kolay)

```bash
# Android Studio açın
# Menu: Tools > Device Manager
# "Create Device" tıklayın
# "Pixel 6" seçin
# "Android 13" ve üzeri seçin
# "Finish" tıklayın

# Sonra emülatörü başlatabilirsiniz:
flutter emulators --launch pixel6
```

### Seçenek 2: Komut satırı ile

```bash
# Kurulu emülatörleri listele
flutter emulators

# Emülatörü başlat
flutter emulators --launch pixel6

# Veya Android SDK tools ile
sdkmanager "system-images;android-34;google_apis;x86_64"
avdmanager create avd -n "ezanvakti_test" \
  -k "system-images;android-34;google_apis;x86_64"

# Başlat
emulator -avd ezanvakti_test
```

---

## 🍎 iOS SİMÜLATÖRÜ BAŞLATMA (macOS Sadece)

```bash
# Simulator'ı aç
open -a Simulator

# VSCode'dan çalıştırma
flutter run -d "iPhone 14"

# Simulator'ları listele
xcrun simctl list devices

# Terminal'den başlat
xcrun simctl boot <device-uuid>
```

---

## 🎯 FLUTTER ÇALIŞTRMA KOMUTLARI

### VSCode İçinde (F5 Basın)

VSCode sol sidebar'daki **Run and Debug** seçeneğine tıklayın ve başlayın.

### Terminal'den

```bash
# Debug mode (sıcak reload ile)
flutter run

# Release mode (hızlı, debug bilgisi yok)
flutter run --release

# Verbose mode (ayrıntılı log)
flutter run -v

# Belirli cihazda çalıştır
flutter run -d <cihaz-id>

# Cihazları listele
flutter devices
```

---

## 🔧 ANDROID SETUP

### AndroidManifest.xml Güncelle

`android/app/src/main/AndroidManifest.xml` dosyasını açıp:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Satırlarının bulunduğundan emin olun.

### build.gradle Kontrol Et

`android/app/build.gradle` dosyasında:

```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}
```

---

## 🍎 iOS SETUP

### Info.plist Güncelle

`ios/Runner/Info.plist` dosyasını açıp şu bölümü ekleyin:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>

<key>UIUserInterfaceStyle</key>
<string>Dark</string>
```

---

## ✅ KONTROL LİSTESİ

Başlangıçtan önce kontrol edin:

- [ ] Flutter kurulu (`flutter --version`)
- [ ] VSCode kurulu ve uzantıları yüklenmiş
- [ ] Android SDK kurulu
- [ ] Xcode kurulu (macOS için)
- [ ] Emülatör/Simulator hazır (`flutter emulators`)
- [ ] `flutter pub get` çalıştırıldı
- [ ] `pubspec.yaml` doğru
- [ ] `android/app/src/main/AndroidManifest.xml` güncellemeleri yapıldı
- [ ] `ios/Runner/Info.plist` güncellemeleri yapıldı

---

## 🚀 TEST KOMUTLARI

```bash
# Tüm testleri çalıştır
flutter test

# Widget testleri izle (otomatik rerun)
flutter test --watch

# Coverage raporu
flutter test --coverage

# DevTools'u aç
flutter pub global activate devtools
flutter pub global run devtools
# http://localhost:9100 açılacak
```

---

## 🧞 HOT RELOAD KULLANMA

Uygulamayı başlattıktan sonra:

**VSCode'da:** Dosya kaydet (Ctrl+S)
**Terminal'de:** `r` tuşu + Enter (Hot Reload)
**Terminal'de:** `R` tuşu + Enter (Hot Restart)

---

## 🐛 SORUN GİDERME

### Emülatör açılmıyor
```bash
flutter clean
flutter pub get
flutter run -v
```

### "Gradle build failed"
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

### "XCode error" (iOS)
```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

### Konum izni hatası
- **Android:** Emülatör ayarlarından Settings > Apps > EzanVakti > Permissions > Location
- **iOS:** Simulator ayarlarından Privacy > Location Services

---

## 📱 DOSYA YAPISI

```
ezanvakti_flutter/
├── lib/
│   └── main.dart          # ← Sağlanan kodu buraya kopyala
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml  # ← Güncellemeleri buraya yap
├── ios/
│   └── Runner/
│       └── Info.plist     # ← Güncellemeleri buraya yap
└── pubspec.yaml           # ← Bağımlılıkları buraya ekle
```

---

## ✨ VSCode KISAYOLLARı

| Kısayol | İşlem |
|---------|-------|
| F5 | Debug başlat |
| Ctrl+Shift+D | Run and Debug paneli |
| Ctrl+` | Terminal aç |
| Ctrl+Alt+N | Yeni dosya |
| Ctrl+Shift+E | Explorer |

---

## 📞 DESTEK

Sorular için:
1. `VSCODE_FLUTTER_SETUP_REHBERI.md` dosyasını okuyun
2. Terminal çıktısında hataları kontrol edin (`flutter run -v`)
3. Flutter dokumentasyonunu kontrol edin (flutter.dev)

---

**Hazırlanma Tarihi:** 03 Mart 2026
**Durum:** ✅ Emülatör/Simulator'da test için hazır
