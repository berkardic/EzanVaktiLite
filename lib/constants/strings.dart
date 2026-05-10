class AppStrings {
  AppStrings._();

  // Helper: 3-language selector
  static String _s(String lang, String tr, String ar, String en) =>
      lang == 'ar' ? ar : lang == 'tr' ? tr : en;

  static String prayerTimes(String lang) =>
      _s(lang, 'Ezan Vakitleri', 'أوقات الصلاة', 'Prayer Times');
  static String nextPrayer(String lang) =>
      _s(lang, 'Sıradaki Namaz', 'الصلاة القادمة', 'Next Prayer');
  static String location(String lang) =>
      _s(lang, 'Konum', 'الموقع', 'Location');
  static String selectLocation(String lang) =>
      _s(lang, 'İl / İlçe Seç', 'اختر الموقع', 'Select Location');
  static String selectPrompt(String lang) => lang == 'ar'
      ? 'اختر مدينتك ومنطقتك\nلعرض أوقات الصلاة'
      : lang == 'tr'
          ? 'Ezan vakitlerini görmek için\nil ve ilçenizi seçin'
          : 'Select your province and district\nto see prayer times';
  static String loading(String lang) =>
      _s(lang, 'Vakitler yükleniyor...', 'جارٍ التحميل...', 'Loading...');
  static String couldNotLoad(String lang) =>
      _s(lang, 'Vakitler yüklenemedi', 'تعذر تحميل الأوقات', 'Could not load times');
  static String retry(String lang) =>
      _s(lang, 'Tekrar Dene', 'إعادة المحاولة', 'Retry');
  static String settings(String lang) =>
      _s(lang, 'Ayarlar', 'الإعدادات', 'Settings');
  static String done(String lang) => _s(lang, 'Tamam', 'تم', 'Done');
  static String close(String lang) => _s(lang, 'Kapat', 'إغلاق', 'Close');
  static String general(String lang) => _s(lang, 'Genel', 'عام', 'General');
  static String language(String lang) =>
      _s(lang, 'Dil', 'اللغة', 'Language');
  static String notifications(String lang) =>
      _s(lang, 'Bildirimler', 'الإشعارات', 'Notifications');
  static String about(String lang) =>
      _s(lang, 'Hakkında', 'حول التطبيق', 'About');
  static String dataSource(String lang) =>
      _s(lang, 'Veri Kaynağı', 'مصدر البيانات', 'Data Source');
  static String updateDate(String lang) =>
      _s(lang, 'Güncelleme Tarihi', 'آخر تحديث', 'Last Updated');
  static String qiblaCompass(String lang) =>
      _s(lang, 'Kıble Pusulası', 'بوصلة القبلة', 'Qibla Compass');
  static String direction(String lang) =>
      _s(lang, 'Yön', 'الاتجاه', 'Direction');
  static String qibla(String lang) =>
      _s(lang, 'Kıble', 'القبلة', 'Qibla');
  static String qiblaLabel(String lang) =>
      _s(lang, 'KİBLE', 'القبلة', 'QIBLA');
  static String selectProvince(String lang) =>
      _s(lang, 'İl Seç', 'اختر المحافظة', 'Select Province');
  static String selectDistrict(String lang) =>
      _s(lang, 'İlçe Seç', 'اختر المنطقة', 'Select District');
  static String searchCity(String lang) =>
      _s(lang, 'İl ara...', 'البحث عن مدينة...', 'Search...');
  static String searchDistrict(String lang) =>
      _s(lang, 'İlçe ara...', 'البحث عن منطقة...', 'Search...');
  static String citiesLoading(String lang) =>
      _s(lang, 'İller yükleniyor...', 'جارٍ تحميل المدن...', 'Loading...');
  static String districtsLoading(String lang) =>
      _s(lang, 'İlçeler yükleniyor...', 'جارٍ تحميل المناطق...', 'Loading...');
  static String couldNotLoadCities(String lang) =>
      _s(lang, 'Şehirler yüklenemedi', 'تعذر تحميل المدن', 'Could not load cities');
  static String noDistricts(String lang) =>
      _s(lang, 'İlçe bulunamadı', 'لا توجد مناطق', 'No districts found');
  static String back(String lang) =>
      _s(lang, 'İller', 'رجوع', 'Back');
  static String locationPermRequired(String lang) =>
      _s(lang, 'Konum İzni Gerekli', 'إذن الموقع مطلوب', 'Location Permission Required');
  static String openSettings(String lang) =>
      _s(lang, 'Ayarları Aç', 'فتح الإعدادات', 'Open Settings');
  static String cancel(String lang) =>
      _s(lang, 'İptal', 'إلغاء', 'Cancel');
  static String locationDeniedMsg(String lang) => lang == 'ar'
      ? 'فعّل الموقع من الإعدادات > الخصوصية > خدمات الموقع > EzanVakti.'
      : lang == 'tr'
          ? 'Konum iznini Ayarlar > Gizlilik > Konum Servisleri > EzanVakti bölümünden açın.'
          : 'Enable location in Settings > Privacy > Location Services > EzanVakti.';
  static String locationSelectLabel(String lang) =>
      _s(lang, 'Konum seç', 'اختر الموقع', 'Select location');
  static String locationPermissions(String lang) =>
      _s(lang, 'Konum İzinleri', 'أذونات الموقع', 'Location Permissions');
  static String locationDenied(String lang) =>
      _s(lang, 'Konum İzni Reddedildi', 'تم رفض إذن الموقع', 'Location Access Denied');
  static String locationAlways(String lang) =>
      _s(lang, 'Her Zaman İzinli', 'مسموح دائماً', 'Always Allowed');
  static String locationWhileUsing(String lang) =>
      _s(lang, 'Uygulama Kullanımda İzinli', 'مسموح أثناء الاستخدام', 'While Using App');
  static String locationNotAuthorized(String lang) =>
      _s(lang, 'İzin Verilmedi', 'غير مصرح', 'Not Authorized');
  static String requestAlwaysPerm(String lang) =>
      _s(lang, 'Her Zaman Konum İzni İste', 'طلب إذن الموقع الدائم', 'Request Always Permission');
  static String locationPermFooter(String lang) => lang == 'ar'
      ? 'يستخدم إذن الموقع لعرض أوقات الصلاة تلقائياً.'
      : lang == 'tr'
          ? 'Konum izni, bulunduğunuz yere göre otomatik olarak namaz vakitlerini göstermek için kullanılır.'
          : 'Location permission is used to automatically show prayer times for your location.';
  static String backgroundLocationNote(String lang) => lang == 'ar'
      ? 'تفعيل الموقع في الخلفية لميزات الإشعارات المحسّنة.'
      : lang == 'tr'
          ? 'Arka planda da bildirimler için konum bazlı özellikler kullanılabilir.'
          : 'Enable background location for enhanced notification features.';
  static String locationUnavailable(String lang) =>
      _s(lang, 'Konum alınamadı. Açık alanda tekrar deneyin.',
          'تعذر الحصول على الموقع. حاول في مكان مكشوف.',
          'Location unavailable. Try in an open area.');
  static String locationError(String lang) =>
      _s(lang, 'Konum hatası. Tekrar deneyin.',
          'خطأ في الموقع. حاول مرة أخرى.',
          'Location error. Try again.');
  static String citiesUnavailable(String lang) =>
      _s(lang, 'Şehirler yüklenemedi.', 'تعذر تحميل المدن.', 'Cities unavailable.');
  static String internetError(String lang) =>
      _s(lang,
          'Şehirler yüklenemedi. İnternet bağlantınızı kontrol edin.',
          'تعذر تحميل المدن. تحقق من اتصالك بالإنترنت.',
          'Cities could not be loaded. Check your internet connection.');
  static String districtsError(String lang) =>
      _s(lang, 'İlçeler yüklenemedi.', 'تعذر تحميل المناطق.', 'Districts could not be loaded.');
  static String gettingLocation(String lang) =>
      _s(lang, 'Konum alınıyor...', 'جارٍ تحديد الموقع...', 'Getting location...');
  static String locationPermWarning(String lang) =>
      _s(lang,
          'Konum izni gerekli. Lütfen ayarlardan konum iznini açın.',
          'إذن الموقع مطلوب. يرجى تفعيله من الإعدادات.',
          'Location permission required. Please enable location in settings.');
  static String country(String lang) =>
      _s(lang, 'Ülke', 'الدولة', 'Country');
  static String selectCountry(String lang) =>
      _s(lang, 'Ülke Seç', 'اختر الدولة', 'Select Country');
  static String searchCountry(String lang) =>
      _s(lang, 'Ülke ara...', 'البحث عن دولة...', 'Search country...');
  static String countriesLoading(String lang) =>
      _s(lang, 'Ülkeler yükleniyor...', 'جارٍ تحميل الدول...', 'Loading countries...');
  static String couldNotLoadCountries(String lang) =>
      _s(lang, 'Ülkeler yüklenemedi', 'تعذر تحميل الدول', 'Could not load countries');

  static String remaining(String lang) =>
      _s(lang, 'Kalan süre:', 'الوقت المتبقي:', 'Remaining:');

  static String timeLeft(String lang, int h, int m) {
    if (lang == 'ar') {
      return h > 0 ? '$h ساعة $m دقيقة' : '$m دقيقة';
    }
    if (lang == 'tr') {
      return h > 0 ? '$h saat $m dk' : '$m dakika';
    }
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  // Prayer names
  static List<String> prayerNamesTR = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
  static List<String> prayerNamesEN = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static List<String> prayerNamesAR = ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
  static List<String> prayerKeys = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];
  static List<String> prayerEmojis = ['🌙', '🌅', '☀️', '⛅', '🌇', '🌃'];

  static List<String> prayerNames(String lang) =>
      lang == 'ar' ? prayerNamesAR : lang == 'tr' ? prayerNamesTR : prayerNamesEN;

  // Language display names
  static const Map<String, String> languageNames = {
    'tr': 'Türkçe',
    'en': 'English',
    'ar': 'العربية',
  };
}
