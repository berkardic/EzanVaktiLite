# ⚠️ AdMob SDK Versiyonu Sorunu

Eğer hala `'GADBannerView' has been renamed to 'BannerView'` hatası alıyorsanız:

## Çözüm 1: SPM Paketini Güncelle

1. **Xcode**: File > Packages > Update to Latest Package Versions
2. Build ⌘B

## Çözüm 2: Manuel Güncelleme

1. **Xcode**: File > Packages > Reset Package Caches
2. AdMob paketini silin
3. Yeniden ekleyin:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads
   Version: 11.0.0+
   ```

## Çözüm 3: Versiyon Değiştir

Package listesinde AdMob'a sağ tık:
- "Update Package" seçin
- En son versiyon (11.x.x) seçin

---

**Not**: Google AdMob SDK 11.0+ yeni API isimleri kullanıyor.
Eski versiyon (10.x) `GAD...` prefix'i kullanır.

Build başarısız olursa bu dosyayı kontrol edin!
