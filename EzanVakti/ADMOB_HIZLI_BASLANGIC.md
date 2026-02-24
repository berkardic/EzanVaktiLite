# 🚀 AdMob Hızlı Başlangıç - 5 Dakika!

## ✅ Yapıldı

1. ✅ `AdMobManager.swift` - AdMob yönetimi
2. ✅ `AppDelegate.swift` - AdMob başlatma
3. ✅ `ContentView.swift` - Alt banner eklendi
4. ✅ ATT (App Tracking Transparency) desteği

---

## 📋 ŞİMDİ YAPMANIZ GEREKENLER

### 1️⃣ SDK Kur (5 dakika)

#### Swift Package Manager ile:

1. **Xcode**: File > Add Package Dependencies...

2. **URL**:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads
   ```

3. **Version**: 11.0.0

4. **Add to Target**: EzanVakti

5. **Add Package** ✅

---

### 2️⃣ Info.plist Güncelle

Info.plist'e ekleyin (Source Code olarak):

```xml
<!-- App Tracking Transparency -->
<key>NSUserTrackingUsageDescription</key>
<string>Kişiselleştirilmiş reklamlar gösterebilmek için izin gereklidir.</string>

<!-- SKAdNetwork (Google'ın listesini tam ekleyin) -->
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Daha fazlası için ADMOB_KURULUM_REHBERI.md'ye bakın -->
</array>
```

---

### 3️⃣ Build & Test

```bash
⌘B  # Build
⌘R  # Run
```

**Sonuç:**
- ✅ Uygulama açılınca ATT izni popup'ı gelir
- ✅ Sayfa alt kısmında TEST BANNER görünür
- ✅ Gri arka plan + "Test Ad" yazısı

---

### 4️⃣ AdMob Hesabı Oluştur

**Canlıya geçmeden önce:**

1. https://admob.google.com adresine gidin
2. Hesap oluşturun
3. Uygulama ekleyin
4. **Banner Ad Unit** oluşturun
5. **Ad Unit ID** alın:
   ```
   ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX
   ```

6. `AdMobManager.swift`'te TEST ID'yi değiştirin:
   ```swift
   // ÖNCE (TEST):
   private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
   
   // SONRA (PRODUCTION):
   private let bannerAdUnitID = "ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX"
   ```

---

## 🎯 Özellikler

### ATT (App Tracking Transparency)

```swift
// Otomatik olarak istiyor:
await adManager.requestTrackingPermission()
```

**Popup:**
```
"[Uygulama Adı]" Would Like to 
Track Your Activity

Kişiselleştirilmiş reklamlar 
gösterebilmek için izin gereklidir.

[Ask App Not to Track]  [Allow]
```

### Banner Reklam

**Pozisyon**: Sayfa alt kısmı (fixed)

**Boyut**: 320x50 (standart banner)

**Test ID**: Otomatik test reklamı gösterir

**Production**: Gerçek reklamlar gösterir

---

## ⚠️ Önemli Uyarılar

1. **Test ID ile yayınlamayın!**
   - Geliştirmede: TEST ID kullanın
   - Canlıda: Kendi ID'nizi kullanın
   - Yanlış yaparsanız **ban yersiniz**!

2. **Privacy Policy gerekli**
   - App Store'a koymadan önce
   - Website'de yayınlayın
   - App içinde link verin

3. **GDPR Compliance** (AB için)
   - Consent form gösterin
   - UMP SDK kullanın

---

## 🧪 Test Sonuçları

**Başarılı ise:**
```
Console'da:
✅ AdMob initialized
✅ Banner ad loaded
📊 Tracking Permission: 3 (authorized)
```

**Başarısız ise:**
```
Console'da:
❌ Banner ad failed: [hata mesajı]
```

**Çözüm:**
- SDK kuruldu mu?
- Info.plist güncellendi mi?
- Build başarılı mı?

---

## 📊 Gelir Modeli

**Banner Reklamlar:**
- **eCPM**: $1-15 (ülkeye göre)
- **Gösterim**: Kullanıcı sayfa görüntüleme
- **Kazanç**: Gösterim + Tıklama

**Örnek Hesap:**
```
1,000 günlük aktif kullanıcı
× 5 oturum/gün
× 3 sayfa görüntüleme/oturum
= 15,000 gösterim/gün

eCPM $2 × (15,000/1000) = $30/gün
= ~$900/ay 💰
```

---

## 📚 Dokümantasyon

**Detaylı rehber**: `ADMOB_KURULUM_REHBERI.md`

**İçerik:**
- AdMob hesap kurulumu
- Ad Unit oluşturma
- Test cihazları
- GDPR compliance
- Privacy Policy
- Canlıya alma checklist

---

## ✅ Kontrol Listesi

Geliştirme:
- [ ] SDK kuruldu (SPM)
- [ ] Info.plist güncellendi (ATT + SKAdNetwork)
- [ ] Build başarılı
- [ ] ATT popup görünüyor
- [ ] Test banner görünüyor

Canlıya Alma:
- [ ] AdMob hesabı oluşturuldu
- [ ] Banner Ad Unit oluşturuldu
- [ ] Production ID alındı
- [ ] `AdMobManager.swift`'te ID değiştirildi
- [ ] Privacy Policy oluşturuldu
- [ ] app-ads.txt yayınlandı
- [ ] Gerçek cihazda test edildi

---

**Tamamdır! Artık reklam sisteminiz hazır! 💰**

**Sorularınız varsa:** `ADMOB_KURULUM_REHBERI.md` dosyasına bakın

**Hayırlı kazançlar! 🌙⭐**
