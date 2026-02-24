# 📱 AdMob ve ATT Kurulum Rehberi

## 🎯 Yapılması Gerekenler

### 1. Info.plist'e ATT İzni Ekle

**App Tracking Transparency** izni için Info.plist'e ekleyin:

```xml
<!-- App Tracking Transparency İzni -->
<key>NSUserTrackingUsageDescription</key>
<string>Kişiselleştirilmiş reklamlar gösterebilmek için izin gereklidir. Verileriniz güvenli tutulur.</string>
```

**İngilizce için** (en.lproj/InfoPlist.strings):
```
"NSUserTrackingUsageDescription" = "We need permission to show personalized ads. Your data is kept secure.";
```

---

### 2. Google AdMob SDK Kurulumu

#### Seçenek A: Swift Package Manager (SPM) - ÖNERİLEN

1. **Xcode'da**: File > Add Package Dependencies...

2. **URL girin**:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads
   ```

3. **Version**: "Up to Next Major" → 11.0.0 seçin

4. **Add to Target**: EzanVakti seçin

5. **Add Package** tıklayın

#### Seçenek B: CocoaPods

1. **Podfile oluşturun** (proje klasöründe):
   ```ruby
   platform :ios, '14.0'

   target 'EzanVakti' do
     use_frameworks!
     pod 'Google-Mobile-Ads-SDK'
   end
   ```

2. **Terminal'de**:
   ```bash
   cd /Users/bardic/Documents/AITEST/EzanVakti/EzanVakti
   pod install
   ```

3. **`.xcworkspace` dosyasını** açın (artık `.xcodeproj` değil!)

---

### 3. Google AdMob Hesabı Oluştur

1. **AdMob'a gidin**: https://admob.google.com

2. **Hesap oluşturun** veya Google hesabıyla giriş yapın

3. **Uygulama ekleyin**:
   - App Name: "Ezan Vakti"
   - Platform: iOS
   - App Store URL: (henüz yoksa "No" seçin)

4. **Ad Unit oluşturun**:
   - Ad format: **Banner**
   - Ad unit name: "Ana Sayfa Banner"
   
5. **Ad Unit ID'yi kopyalayın**:
   ```
   ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX
   ```

---

### 4. Test ID'lerini Production ID'lerle Değiştirin

`AdMobManager.swift` dosyasında:

```swift
// ❌ TEST (Şu an)
private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

// ✅ PRODUCTION (AdMob'dan aldığınız gerçek ID)
private let bannerAdUnitID = "ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX"
```

**⚠️ ÖNEMLİ**: 
- Geliştirme sırasında **TEST ID** kullanın
- Canlıya geçerken **kendi Ad Unit ID'nizi** kullanın
- Test ID ile yayınlarsanız **ban yersiniz**!

---

### 5. App-ads.txt Dosyası (App Store'a Koymadan ÖNCE!)

1. **AdMob'da**: Apps > App settings > app-ads.txt

2. **Dosyayı indirin** veya içeriği kopyalayın

3. **Website'inizde** yayınlayın:
   ```
   https://yourdomain.com/app-ads.txt
   ```

4. Yoksa domain satın alın veya GitHub Pages kullanın

---

### 6. SKAdNetwork ID'lerini Ekle (iOS 14.5+)

Info.plist'e ekleyin:

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4fzdc2evr5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v72qych5uu.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ludvb6z3bs.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2u9pt9hc89.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>yclnxrl5pm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>c6k4g5qg8m.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>mlmmfzh3r3.skadnetwork</string>
    </dict>
</array>
```

**Tam liste**: https://developers.google.com/admob/ios/quick-start#skadnetwork

---

## 🧪 Test

### Adım 1: Build & Run

```bash
⌘B  # Build
⌘R  # Run (gerçek iPhone veya simülatör)
```

### Adım 2: İzinleri Kontrol Et

**Uygulama açılınca sırayla:**
1. ✅ Bildirim izni popup'ı
2. ✅ Konum izni popup'ı
3. ✅ **Tracking izni popup'ı** (ATT) ← YENİ!

### Adım 3: Banner Reklamı Kontrol Et

- ✅ Sayfa alt kısmında banner görünmeli
- ✅ Test reklamı yüklenmeli (gri arka plan + "Test Ad" yazısı)
- ✅ Console'da: "✅ Banner ad loaded"

---

## 📊 AdMob Dashboard

### Gelir Takibi

1. **AdMob Dashboard**: https://admob.google.com
2. **Metrics**: Günlük gelir, gösterim, tıklama
3. **Reports**: Detaylı raporlar

### Önemli Metrikler

- **Impressions** (Gösterim): Reklam kaç kez görüldü
- **CTR** (Click-Through Rate): Tıklama oranı
- **eCPM**: 1000 gösterim başına kazanç
- **Revenue**: Toplam gelir

---

## ⚠️ Önemli Notlar

### 1. Test Cihazları

Kendi cihazınızı test cihazı olarak ekleyin:

```swift
// AdMobManager.swift'te
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
    GADSimulatorID,
    "YOUR_DEVICE_IDFA" // Console'dan alın
]
```

### 2. GDPR ve Privacy

**AB kullanıcıları için**:
- UMP (User Messaging Platform) kullanın
- Consent form gösterin
- Privacy Policy sayfası oluşturun

### 3. Apple Review

**App Store Review için**:
- Privacy Policy linki ekleyin
- ATT iznini doğru açıklayın
- Test ID'lerini production ID'lerle değiştirin

### 4. Reklam Politikaları

**İzin verilmeyen içerik**:
- Şiddet, cinsellik
- Sahte bilgiler
- Spam, tıklama hilesi

---

## 🚀 Canlıya Alma Checklist

- [ ] AdMob hesabı oluşturuldu
- [ ] App eklendi
- [ ] Banner Ad Unit oluşturuldu
- [ ] Production Ad Unit ID alındı
- [ ] `AdMobManager.swift`'te TEST ID → PRODUCTION ID
- [ ] Info.plist'e ATT izni eklendi
- [ ] SKAdNetwork ID'leri eklendi
- [ ] app-ads.txt dosyası yayınlandı
- [ ] Privacy Policy oluşturuldu
- [ ] Gerçek cihazda test edildi
- [ ] Banner reklamı görünüyor
- [ ] ATT izni çalışıyor

---

## 📞 Destek

**AdMob Dokümantasyon**: https://developers.google.com/admob/ios

**Swift Package**: https://github.com/googleads/swift-package-manager-google-mobile-ads

**Sorun mu var?**
- Console loglarını kontrol edin
- AdMob dashboard'da hesap durumunu kontrol edin
- Test ID'lerini kullandığınızdan emin olun

---

## 💰 Gelir Tahmini

**Ortalama eCPM** (1000 gösterim başına):
- Türkiye: $1-3
- ABD/AB: $5-15
- Ortadoğu: $2-8

**Örnek**:
- 10,000 aktif kullanıcı
- Her biri günde 10 reklam görür
- 100,000 gösterim/gün
- eCPM $2 → **$200/gün** → **$6,000/ay**

---

**Hayırlı kazançlar! 💰🌙⭐**
