# 📄 app-ads.txt Nedir? Neden Gerekli?

## 🤔 Neden Gerekli?

### Problem: Reklam Sahtekarlığı

**Senaryo:**
1. Siz "Ezan Vakti" uygulamasını yayınladınız
2. Birisi sahte bir "Ezan Vakti" uygulaması yayınlıyor
3. Sahte uygulama **SİZİN AdMob ID'nizi** kullanıyor
4. Sahte uygulama **SİZİN ADİNIZA** reklam gösteriyor
5. Gelir sizin hesabınıza gidiyor **AMA**:
   - Google bunun sahte olduğunu anlar
   - Hesabınızı **KAPATIR** (ban)
   - Paranızı **ÖDEMEZpara**

### Çözüm: app-ads.txt

**app-ads.txt** = "Bu AdMob ID'si sadece BENİM!" beyanı

Google bunu kontrol ederek:
- ✅ Sahte uygulamaları tespit eder
- ✅ Sizin hesabınızı korur
- ✅ Reklam verenlerin parasını doğru yere gönderir

---

## 📋 app-ads.txt İçeriği

### Örnek Dosya:

```txt
google.com, pub-XXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
```

**Açıklama:**
- `google.com` → Reklam ağı (AdMob = Google)
- `pub-XXXXXXXXXXXXX` → **SİZİN** AdMob Publisher ID'niz
- `DIRECT` → Direkt anlaşma (sahte değil!)
- `f08c47fec0942fa0` → Google'ın doğrulama kodu

---

## 🔍 AdMob'dan Nasıl İndirilir?

### Adım 1: AdMob'a Giriş

1. https://admob.google.com adresine gidin
2. Google hesabınızla giriş yapın

### Adım 2: app-ads.txt Sayfasına Git

**Yol 1:**
```
Apps → (Uygulamanızı seçin) → App settings → app-ads.txt
```

**Yol 2:**
```
Sol menü → Apps → App settings → app-ads.txt tab
```

### Adım 3: Dosyayı İndir veya Kopyala

**Seçenek A: Otomatik İndir**
- "Download app-ads.txt" butonuna tıklayın
- Dosya inecek: `app-ads.txt`

