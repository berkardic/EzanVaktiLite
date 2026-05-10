# iOS Bundle ID Düzeltme Talimatları

Xcode'da şu adımları takip edin:

## 1. Adım: Xcode'da Projeyi Açın
```bash
open ios/Runner.xcworkspace
```

## 2. Adım: Runner Projesini Seçin
- Sol panelde en üstteki **Runner** (mavi ikon) projesine tıklayın

## 3. Adım: Signing & Capabilities
- Orta panelde **TARGETS** altında **Runner** seçin
- **Signing & Capabilities** sekmesine tıklayın

## 4. Adım: Ayarları Düzenleyin

### Debug, Profile ve Release için (her biri için ayrı ayrı):
1. **Automatically manage signing** kutusunu işaretleyin ✅
2. **Team** dropdown'dan Apple ID'nizi seçin (yoksa Add Account diyerek ekleyin)
3. **Bundle Identifier** değiştirin:
   - Eski: `com.ezanvakti.ezanVakti`
   - Yeni: `com.berkardic.ezanvakti` (veya istediğiniz benzersiz bir isim)

## 5. Adım: Apple ID Ekleyin (Gerekirse)
Eğer **Team** kısmında hesabınız yoksa:
1. **Xcode → Settings** (veya Preferences)
2. **Accounts** sekmesi
3. **+** butonuna tıklayın
4. Apple ID'nizi girin
5. Sign In yapın

## 6. Adım: Test Edin
Terminal'de:
```bash
cd /Users/bardic/Documents/AITEST/EzanVaktiFlutter
flutter clean
flutter run
```

---

## Manuel Düzenleme (Alternatif)

Eğer Xcode'da yapamıyorsanız, terminal'de şu komutu çalıştırın:

```bash
# project.pbxproj dosyasını düzenle
sed -i '' 's/com\.ezanvakti\.ezanVakti/com.berkardic.ezanvakti/g' ios/Runner.xcodeproj/project.pbxproj

# DEVELOPMENT_TEAM satırlarını kaldır (boş bırak)
sed -i '' 's/DEVELOPMENT_TEAM = 752JRF6XQU;/DEVELOPMENT_TEAM = "";/g' ios/Runner.xcodeproj/project.pbxproj

# CODE_SIGN_STYLE ekle (otomatik imzalama)
sed -i '' '/CLANG_ENABLE_MODULES = YES;/a\
                CODE_SIGN_STYLE = Automatic;
' ios/Runner.xcodeproj/project.pbxproj
```

Sonra Xcode'da Team'i manuel seçin.
