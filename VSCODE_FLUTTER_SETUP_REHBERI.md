# 🎯 EzanVakti Flutter - VSCode Setup Rehberi

## ✅ ADIM 1: ÖN ŞARTLAR

### Kurulu Olması Gerekenler

```bash
# Flutter check yaparak kontrol edin
flutter --version

# Çıkması gereken:
# Flutter 3.2.0 or higher
# Dart 3.0 or higher
```

**Eğer kurulu değilse:**
- [flutter.dev](https://flutter.dev) adresinden Flutter SDK'sı indirin
- Sistem PATH'ine ekleyin

---

## ✅ ADIM 2: VSCode KURULUMU

### Gerekli Uzantılar
VSCode'da şu uzantıları yükleyin:

1. **Flutter** (Dart Code tarafından) - ID: `Dart-Code.flutter`
2. **Dart** (Dart Code tarafından) - ID: `Dart-Code.dart-code`
3. **Awesome Flutter Snippets** - ID: `Nash.awesome-flutter-snippets`

### VSCode Settings (`.vscode/settings.json`)

```json
{
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": true
    },
    "editor.defaultFormatter": "Dart-Code.dart"
  },
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 100
}
```

---

## ✅ ADIM 3: PROJE OLUŞTURMA

```bash
# Yeni Flutter projesi oluştur
flutter create ezanvakti_flutter

# Proje klasörüne git
cd ezanvakti_flutter

# VSCode'da aç
code .
```

### Dosya Yapısı

```
ezanvakti_flutter/
├── android/           # Android projesı
├── ios/              # iOS projesi
├── lib/              # Dart kod dosyaları
│   ├── main.dart     # Giriş noktası
│   ├── screens/      # Ekran komponentleri
│   ├── widgets/      # Yeniden kullanılabilir widgetlar
│   ├── models/       # Veri modelleri
│   ├── services/     # API, konum, vb servisler
│   ├── providers/    # State management (Provider)
│   └── utils/        # Yardımcı fonksiyonlar
├── test/             # Unit testleri
├── pubspec.yaml      # Proje bağımlılıkları
└── pubspec.lock      # Locked versiyonlar
```

---

## ✅ ADIM 4: ANDROID EMÜLATÖRÜ KURULUMU

### Seçenek A: Android Studio kullanarak (Kolay)

```bash
# Android Studio'yu açın
# Tools > Device Manager > Create Device
# Pixel 6 Pro seçin, Android 13+ seçin
# Finish tıklayın
```

### Seçenek B: Komut satırı ile

```bash
# Mevcut emülatörleri listele
flutter emulators

# Eğer emülatör yoksa, Android SDK tools kullanarak oluştur
sdkmanager "system-images;android-34;google_apis;x86_64"

# AVD oluştur
avdmanager create avd -n "Flutter_Emulator" \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_6_pro"

# Emülatörü başlat
flutter emulators --launch Flutter_Emulator
```

### Emülatör kontrol listesi

- [ ] Emülatör listesinde görünüyor (`flutter emulators`)
- [ ] Emülatör açılabiliyor (`flutter emulators --launch`)
- [ ] Wi-Fi bağlantısı var
- [ ] Google Play Services kurulu (çoğu sistem imajında var)

---

## ✅ ADIM 5: iOS SİMÜLATÖRÜ KURULUMU (macOS Sadece)

### Otomatik Kurulum

```bash
# iOS Development tools'u yükle
sudo xcode-select --install

# Simulator'ı aç
open -a Simulator

# Mevcut simulators'ları görmek için
xcrun simctl list devices
```

### iOS Simulator Ayarları

1. Simulator açın
2. **Simulator > Settings > General**
3. **Location Services** - ON yapın
4. **Privacy > Location Services** - ON yapın

### Simulator kontrol listesi

- [ ] Simulator açılabiliyor
- [ ] Location Services açık
- [ ] Internet bağlantısı var
- [ ] Xcode 14.0+ kurulu

---

## ✅ ADIM 6: PUBSPEC.YAML GÜNCELLEME

`pubspec.yaml` dosyasını açıp şu içeriği yapıştırın:

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

  # UI & Design
  cupertino_icons: ^1.0.2

  # State Management
  provider: ^6.0.0

  # Location Services
  geolocator: ^9.0.0
  geocoding: ^2.1.0

  # Local Notifications
  flutter_local_notifications: ^14.1.0
  timezone: ^0.9.0

  # Http Client
  http: ^1.1.0

  # Localization
  intl: ^0.18.0

  # Local Storage
  shared_preferences: ^2.2.0

  # Sensors (Compass)
  sensors_plus: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true

  # Assets
  assets:
    - assets/data/
    - assets/locales/
```

---

## ✅ ADIM 7: BAĞIMLILIKLARI YÜKLEMEH

```bash
# Bağımlılıkları yükle
flutter pub get

# (Opsiyonel) Pub outdated pakageler kontrol et
flutter pub outdated

# (Opsiyonel) Upgrade et
flutter pub upgrade
```

---

## ✅ ADIM 8: UYGULAMAYΙ ÇALIŞTIRMA

### VSCode Debug Modu (F5)

1. VSCode sol sidebar'dan **Run and Debug** tıkla
2. **Create a launch.json file** tıkla
3. Aşağıdaki konfigürasyonu yapıştır:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "ezanvakti_flutter",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "args": ["--dart-define=FLUTTER_APPID=com.example.ezanvakti"]
    },
    {
      "name": "ezanvakti_flutter (Release)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
```

### Komut Satırı ile

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Belirli cihazda çalıştır
flutter run -d <device-id>

# Verbose mode (hata ayıklamak için)
flutter run -v
```

### Cihazları listele

```bash
# Bağlı cihazları göster
flutter devices

# Emülatörleri göster
flutter emulators
```

---

## ✅ ADIM 9: ANDROID İZİNLERİ

`android/app/src/main/AndroidManifest.xml` dosyasını açıp şu şekilde güncelleyin:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.ezanvakti">

    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:label="EzanVakti"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## ✅ ADIM 10: iOS İZİNLERİ (macOS Sadece)

`ios/Runner/Info.plist` dosyasını açıp şu değerleri ekleyin:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... mevcut içerik ... -->
    
    <!-- Location Permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>
    
    <!-- Notification Permissions -->
    <key>UIUserInterfaceStyle</key>
    <string>Dark</string>

</dict>
</plist>
```

---

## 🧪 TEST KOMUTLARI

### Debug Modu

```bash
# Tüm testleri çalıştır
flutter test

# Belirli bir test dosyasını çalıştır
flutter test test/models_test.dart

# Watch mode (otomatik rerun)
flutter test --watch
```

### Hot Reload

```
# Uygulamayı başlattıktan sonra:
# VSCode: Ctrl+S (otomatik) veya manuel
# Terminal: 'r' tuşu + Enter (hot reload)
# Terminal: 'R' tuşu + Enter (hot restart)
```

### Performans Monitoring

```bash
# DevTools'u aç
flutter pub global activate devtools
flutter pub global run devtools

# Browser'da http://localhost:9100 açılacak
```

---

## 🐛 YAYGIM HATALAR VE ÇÖZÜMLERI

### 1. "Could not load the Qt platform plugin"
**Çözüm:** Android emülatörünü kapatıp tekrar başlatın
```bash
flutter emulators --launch pixel6
```

### 2. "Gradle build failed"
**Çözüm:** Cache'i temizle
```bash
flutter clean
flutter pub get
flutter run
```

### 3. "XCode build error" (iOS)
**Çözüm:** Pod'ları yenile
```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

### 4. "Location permission denied"
**Çözüm:** Emülatör/Simulator ayarlarında izin verin
- **Android:** Settings > Apps > EzanVakti > Permissions > Location > Allow
- **iOS:** Settings > EzanVakti > Location > While Using the App

### 5. "Unable to connect to API"
**Çözüm:** Emülatörün internet bağlantısı var mı kontrol edin
```bash
# Emülatörü ping'le
ping 8.8.8.8  # Google DNS
```

---

## ✨ KULLANFUL VSCODE KIŞAYOLLARI

| Kısayol | İşlem |
|---------|-------|
| `Ctrl+Shift+D` | Run and Debug |
| `F5` | Start Debugging |
| `F10` | Step Over |
| `F11` | Step Into |
| `Ctrl+K Ctrl+C` | Comment |
| `Ctrl+K Ctrl+U` | Uncomment |
| `Alt+Shift+F` | Format Document |
| `Ctrl+Space` | Intellisense |

---

## 📝 KONTROL LİSTESİ

### Kurulum
- [ ] Flutter 3.2.0+ kurulu
- [ ] VSCode kurulu ve uzantılar yüklenmiş
- [ ] Android Emülatörü kurulu
- [ ] iOS Simulator hazır (macOS)

### Proje Hazırlığı
- [ ] `flutter create` tamamlandı
- [ ] `pubspec.yaml` güncellendi
- [ ] `flutter pub get` çalıştırıldı
- [ ] AndroidManifest.xml güncellemeleri yapıldı
- [ ] Info.plist izinleri eklendi

### Test
- [ ] Android emülatörde `flutter run` başarılı
- [ ] iOS simulatörde `flutter run` başarılı
- [ ] Hot reload çalışıyor
- [ ] DevTools açılabiliyor

---

## 🚀 SONRAKI ADIM

Şimdi `lib/main.dart` dosyasına kodu yazabilirsiniz!

Proje kodunun tamamı `FLUTTER_KOMPLE_PROJE_KODU.md` dosyasında mevcuttur.

---

**Hazırlanma Tarihi:** 03 Mart 2026
**Durum:** ✅ Emülatör/Simulator Test'e Hazır
