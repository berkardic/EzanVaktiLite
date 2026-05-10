# 🚀 EzanVakti Flutter - MANUEL KURULUM (VSCode İçin)

## 📦 İndirilen Dosyalar

Outputs klasöründen şunları indirin:
- ✅ `main.dart` 
- ✅ `AndroidManifest.xml`
- ✅ `pubspec.yaml` (rehberlerde)
- ✅ Rehber dosyaları (.md)

## 📋 KURULUM ADIMLARI

### ADIM 1: Proje Oluştur (Terminal)

```bash
flutter create ezanvakti_flutter
cd ezanvakti_flutter
code .
```

### ADIM 2: main.dart Dosyasını Değiştir

1. VSCode'da `lib/main.dart` dosyasını aç
2. **Tüm içeriğini sil** (Ctrl+A → Delete)
3. **İndirilen `main.dart` dosyasının içeriğini kopyala**
4. **Yapıştır** (Ctrl+V)
5. **Kaydet** (Ctrl+S)

### ADIM 3: pubspec.yaml Dosyasını Güncelle

1. VSCode'da `pubspec.yaml` dosyasını aç
2. **Aşağıdaki içeriği yapıştır:**

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

3. **Kaydet** (Ctrl+S)

### ADIM 4: AndroidManifest.xml Güncelle

1. VSCode'da `android/app/src/main/AndroidManifest.xml` aç
2. **İndirilen `AndroidManifest.xml` dosyasının içeriğini kopyala**
3. **Tüm içeriği değiştir** (Ctrl+A → Paste)
4. **Kaydet** (Ctrl+S)

### ADIM 5: Bağımlılıkları Yükle

1. Terminal aç: **Ctrl+`** (VSCode'da)
2. Çalıştır:

```bash
flutter pub get
```

**Bekleme süresi:** 1-2 dakika

### ADIM 6: iOS Info.plist (macOS için)

1. VSCode'da `ios/Runner/Info.plist` dosyasını aç
2. **`</dict>`** satırından önce şunları ekle:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Konum bilginiz namaz vakitlerini belirlemek için gereklidir.</string>

<key>UIUserInterfaceStyle</key>
<string>Dark</string>
```

3. **Kaydet** (Ctrl+S)

### ADIM 7: .vscode Ayarları (İsteğe Bağlı - İyileştirme)

1. **Ctrl+Shift+D** → Run and Debug aç
2. **"create a launch.json file"** tıkla
3. **"Dart"** seç
4. Otomatik yapılandırılacak ✅

### ADIM 8: Emulator Başlat

Terminal'de:

```bash
# Android
flutter emulators --launch pixel6

# iOS (macOS)
open -a Simulator
```

### ADIM 9: Çalıştır!

**Terminal'de:**
```bash
flutter run
```

**VEYA VSCode'da:**
- **F5 tuşu** basın (Debug Debug)

---

## ✅ KONTROL LİSTESİ

Kurulum sırasında:

- [ ] `flutter create` tamamlandı
- [ ] `main.dart` kopyalandı
- [ ] `pubspec.yaml` güncellendi
- [ ] `AndroidManifest.xml` kopyalandı
- [ ] `flutter pub get` çalıştırıldı (bekleme: 1-2 min)
- [ ] `Info.plist` güncellemesi yapıldı (iOS)
- [ ] Emulator başlatıldı
- [ ] `flutter run` çalıştırıldı
- [ ] Uygulama emulator'da göründü ✅

---

## 🎯 İLK ÇALIŞTRMA SÜRESİ

- **Gradle download & build:** 3-5 dakika (ilk kez)
- **Sonraki çalıştırmalar:** 30 saniye (Hot Reload ile 2 saniye!)

---

## 💻 VSCode KISAYOLLARı

| Kısayol | İşlem |
|---------|-------|
| **F5** | Debug başlat |
| **Ctrl+`** | Terminal aç |
| **Ctrl+S** | Kaydet |
| **Ctrl+A** | Hepsini seç |
| **Ctrl+V** | Yapıştır |
| **Ctrl+Shift+D** | Run and Debug |

---

## 🐛 YAYGIM SORUNLAR

### "pubspec.yaml not found"
- Doğru klasörde misiniz? (`ezanvakti_flutter` içinde)
- Terminal'de `ls` yazıp `pubspec.yaml` görün mü?

### "Gradle build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### "Emulator açılmıyor"
```bash
flutter emulators  # Listele
flutter emulators --launch pixel6  # Aç
```

### Konum izni hatası
- **Android:** Emulator Settings > App > EzanVakti > Permissions > Location
- **iOS:** Info.plist kontrol et (ADIM 6)

### "Permission denied"
- Windows PowerShell: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`

---

## 📝 DOSYA YAPISI (SONUNDA)

```
ezanvakti_flutter/
├── lib/
│   └── main.dart                 ← Kodunuz burada ✅
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   ← Android izinleri ✅
├── ios/
│   └── Runner/
│       └── Info.plist            ← iOS izinleri ✅
├── test/
├── assets/
├── .vscode/
│   ├── settings.json             ← VSCode ayarları
│   └── launch.json               ← Debug config
├── pubspec.yaml                  ← Bağımlılıklar ✅
└── .gitignore
```

---

## 🎉 BAŞARILI!

Eğer emulator'da uygulama açıldıysa **TEBRİKLER!** 🎉

Artık:
- ✅ Kodu değiştirebilirsiniz
- ✅ Hot Reload ile test edebilirsiniz (r + Enter)
- ✅ Debug yapabilirsiniz (F5)
- ✅ Emulator'da test edebilirsiniz

---

## 🚀 SONRAKI ADIMLAR

1. **Diyanet API'sine Bağlan**
   - DiyanetService kodunu main.dart'a ekle

2. **Gerçek Konum Servisleri**
   - LocationService kodunu ekle

3. **Bildirim Sistemi**
   - NotificationService kodunu ekle

4. **Daha Fazla Screen**
   - SettingsScreen, QiblaScreen ekle

5. **Release Build**
   - `flutter build apk` (Android)
   - `flutter build ipa` (iOS)

---

**Hazırlanma:** 03 Mart 2026  
**Zorluk Seviyesi:** Beginner - Intermediate  
**Tahmini Zaman:** 10-15 dakika
