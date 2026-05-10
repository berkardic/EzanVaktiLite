import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diyanet_country.dart';
import '../models/diyanet_city.dart';
import '../models/diyanet_district.dart';
import '../models/today_prayers.dart';
import '../services/diyanet_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_counter_service.dart';
import '../constants/strings.dart';
import 'package:intl/intl.dart';

class PrayerTimeViewModel extends ChangeNotifier with WidgetsBindingObserver {
  // Published state
  TodayPrayers? todayPrayers;
  bool isLoading = false;
  bool isLoadingCities = false;
  bool isLoadingDistricts = false;
  bool isLoadingCountries = false;
  String? errorMessage;
  DateTime currentTime = DateTime.now();
  String language = 'tr';
  bool useLocation = false;
  bool isResolvingLocation = false;
  bool isOffline = false;

  List<DiyanetCountry> countries = [];
  List<DiyanetCity> cities = [];
  List<DiyanetDistrict> districts = [];
  DiyanetCountry? selectedCountry;
  DiyanetCity? selectedCity;
  DiyanetDistrict? selectedDistrict;
  String locationAuthStatus = 'unknown';

  final LocationService locationService = LocationService.shared;
  final NotificationService notificationManager = NotificationService.shared;

  Timer? _timer;

  static const _widgetChannel = MethodChannel('com.yba.ezanvakti/widget');
  static const _laChannel    = MethodChannel('com.yba.ezanvakti/liveactivity');

  static const String _langKey = 'appLanguage';
  static const String _countryIdKey = 'selectedCountryId';
  static const String _cityIdKey = 'selectedCityId';
  static const String _distIdKey = 'selectedDistrictId';
  static const String _useLocKey = 'useLocation';
  static const String _themeModeKey = 'themeMode';

  ThemeMode themeMode = ThemeMode.system;

  // Saved country id before countries list is loaded
  int _savedCountryId = DiyanetService.turkeyCountryId;

  // ── Prayer prompt ────────────────────────────────────────────────────────────
  /// Non-null when a prayer time has just arrived and needs a yes/no response.
  ({String key, String nameTr, String nameEn, String time, DateTime date})? prayerPromptRequest;

  void clearPrayerPrompt() {
    prayerPromptRequest = null;
    // No notifyListeners — avoids rebuild loop; HomeScreen tracks separately
  }

  String? _lastDetectedPrayerTime; // HH:mm of the last prayer we checked

  // ── Init ────────────────────────────────────────────────────────────────────

  PrayerTimeViewModel() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    debugPrint('[VM] _init() başladı');

    try {
      await _loadPreferences();
    } catch (e) {
      debugPrint('[VM] _loadPreferences() HATA: $e');
    }

    await PrayerCounterService.shared.loadPendingState();

    _startTimer();

    try {
      await _updateAuthStatus();
    } catch (e) {
      debugPrint('[VM] _updateAuthStatus() HATA: $e');
    }

    try {
      await loadCountries();
    } catch (e) {
      debugPrint('[VM] loadCountries() HATA: $e');
    }

    try {
      await loadCitiesAndRestore();
    } catch (e) {
      debugPrint('[VM] loadCitiesAndRestore() HATA: $e');
    }