**Seçenek B: Manuel Kopyala**
```txt
google.com, pub-1234567890123456, DIRECT, f08c47fec0942fa0
```
(Sizin gerçek Publisher ID'niz olacak)

---

## 🌐 Nereye Yüklenecek?

### Website'nizde!

**Format:**
```
https://yourdomain.com/app-ads.txt
```

**Örnekler:**
```
https://ezanvakti.com/app-ads.txt
https://example.com/app-ads.txt
https://mycompany.io/app-ads.txt
```

---

## 🚫 Website'im Yok, Ne Yapmalıyım?

### Seçenek 1: GitHub Pages (ÜCRETSİZ!)

#### Adım 1: GitHub Repo Oluştur

1. https://github.com adresine gidin
2. Hesap açın (ücretsiz)
3. **New Repository** tıklayın
4. Repo adı: `ezanvakti-app`
5. **Public** seçin
6. **Create repository**

#### Adım 2: app-ads.txt Dosyası Ekle

1. Repo'da **Add file > Create new file**
2. Dosya adı: `app-ads.txt`
3. İçeriği yapıştırın:
   ```txt
   google.com, pub-XXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
   ```
4. **Commit** tıklayın

#### Adım 3: GitHub Pages Aktif Et

1. Repo **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: **main** veya **master**
4. Folder: **/ (root)**
5. **Save**

#### Adım 4: URL'yi AdMob'a Ekle

**URL'niz:**
```
https://KULLANICI_ADINIZ.github.io/ezanvakti-app/app-ads.txt
```

**Örnek:**
```
https://bardic.github.io/ezanvakti-app/app-ads.txt
```

**AdMob'da:**
1. Apps → App settings → Store presence → Developer Website
2. URL'yi yapıştırın
3. **Save**

✅ **5-10 dakika bekleyin**, GitHub Pages aktif olacak!

---

### Seçenek 2: Domain Satın Al (TAVSIYE EDİLİR)

#### Domain Satın Alma

**Popüler Siteler:**
- **Namecheap.com** → ~$10/yıl
- **GoDaddy.com** → ~$12/yıl
- **Google Domains** → ~$12/yıl

**Örnek Domainler:**
```
ezanvakti.app
prayertimes.app
muslimclock.com
```

#### Hosting (Ücretsiz!)

**GitHub Pages + Custom Domain:**

1. Domain satın alın
2. Domain DNS ayarlarında **CNAME** ekleyin:
   ```
   Host: www
   Value: KULLANICI_ADINIZ.github.io
   ```
3. GitHub repo'da **Settings > Pages > Custom domain**:
   ```
   www.ezanvakti.app
   ```
4. app-ads.txt dosyasını ekleyin
5. **Hazır!** → `https://www.ezanvakti.app/app-ads.txt`

---

### Seçenek 3: Firebase Hosting (Google'dan Ücretsiz!)

#### Adım 1: Firebase Projesi Oluştur

1. https://console.firebase.google.com
2. **Add project**
3. Proje adı: "Ezan Vakti"

#### Adım 2: Hosting Aktif Et

1. Sol menü → **Hosting**
2. **Get started** tıklayın
3. Terminal'de:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init hosting
   ```

#### Adım 3: app-ads.txt Ekle

1. `public/app-ads.txt` dosyası oluşturun
2. İçeriği ekleyin
3. Deploy edin:
   ```bash
   firebase deploy
   ```

**URL:**
```
https://ezan-vakti.web.app/app-ads.txt
```

---

## ⏰ Ne Zaman Eklenimeli?

### Timeline:

**1. GELİŞTİRME** (Şimdi):
- ❌ app-ads.txt gerekmez
- ✅ TEST ID'leri kullanın

**2. APP STORE'A GÖNDERME ÖNCESI** (Önemli!):
- ✅ app-ads.txt oluşturun
- ✅ Website'de yayınlayın
- ✅ AdMob'a URL ekleyin
- ✅ Production Ad Unit ID kullanın

**3. APP STORE'DA YAYINDA**:
- ✅ app-ads.txt aktif olmalı
- ✅ Yoksa **gelir alamazsınız**!

---

## 🧪 Doğrulama

### app-ads.txt Çalışıyor mu?

**Browser'da test edin:**
```
https://yourdomain.com/app-ads.txt
```

**Görmeli:**
```txt
google.com, pub-XXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
```

**AdMob'da kontrol:**
1. Apps → App settings → app-ads.txt
2. **Status**: 
   - ✅ **Authorized** → Çalışıyor!
   - ⚠️ **Pending** → 24-48 saat bekleyin
   - ❌ **Not Found** → URL yanlış veya dosya yok

---

## 📊 Sonuçlar

### app-ads.txt OLMADAN:

```
❌ Gelir alamama riski
❌ Sahte uygulamalar sizin ID'nizi kullanabilir
❌ Hesap ban riski
❌ Google ödeme yapmayabilir
⚠️  "app-ads.txt not found" uyarısı
```

### app-ads.txt İLE:

```
✅ Hesabınız korunur
✅ Gelir garantisi
✅ Sahte uygulamalar engellenirse
✅ Google'a güven sinyali
✅ Daha yüksek reklam geliri (Google priorizasyonu)
```

---

## 🎯 Özet

**Ne?** → Sizin AdMob ID'nizin doğruluğunu kanıtlayan dosya

**Neden?** → Sahte uygulamaları engellemek + Hesabınızı korumak

**Nasıl?** → AdMob'dan indirin, website'de yayınlayın

**Ne Zaman?** → App Store'a koymadan ÖNCE!

**Nereye?** → `https://yourdomain.com/app-ads.txt`

**Yoksa?** → ❌ Gelir alamama, ban riski!

---

## ✅ Hızlı Başlangıç (Website Yoksa)

```bash
# 1. GitHub hesabı aç (ücretsiz)
https://github.com

# 2. Yeni repo oluştur
"ezanvakti-app" (public)

# 3. app-ads.txt dosyası ekle
AdMob'dan kopyala → yapıştır

# 4. GitHub Pages aktif et
Settings → Pages → Deploy from main

# 5. URL'yi AdMob'a ekle
https://KULLANICI_ADINIZ.github.io/ezanvakti-app/app-ads.txt

# ✅ Hazır! 5 dakika!
```

---

**Önemli:** App Store'a koymadan mutlaka ekleyin! 🚨