    debugPrint('[VM] _init() tamamlandı');
  }

  // Called by HomeScreen after the notification permission dialog is dismissed,
  // so location permission is requested sequentially (not simultaneously).
  void onLocationPermissionResult(String status) {
    locationAuthStatus = status;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPrayerTransition();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  int _lastNotifiedMinute = -1;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now();
      currentTime = now;
      if (now.minute != _lastNotifiedMinute) {
        _lastNotifiedMinute = now.minute;
        _checkPrayerTransition();
        notifyListeners();
      }
    });
  }

  // ── Prayer transition detection ──────────────────────────────────────────────

  PrayerTime? _currentActivePrayer() {
    if (todayPrayers == null) return null;
    final nowStr = DateFormat('HH:mm').format(DateTime.now());
    PrayerTime? last;
    for (final p in todayPrayers!.allTimes) {
      if (p.time.compareTo(nowStr) <= 0) last = p;
    }
    return last;
  }

  static String? _prayerCounterKey(String nameEn) {
    switch (nameEn) {
      case 'Fajr':    return 'fajr';
      case 'Dhuhr':   return 'dhuhr';
      case 'Asr':     return 'asr';
      case 'Maghrib': return 'maghrib';
      case 'Isha':    return 'isha';
      default:        return null; // Sunrise — not counted
    }
  }

  void _checkPrayerTransition() {
    final active = _currentActivePrayer();
    if (active == null) return;
    final counterKey = _prayerCounterKey(active.nameEn);
    if (counterKey == null) return;
    if (active.time == _lastDetectedPrayerTime) return; // Already handled

    // Auto-mark expired pending prayer as not done
    final svc = PrayerCounterService.shared;
    if (svc.pendingKey != null &&
        svc.pendingKey != counterKey &&
        svc.pendingDate != null) {
      svc.setAnswer(svc.pendingKey!, svc.pendingDate!, done: false)
          .then((_) => svc.clearPending());
    }

    _lastDetectedPrayerTime = active.time;
    prayerPromptRequest = (
      key: counterKey,
      nameTr: active.name,
      nameEn: active.nameEn,
      time: active.time,
      date: DateTime.now(),
    );
    notifyListeners();
  }

  /// Call after prayer times load so we can check if current prayer needs prompt
  Future<void> _checkInitialPrayerPrompt() async {
    if (todayPrayers == null) return;

    final fmt = DateFormat('HH:mm');
    final now = DateTime.now();
    final nowStr = fmt.format(now);
    final all = todayPrayers!.allTimes;

    // Find the last COUNTABLE prayer (skipping Sunrise) that has already passed.
    // If we're before Fajr (no prayer has passed yet), fall back to yesterday's
    // last prayer (Isha) by scanning from the end of today's list.
    PrayerTime? target;
    for (int i = all.length - 1; i >= 0; i--) {
      if (_prayerCounterKey(all[i].nameEn) == null) continue; // skip Sunrise
      if (all[i].time.compareTo(nowStr) <= 0) {
        target = all[i];
        break;
      }
    }
    if (target == null) {
      // Before first countable prayer — check yesterday's last prayer
      for (int i = all.length - 1; i >= 0; i--) {
        if (_prayerCounterKey(all[i].nameEn) != null) {
          target = all[i];
          break;
        }
      }
    }

    if (target == null) return;
    final counterKey = _prayerCounterKey(target.nameEn)!;

    _lastDetectedPrayerTime = target.time; // Suppress future timer re-triggers

    final svc = PrayerCounterService.shared;

    // Determine the date this prayer belongs to.
    // If prayer HH:mm is ahead of the current time (e.g. "20:51" at "00:01"),
    // it occurred yesterday.
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = target.time.compareTo(nowStr) > 0
        ? today.subtract(const Duration(days: 1))
        : today;

    final answered = await svc.hasAnswer(counterKey, checkDate);
    if (!answered) {
      prayerPromptRequest = (
        key: counterKey,
        nameTr: target.name,
        nameEn: target.nameEn,
        time: target.time,
        date: checkDate,
      );
      notifyListeners();
    }
  }

  Future<void> _updateAuthStatus() async {
    final permission = await locationService.checkPermission();
    locationAuthStatus = locationService.authStatusString(permission);
    notifyListeners();
  }

  // MARK: - Load countries

  Future<void> loadCountries() async {
    isLoadingCountries = true;
    notifyListeners();

    try {
      final list = await DiyanetService.shared.fetchCountries();
      countries = list;
      isLoadingCountries = false;
      _resolveSelectedCountry();
      notifyListeners();
    } catch (e) {
      debugPrint('[VM] fetchCountries() HATA: $e');
      final cached = await DiyanetService.shared.fetchCountriesCached();
      if (cached != null && cached.isNotEmpty) {
        countries = cached;
      }
      isLoadingCountries = false;
      _resolveSelectedCountry();
      notifyListeners();
    }
  }

  void _resolveSelectedCountry() {
    if (countries.isEmpty) return;
    selectedCountry = countries
        .where((c) => c.id == _savedCountryId)
        .firstOrNull;
    // Default to Turkey if not found
    selectedCountry ??= countries
        .where((c) => c.id == DiyanetService.turkeyCountryId)
        .firstOrNull;
    selectedCountry ??= countries.first;
  }

  // MARK: - Select country

  Future<void> selectCountry(DiyanetCountry country) async {
    selectedCountry = country;
    selectedCity = null;
    selectedDistrict = null;
    todayPrayers = null;
    cities = [];
    districts = [];
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_countryIdKey, country.id);
    prefs.remove(_cityIdKey);
    prefs.remove(_distIdKey);

    await _loadCitiesForCurrentCountry();
  }

  Future<void> _loadCitiesForCurrentCountry() async {
    final countryId = selectedCountry?.id ?? DiyanetService.turkeyCountryId;

    isLoadingCities = true;
    errorMessage = null;
    notifyListeners();

    try {
      cities = await DiyanetService.shared.fetchCities(countryId);
      isOffline = false;
      isLoadingCities = false;
      notifyListeners();
    } catch (e) {
      final cached = await DiyanetService.shared.fetchCitiesCached(countryId);
      if (cached != null && cached.isNotEmpty) {
        cities = cached;
        isOffline = true;
      } else {
        errorMessage = AppStrings.internetError(language);
      }
      isLoadingCities = false;
      notifyListeners();
    }
  }

  // MARK: - Load cities and restore saved preferences

  Future<void> loadCitiesAndRestore() async {
    final countryId = selectedCountry?.id ?? _savedCountryId;

    isLoadingCities = true;
    errorMessage = null;
    notifyListeners();

    try {
      final list = await DiyanetService.shared.fetchCities(countryId);
      cities = list;
      isOffline = false;
      isLoadingCities = false;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final savedCityId = prefs.getInt(_cityIdKey) ?? 0;
      final savedDistId = prefs.getInt(_distIdKey) ?? 0;

      if (savedCityId > 0) {
        final city = list.where((c) => c.id == savedCityId).firstOrNull;
        if (city != null) {
          selectedCity = city;
          isLoadingDistricts = true;
          notifyListeners();

          final distList =
              await DiyanetService.shared.fetchDistricts(city.id);
          districts = distList;
          isLoadingDistricts = false;
          notifyListeners();

          if (savedDistId > 0) {
            final dist =
                distList.where((d) => d.id == savedDistId).firstOrNull;
            if (dist != null) {
              selectedDistrict = dist;
              notifyListeners();
              await loadPrayerTimes();
            }
          }
        }
      }
    } catch (e) {
      isLoadingCities = false;

      final cachedCities =
          await DiyanetService.shared.fetchCitiesCached(countryId);
      if (cachedCities != null && cachedCities.isNotEmpty) {
        cities = cachedCities;
        isOffline = true;
        notifyListeners();

        final prefs = await SharedPreferences.getInstance();
        final savedCityId = prefs.getInt(_cityIdKey) ?? 0;
        final savedDistId = prefs.getInt(_distIdKey) ?? 0;

        if (savedCityId > 0) {
          final city =
              cachedCities.where((c) => c.id == savedCityId).firstOrNull;
          if (city != null) {
            selectedCity = city;
            final cachedDist =
                await DiyanetService.shared.fetchDistrictsCached(city.id);
            if (cachedDist != null) {
              districts = cachedDist;
              if (savedDistId > 0) {
                final dist =
                    cachedDist.where((d) => d.id == savedDistId).firstOrNull;
                if (dist != null) {
                  selectedDistrict = dist;
                  notifyListeners();
                  await loadPrayerTimes();
                  return;
                }
              }
            }
            notifyListeners();
          }
        }
      } else {
        errorMessage = AppStrings.internetError(language);
        notifyListeners();
      }
    }
  }

  // MARK: - Load districts

  Future<void> loadDistricts(DiyanetCity city) async {
    errorMessage = null;
    isLoadingDistricts = true;
    districts = [];
    selectedDistrict = null;
    notifyListeners();

    try {
      final list = await DiyanetService.shared.fetchDistricts(city.id);
      districts = list;
      isOffline = false;
      isLoadingDistricts = false;
      notifyListeners();
    } catch (e) {
      debugPrint('loadDistricts error: $e');
      final cached = await DiyanetService.shared.fetchDistrictsCached(city.id);
      if (cached != null && cached.isNotEmpty) {
        districts = cached;
        isOffline = true;
      } else {
        errorMessage = AppStrings.districtsError(language);
      }
      isLoadingDistricts = false;
      notifyListeners();
    }
  }

  // MARK: - Widget data sync

  /// Writes today's prayer times to the iOS App Group container so
  /// WidgetKit widgets can read them without launching the main app.
  Future<void> _updateWidgetData() async {
    final p = todayPrayers;
    if (p == null) return;

    String tomorrowImsak = '';
    String tomorrowDate = '';
    if (selectedDistrict != null) {
      final td = await DiyanetService.shared.getTomorrowImsakCached(selectedDistrict!.id);
      if (td != null) {
        tomorrowImsak = td.imsak;
        tomorrowDate = td.date;
      }
    }

    _widgetChannel.invokeMethod<void>('updateWidgetData', {
      'city':          p.cityName,
      'district':      p.districtName,
      'date':          p.date,
      'imsak':         p.imsak,
      'gunes':         p.gunes,
      'ogle':          p.ogle,
      'ikindi':        p.ikindi,
      'aksam':         p.aksam,
      'yatsi':         p.yatsi,
      'tomorrowImsak': tomorrowImsak,
      'tomorrowDate':  tomorrowDate,
    }).catchError((_) {
      // Non-fatal: widget update is best-effort (Android has no widget channel)
    });
  }

  // MARK: - Live Activity sync

  /// Starts or updates the iOS Live Activity with the next upcoming prayer.
  /// Silently ignored on Android (channel not registered there).
  Future<void> _updateLiveActivity() async {
    final p = todayPrayers;
    if (p == null) return;

    final now = DateTime.now();
    final prayerNames  = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
    final prayerTimes  = [p.imsak, p.gunes, p.ogle, p.ikindi, p.aksam, p.yatsi];

    DateTime? nextDate;
    String?   nextName;

    for (int i = 0; i < prayerTimes.length; i++) {
      final parts = prayerTimes[i].split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final dt = DateTime(now.year, now.month, now.day, h, m);
      if (dt.isAfter(now)) {
        nextDate = dt;
        nextName = prayerNames[i];
        break;
      }
    }

    final distName = selectedDistrict?.ilceAdi ?? selectedCity?.sehirAdi ?? '';

    if (nextDate == null) {
      // All prayers passed — end activity
      _laChannel.invokeMethod<void>('end').catchError((_) {});
      return;
    }

    _laChannel.invokeMethod<void>('start', {
      'nextPrayerName':      nextName,
      'nextPrayerTimestamp': nextDate.millisecondsSinceEpoch.toDouble(),
      'districtName':        distName,
    }).catchError((_) {});
  }

  // MARK: - Load prayer times

  Future<void> loadPrayerTimes() async {
    if (selectedDistrict == null || selectedCity == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cityName = language == 'tr'
          ? selectedCity!.sehirAdi
          : selectedCity!.sehirAdiEn;
      final distName = language == 'tr'
          ? selectedDistrict!.ilceAdi
          : selectedDistrict!.ilceAdiEn;

      final prayers = await DiyanetService.shared.fetchPrayerTimes(
        districtId: selectedDistrict!.id,
        cityName: cityName,
        districtName: distName,
      );

      todayPrayers = prayers;
      isOffline = false;
      isLoading = false;
      notifyListeners();

      _updateWidgetData();
      _updateLiveActivity();
      notificationManager.schedulePrayerNotifications(prayers, language);
      _checkInitialPrayerPrompt();
    } catch (e) {
      final cached = await DiyanetService.shared
          .fetchPrayerTimesCached(selectedDistrict!.id);
      if (cached != null) {
        todayPrayers = cached;
        isOffline = true;
        isLoading = false;
        notifyListeners();
        _updateWidgetData();
        _updateLiveActivity();
        _checkInitialPrayerPrompt();
      } else {
        debugPrint('[VM] loadPrayerTimes HATA: $e');
        final is5xx = e is DioException &&
            (e.response?.statusCode ?? 0) >= 500;
        errorMessage = is5xx
            ? (language == 'tr'
                ? 'Bu bölge için namaz vakitleri şu an Diyanet sunucusunda mevcut değil.'
                : language == 'ar'
                    ? 'بيانات أوقات الصلاة لهذه المنطقة غير متوفرة حالياً.'
                    : 'Prayer times for this region are currently unavailable on Diyanet servers.')
            : AppStrings.couldNotLoad(language);
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // MARK: - Select city

  Future<void> selectCity(DiyanetCity city) async {
    selectedCity = city;
    selectedDistrict = null;
    todayPrayers = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_cityIdKey, city.id);
    prefs.remove(_distIdKey);

    await loadDistricts(city);
  }

  // MARK: - Select district

  Future<void> selectDistrict(DiyanetDistrict district) async {
    selectedDistrict = district;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_distIdKey, district.id);

    await loadPrayerTimes();
  }

  // MARK: - Location button

  Future<void> enableLocationMode() async {
    if (isResolvingLocation) return;

    useLocation = true;
    isResolvingLocation = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_useLocKey, true);

    final serviceEnabled = await locationService.isServiceEnabled();
    if (!serviceEnabled) {
      isResolvingLocation = false;
      locationAuthStatus = 'serviceDisabled';
      errorMessage = language == 'tr'
          ? 'Cihazınızda Konum Servisleri kapalı.'
          : language == 'ar'
              ? 'خدمات الموقع معطلة على جهازك.'
              : 'Location Services are disabled.';
      notifyListeners();
      return;
    }

    var permission = await locationService.checkPermission();

    if (!locationService.isAuthorized(permission)) {
      permission = await locationService.requestPermission();
    }

    locationAuthStatus = locationService.authStatusString(permission);
    notifyListeners();

    if (permission == LocationPermission.deniedForever) {
      isResolvingLocation = false;
      locationAuthStatus = 'denied';
      notifyListeners();
      await locationService.openAppSettings();
      return;
    }

    if (permission == LocationPermission.denied) {
      isResolvingLocation = false;
      locationAuthStatus = 'denied';
      errorMessage = language == 'tr'
          ? 'Konum izni verilmedi.'
          : language == 'ar'
              ? 'لم يتم منح إذن الموقع.'
              : 'Location permission not granted.';
      notifyListeners();
      return;
    }

    if (locationService.isAuthorized(permission)) {
      await _startLocationRequest();
    } else {
      isResolvingLocation = false;
      notifyListeners();
    }
  }

  Future<void> _startLocationRequest() async {
    try {
      final position = await locationService.getCurrentPosition();
      await _resolveLocation(position.latitude, position.longitude);
    } catch (e) {
      isResolvingLocation = false;
      errorMessage = AppStrings.locationError(language);
      notifyListeners();
    }
  }

  // MARK: - Resolve location

  Future<void> _resolveLocation(double lat, double lon) async {
    try {
      if (cities.isEmpty) {
        try {
          final countryId =
              selectedCountry?.id ?? DiyanetService.turkeyCountryId;
          cities = await DiyanetService.shared.fetchCities(countryId);
          notifyListeners();
        } catch (e) {
          debugPrint('[VM] _resolveLocation fetchCities HATA: $e');
        }
      }

      if (cities.isEmpty) {
        errorMessage = AppStrings.citiesUnavailable(language);
        isResolvingLocation = false;
        notifyListeners();
        return;
      }

      String province = '';
      String district = '';
      String locality = '';
      String detectedIsoCode = '';
      String detectedCountryName = '';

      try {
        final placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          province = placemarks.first.administrativeArea ?? '';
          locality = placemarks.first.locality ?? '';
          district = placemarks.first.subAdministrativeArea ?? locality;
          detectedIsoCode = placemarks.first.isoCountryCode ?? '';
          detectedCountryName = placemarks.first.country ?? '';
        }
      } catch (e) {
        debugPrint('[VM] geocoding HATA: $e');
      }

      debugPrint('[LOC] ── GPS ($lat, $lon) ──────────────────────');
      debugPrint('[LOC] country="$detectedCountryName" iso="$detectedIsoCode"');
      debugPrint('[LOC] province="$province" district="$district" locality="$locality"');

      // Auto-switch country if location is in a different country
      if (countries.isNotEmpty) {
        final matched = _detectCountry(detectedIsoCode, detectedCountryName);
        debugPrint('[LOC] _detectCountry → ${matched == null ? "NULL" : '"${matched.ulkeAdi}" / "${matched.ulkeAdiEn}" id=${matched.id}'}');
        if (matched != null &&
            matched.id != (selectedCountry?.id ?? DiyanetService.turkeyCountryId)) {
          selectedCountry = matched;
          _savedCountryId = matched.id;
          // Clear stale city/district from the previous country
          selectedCity = null;
          selectedDistrict = null;
          todayPrayers = null;
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt(_countryIdKey, matched.id);
          prefs.remove(_cityIdKey);
          prefs.remove(_distIdKey);
          cities = [];
          districts = [];
          notifyListeners();
          try {
            cities = await DiyanetService.shared.fetchCities(matched.id);
          } catch (_) {
            final cached = await DiyanetService.shared.fetchCitiesCached(matched.id);
            if (cached != null) cities = cached;
          }
          notifyListeners();
        }
      } else {
        debugPrint('[LOC] countries listesi boş — ülke tespiti yapılamadı');
      }

      debugPrint('[LOC] cities (${cities.length}): ${cities.map((c) => '"${c.sehirAdi}"/"${c.sehirAdiEn}"').join(', ')}');

      // Coordinate-based fallback only for Turkey
      final isTurkey =
          (selectedCountry?.id ?? DiyanetService.turkeyCountryId) ==
              DiyanetService.turkeyCountryId;
      if (province.isEmpty && isTurkey) {
        province = DiyanetService.shared.findNearestProvince(lat, lon);
      }

      if (province.isEmpty && locality.isEmpty) {
        isResolvingLocation = false;
        notifyListeners();
        return;
      }

      DiyanetCity? _matchCity(String query) {
        if (query.isEmpty) return null;
        final nQ = normalize(query);
        return cities.where((c) {
          final nTR = normalize(c.sehirAdi);
          final nEN = normalize(c.sehirAdiEn);
          return nTR == nQ ||
              nEN == nQ ||
              nTR.contains(nQ) ||
              nEN.contains(nQ) ||
              nQ.contains(nTR) ||
              nQ.contains(nEN) ||
              (nQ.length >= 4 &&
                  (nTR.startsWith(nQ.substring(0, 4)) ||
                      nEN.startsWith(nQ.substring(0, 4))));
        }).firstOrNull;
      }

      // Stage 1: exact/contains match
      DiyanetCity? city = _matchCity(province);
      if (city == null && locality.isNotEmpty && locality != province) {
        city = _matchCity(locality);
      }

      final isTurkeySelected =
          (selectedCountry?.id ?? DiyanetService.turkeyCountryId) ==
              DiyanetService.turkeyCountryId;

      // Stage 2: fuzzy match (handles "Barcelona"→"Barselona", "Munich"→"Münih")
      if (city == null) {
        city = _fuzzyMatchCity(province);
        if (city == null && locality.isNotEmpty && locality != province) {
          city = _fuzzyMatchCity(locality);
        }
      }

      // Stage 3: for countries where Diyanet uses a single "country-as-city"
      // entry (e.g. Spain → "İspanya"), fall back to cities.first so district
      // matching can still find the actual city.
      if (city == null && !isTurkeySelected && cities.isNotEmpty) {
        city = cities.first;
      }

      if (city == null) {
        isResolvingLocation = false;
        notifyListeners();
        return;
      }

      if (selectedCity?.id != city.id) {
        selectedCity = city;
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt(_cityIdKey, city.id);
        isLoadingDistricts = true;
        districts = [];
        notifyListeners();

        try {
          districts = await DiyanetService.shared.fetchDistricts(city.id);
        } catch (e) {
          debugPrint('[VM] _resolveLocation fetchDistricts HATA: $e');
          final cached = await DiyanetService.shared.fetchDistrictsCached(city.id);
          if (cached != null) districts = cached;
        }
        isLoadingDistricts = false;
        notifyListeners();
      }

      debugPrint('[LOC] districts (${districts.length}): ${districts.map((d) => '"${d.ilceAdi}"/"${d.ilceAdiEn}"').join(', ')}');

      if (districts.isEmpty) {
        debugPrint('[LOC] ⚠ districts boş — eşleşme yapılamıyor');
        isResolvingLocation = false;
        notifyListeners();
        return;
      }

      DiyanetDistrict? _matchDistrict(String query) {
        if (query.isEmpty) return null;
        final nQ = normalize(query);
        return districts.where((d) {
          final nTR = normalize(d.ilceAdi);
          final nEN = normalize(d.ilceAdiEn);
          return nTR == nQ ||
              nEN == nQ ||
              nTR.contains(nQ) ||
              nEN.contains(nQ) ||
              nQ.contains(nTR) ||
              nQ.contains(nEN) ||
              (nQ.length >= 4 &&
                  (nTR.startsWith(nQ.substring(0, 4)) ||
                      nEN.startsWith(nQ.substring(0, 4))));
        }).firstOrNull;
      }

      // Stage 1: exact/contains match on district
      // iOS may return "Barcelonès" (subAdmin) or "Barcelona" (locality)
      // while Diyanet has "Barselona" → fuzzy handles the transliteration gap
      DiyanetDistrict? matchedDist = _matchDistrict(district);
      debugPrint('[LOC] exact district("$district") → ${matchedDist?.ilceAdi ?? "null"}');
      if (matchedDist == null && locality.isNotEmpty && locality != district) {
        matchedDist = _matchDistrict(locality);
        debugPrint('[LOC] exact district("$locality") → ${matchedDist?.ilceAdi ?? "null"}');
      }

      // Stage 2: fuzzy match on district
      if (matchedDist == null) {
        matchedDist = _fuzzyMatchDistrict(district);
        if (matchedDist == null && locality.isNotEmpty && locality != district) {
          matchedDist = _fuzzyMatchDistrict(locality);
        }
      }

      // Stage 3: province name as district query (some countries list province
      // name as both city and district)
      if (matchedDist == null && province.isNotEmpty && province != district && province != locality) {
        debugPrint('[LOC] trying province as district query: "$province"');
        matchedDist = _matchDistrict(province) ?? _fuzzyMatchDistrict(province);
      }

      debugPrint('[LOC] ── SONUÇ: city="${city?.sehirAdi}" district="${matchedDist?.ilceAdi ?? "BULUNAMADI → districts.first"}" ──');

      isResolvingLocation = false;
      notifyListeners();
      if (matchedDist != null) {
        await selectDistrict(matchedDist);
      } else if (districts.isNotEmpty) {
        // Last resort: first district (typically the capital/largest city)
        debugPrint('[LOC] fallback → districts.first="${districts.first.ilceAdi}"');
        await selectDistrict(districts.first);
      }
    } catch (e) {
      debugPrint('[VM] _resolveLocation HATA: $e');
      isResolvingLocation = false;
      notifyListeners();
    }
  }

  // MARK: - Language switch

  void switchLanguage(String lang) {
    language = lang;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_langKey, lang);
    });

    if (todayPrayers != null) {
      notificationManager.schedulePrayerNotifications(todayPrayers!, lang);
    }
    notifyListeners();
    loadPrayerTimes();
  }

  // MARK: - Next prayer

  ({String name, String time, IconData icon})? nextPrayer() {
    if (todayPrayers == null) return null;
    final n = todayPrayers!.nextPrayer();
    if (n == null) return null;
    String displayName;
    if (language == 'ar') {
      final idx = AppStrings.prayerNamesTR.indexOf(n.name);
      displayName = idx >= 0 ? AppStrings.prayerNamesAR[idx] : n.nameEn;
    } else {
      displayName = language == 'tr' ? n.name : n.nameEn;
    }
    return (name: displayName, time: n.time, icon: n.icon);
  }

  String? timeUntilNextPrayer() {
    if (todayPrayers == null) return null;
    final n = todayPrayers!.nextPrayer();
    if (n == null) return null;

    final fmt = DateFormat('HH:mm');
    final nextTime = fmt.parse(n.time);
    final now = DateTime.now();

    var target = DateTime(
        now.year, now.month, now.day, nextTime.hour, nextTime.minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    final diff = target.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;

    return AppStrings.timeLeft(language, h, m);
  }

  /// 0.0 = just after last prayer, 1.0 = next prayer time reached
  double prayerProgress() {
    final prayers = todayPrayers;
    if (prayers == null) return 0.0;

    final fmt = DateFormat('HH:mm');
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    final all = prayers.allTimes;

    // Find the last prayer that already passed
    int? prevMin;
    for (int i = all.length - 1; i >= 0; i--) {
      final t = fmt.parse(all[i].time);
      final tMin = t.hour * 60 + t.minute;
      if (tMin <= nowMin) {
        prevMin = tMin;
        break;
      }
    }

    final next = prayers.nextPrayer();
    if (next == null) return 1.0;

    final nextT = fmt.parse(next.time);
    final nextMin = nextT.hour * 60 + nextT.minute;

    if (prevMin == null) {
      // Before first prayer of the day — use yesterday's last prayer as the
      // start of the current interval (overnight window: Isha → Fajr).
      final lastT = fmt.parse(all.last.time);
      prevMin = lastT.hour * 60 + lastT.minute;
      // Falls through to the nextMin <= prevMin branch below.
    }

    if (nextMin <= prevMin) {
      // Next prayer is after midnight (e.g. imsak wraps)
      final total = (24 * 60 - prevMin) + nextMin;
      final elapsed = nowMin >= prevMin
          ? nowMin - prevMin
          : (24 * 60 - prevMin) + nowMin;
      if (total <= 0) return 0.0;
      return (elapsed / total).clamp(0.0, 1.0);
    }

    final total = nextMin - prevMin;
    if (total <= 0) return 0.0;
    return ((nowMin - prevMin) / total).clamp(0.0, 1.0);
  }

  String get locationLabel {
    if (selectedDistrict != null && selectedCity != null) {
      final cityName = language == 'tr'
          ? selectedCity!.sehirAdi
          : selectedCity!.sehirAdiEn;
      final distName = language == 'tr'
          ? selectedDistrict!.ilceAdi
          : selectedDistrict!.ilceAdiEn;
      // Show country prefix for non-Turkey selections
      if (selectedCountry != null &&
          selectedCountry!.id != DiyanetService.turkeyCountryId) {
        final cName = language == 'tr'
            ? selectedCountry!.ulkeAdi
            : selectedCountry!.ulkeAdiEn;
        return '$cName / $cityName / $distName';
      }
      return '$cityName / $distName';
    }
    if (selectedCity != null) {
      return language == 'tr'
          ? selectedCity!.sehirAdi
          : selectedCity!.sehirAdiEn;
    }
    return AppStrings.locationSelectLabel(language);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_langKey);
    if (savedLang != null) {
      language = savedLang;
    } else {
      // Auto-detect from device locale on first launch
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      final code = locales.isNotEmpty ? locales.first.languageCode : '';
      if (code == 'ar') {
        language = 'ar';
      } else if (code == 'tr') {
        language = 'tr';
      } else {
        language = 'en';
      }
      prefs.setString(_langKey, language);
    }
    useLocation = prefs.getBool(_useLocKey) ?? false;
    _savedCountryId =
        prefs.getInt(_countryIdKey) ?? DiyanetService.turkeyCountryId;
    final savedTheme = prefs.getString(_themeModeKey) ?? 'system';
    themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  // MARK: - Country auto-detection from GPS

  DiyanetCountry? _detectCountry(String isoCode, String countryName) {
    if (countries.isEmpty) return null;
    // Turkey has a known fixed ID — fast path
    if (isoCode == 'TR') {
      return countries
          .where((c) => c.id == DiyanetService.turkeyCountryId)
          .firstOrNull;
    }
    // Try matching by EN/TR display name (case-insensitive, normalized)
    if (countryName.isNotEmpty) {
      final q = normalize(countryName);
      return countries.where((c) {
        final en = normalize(c.ulkeAdiEn);
        final tr = normalize(c.ulkeAdi);
        return en == q || tr == q || en.contains(q) || q.contains(en);
      }).firstOrNull;
    }
    return null;
  }

  // MARK: - Turkish character normalization

  String normalize(String s) {
    return s
        .replaceAll('\u0130', 'I')
        .replaceAll('\u011E', 'G')
        .replaceAll('\u015E', 'S')
        .replaceAll('\u00C7', 'C')
        .replaceAll('\u00D6', 'O')
        .replaceAll('\u00DC', 'U')
        .toLowerCase()
        .replaceAll('\u0131', 'i')
        .replaceAll('\u011F', 'g')
        .replaceAll('\u015F', 's')
        .replaceAll('\u00E7', 'c')
        .replaceAll('\u00F6', 'o')
        .replaceAll('\u00FC', 'u');
  }

  // MARK: - Fuzzy matching (handles Diyanet Turkish transliterations)
  // e.g. "Barcelona" → "Barselona", "London" → "Londra", "Munich" → "Münih"

  /// Strips all diacritics/accents + lowercases for language-agnostic comparison.
  String _normFuzzy(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâãä]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll('ý', 'y')
      .replaceAll('ß', 'ss')
      .replaceAll('\u0131', 'i') // ı
      .replaceAll('\u011f', 'g') // ğ
      .replaceAll('\u015f', 's') // ş
      .replaceAll('\u00e7', 'c') // ç
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Sørensen–Dice coefficient on character bigrams [0.0–1.0].
  /// Works well for short city names with transliteration differences.
  double _bigramSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.length < 2 || b.length < 2) return a.isNotEmpty && b.isNotEmpty && a[0] == b[0] ? 0.3 : 0.0;
    final sa = <String>{};
    final sb = <String>{};
    for (int i = 0; i < a.length - 1; i++) sa.add(a.substring(i, i + 2));
    for (int i = 0; i < b.length - 1; i++) sb.add(b.substring(i, i + 2));
    final common = sa.intersection(sb).length;
    return (2 * common) / (sa.length + sb.length);
  }

  /// Returns the highest bigram similarity between [query] and the two
  /// candidate strings (TR name and EN name of a city/district).
  double _fuzzyScore(String query, String cand1, String cand2) {
    final q = _normFuzzy(query);
    final s1 = _bigramSimilarity(q, _normFuzzy(cand1));
    final s2 = _bigramSimilarity(q, _normFuzzy(cand2));
    return s1 > s2 ? s1 : s2;
  }

  /// Best-matching city from [cities] for [query], or null if below [threshold].
  DiyanetCity? _fuzzyMatchCity(String query, {double threshold = 0.55}) {
    if (query.isEmpty || cities.isEmpty) return null;
    // Collect all scores for debug output
    final scored = cities.map((c) => (c, _fuzzyScore(query, c.sehirAdi, c.sehirAdiEn))).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final top = scored.take(3).map((e) => '"${e.$1.sehirAdi}"=${e.$2.toStringAsFixed(2)}').join(', ');
    final best = scored.first.$2 > threshold ? scored.first.$1 : null;
    debugPrint('[LOC] fuzzyCity("$query") top3: [$top] → ${best == null ? "NO MATCH (threshold=$threshold)" : '"${best.sehirAdi}" ✓'}');
    return best;
  }

  /// Best-matching district from [districts] for [query], or null if below [threshold].
  DiyanetDistrict? _fuzzyMatchDistrict(String query, {double threshold = 0.55}) {
    if (query.isEmpty || districts.isEmpty) return null;
    // Collect all scores for debug output
    final scored = districts.map((d) => (d, _fuzzyScore(query, d.ilceAdi, d.ilceAdiEn))).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final top = scored.take(3).map((e) => '"${e.$1.ilceAdi}"=${e.$2.toStringAsFixed(2)}').join(', ');
    final best = scored.first.$2 > threshold ? scored.first.$1 : null;
    debugPrint('[LOC] fuzzyDist("$query") top3: [$top] → ${best == null ? "NO MATCH (threshold=$threshold)" : '"${best.ilceAdi}" ✓'}');
    return best;
  }
}
