import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diyanet_country.dart';
import '../models/diyanet_city.dart';
import '../models/diyanet_district.dart';
import '../models/diyanet_prayer_entry.dart';
import '../models/today_prayers.dart';

class DiyanetService {
  static final DiyanetService shared = DiyanetService._();
  DiyanetService._();

  final _dio = Dio(BaseOptions(
    baseUrl: 'https://ezanvakti.emushaf.net',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  ));

  static const int turkeyCountryId = 2;

  static const _keyCountries = 'cache_countries_v2';
  static const _keyCitiesPrefix = 'cache_cities_v2_';
  static const _keyDistrictsPrefix = 'cache_districts_v2_';
  static const _keyPrayersPrefix = 'cache_prayers_v2_';
  static const _keyTomorrowImsakPrefix = 'cache_tomorrow_imsak_v2_';
  static const _keyTomorrowDatePrefix = 'cache_tomorrow_date_v2_';

  // MARK: - Countries

  Future<List<DiyanetCountry>> fetchCountries() async {
    final response = await _dio.get('/ulkeler');
    final raw = response.data;
    if (raw is! List) throw Exception('Ülkeler: beklenmedik API cevabı');
    final countries = raw.map((e) => DiyanetCountry.fromJson(e as Map<String, dynamic>)).toList();
    _saveCountries(countries);
    return countries;
  }

  Future<List<DiyanetCountry>?> fetchCountriesCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCountries);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => DiyanetCountry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveCountries(List<DiyanetCountry> countries) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        _keyCountries, jsonEncode(countries.map((c) => c.toJson()).toList()));
  }

  // MARK: - Cities

  Future<List<DiyanetCity>> fetchCities(int countryId) async {
    final response = await _dio.get('/sehirler/$countryId');
    final raw = response.data;
    if (raw is! List) throw Exception('Şehirler: beklenmedik API cevabı');
    final cities = raw.map((e) => DiyanetCity.fromJson(e as Map<String, dynamic>)).toList();
    _saveCities(countryId, cities);
    return cities;
  }

  Future<List<DiyanetCity>?> fetchCitiesCached(int countryId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyCitiesPrefix$countryId');
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => DiyanetCity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveCities(int countryId, List<DiyanetCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('$_keyCitiesPrefix$countryId',
        jsonEncode(cities.map((c) => c.toJson()).toList()));
  }

  // MARK: - Districts

  Future<List<DiyanetDistrict>> fetchDistricts(int cityId) async {
    final response = await _dio.get('/ilceler/$cityId');
    final raw = response.data;
    if (raw is! List) throw Exception('İlçeler: beklenmedik API cevabı');
    final districts = raw.map((e) => DiyanetDistrict.fromJson(e as Map<String, dynamic>)).toList();
    _saveDistricts(cityId, districts);
    return districts;
  }

  Future<List<DiyanetDistrict>?> fetchDistrictsCached(int cityId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyDistrictsPrefix$cityId');
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => DiyanetDistrict.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveDistricts(
      int cityId, List<DiyanetDistrict> districts) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('$_keyDistrictsPrefix$cityId',
        jsonEncode(districts.map((d) => d.toJson()).toList()));
  }

  // MARK: - Prayer times

  Future<TodayPrayers> fetchPrayerTimes({
    required int districtId,
    required String cityName,
    required String districtName,
  }) async {
    final response = await _dio.get('/vakitler/$districtId');
    final raw = response.data;
    if (raw is! List || raw.isEmpty) throw Exception('Vakitler: beklenmedik API cevabı');
    final entries = raw.map((e) => DiyanetPrayerEntry.fromJson(e as Map<String, dynamic>)).toList();

    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final tomorrow = DateFormat('dd.MM.yyyy').format(DateTime.now().add(const Duration(days: 1)));
    final entry = entries.firstWhere(
      (e) => e.miladiTarihKisa == today,
      orElse: () => entries.first,
    );

    // Save tomorrow's imsak so the widget can show it after all prayers pass
    DiyanetPrayerEntry? tomorrowEntry;
    for (final e in entries) {
      if (e.miladiTarihKisa == tomorrow) { tomorrowEntry = e; break; }
    }
    if (tomorrowEntry != null) {
      await _saveTomorrowImsak(districtId, tomorrowEntry.imsak, tomorrowEntry.miladiTarihKisa);
    }

    final prayers = TodayPrayers(
      cityName: cityName,
      districtName: districtName,
      imsak: entry.imsak,
      gunes: entry.gunes,
      ogle: entry.ogle,
      ikindi: entry.ikindi,
      aksam: entry.aksam,
      yatsi: entry.yatsi,
      date: entry.miladiTarihKisa,
    );
    _savePrayers(districtId, prayers);
    return prayers;
  }

  Future<TodayPrayers?> fetchPrayerTimesCached(int districtId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final raw = prefs.getString('${_keyPrayersPrefix}${districtId}_$today');
    if (raw == null) return null;
    return TodayPrayers.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _saveTomorrowImsak(int districtId, String imsak, String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyTomorrowImsakPrefix$districtId', imsak);
    await prefs.setString('$_keyTomorrowDatePrefix$districtId', date);
  }

  Future<({String imsak, String date})?> getTomorrowImsakCached(int districtId) async {
    final prefs = await SharedPreferences.getInstance();
    final imsak = prefs.getString('$_keyTomorrowImsakPrefix$districtId');
    final date = prefs.getString('$_keyTomorrowDatePrefix$districtId');
    if (imsak == null || imsak.isEmpty || date == null || date.isEmpty) return null;
    return (imsak: imsak, date: date);
  }

  Future<void> _savePrayers(int districtId, TodayPrayers prayers) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${_keyPrayersPrefix}${districtId}_${prayers.date}',
        jsonEncode(prayers.toJson()));
  }

  // MARK: - Coordinate fallback (Turkey only)

  String findNearestProvince(double lat, double lon) {
    String best = 'istanbul';
    double bestDist = double.infinity;

    for (final p in provinceCoordinates) {
      final d = (lat - p.lat) * (lat - p.lat) + (lon - p.lon) * (lon - p.lon);
      if (d < bestDist) {
        best = p.name;
        bestDist = d;
      }
    }
    return best;
  }

  static final List<ProvinceCoordinate> provinceCoordinates = [
    ProvinceCoordinate('adana', 37.0000, 35.3213),
    ProvinceCoordinate('adiyaman', 37.7648, 38.2786),
    ProvinceCoordinate('afyonkarahisar', 38.7507, 30.5567),
    ProvinceCoordinate('agri', 39.7191, 43.0503),
    ProvinceCoordinate('amasya', 40.6499, 35.8353),
    ProvinceCoordinate('ankara', 39.9334, 32.8597),
    ProvinceCoordinate('antalya', 36.8969, 30.7133),
    ProvinceCoordinate('artvin', 41.1828, 41.8183),
    ProvinceCoordinate('aydin', 37.8444, 27.8458),
    ProvinceCoordinate('balikesir', 39.6484, 27.8826),
    ProvinceCoordinate('bilecik', 40.1506, 29.9792),
    ProvinceCoordinate('bingol', 38.8854, 40.4983),
    ProvinceCoordinate('bitlis', 38.4006, 42.1095),
    ProvinceCoordinate('bolu', 40.7359, 31.6069),
    ProvinceCoordinate('burdur', 37.7200, 30.2900),
    ProvinceCoordinate('bursa', 40.1885, 29.0610),
    ProvinceCoordinate('canakkale', 40.1553, 26.4142),
    ProvinceCoordinate('cankiri', 40.6013, 33.6134),
    ProvinceCoordinate('corum', 40.5506, 34.9556),
    ProvinceCoordinate('denizli', 37.7765, 29.0864),
    ProvinceCoordinate('diyarbakir', 37.9144, 40.2306),
    ProvinceCoordinate('edirne', 41.6818, 26.5623),
    ProvinceCoordinate('elazig', 38.6748, 39.2225),
    ProvinceCoordinate('erzincan', 39.7500, 39.5000),
    ProvinceCoordinate('erzurum', 39.9043, 41.2679),
    ProvinceCoordinate('eskisehir', 39.7767, 30.5206),
    ProvinceCoordinate('gaziantep', 37.0662, 37.3833),
    ProvinceCoordinate('giresun', 40.9128, 38.3895),
    ProvinceCoordinate('gumushane', 40.4386, 39.5086),
    ProvinceCoordinate('hakkari', 37.5744, 43.7408),
    ProvinceCoordinate('hatay', 36.4018, 36.3498),
    ProvinceCoordinate('isparta', 37.7648, 30.5566),
    ProvinceCoordinate('mersin', 36.8000, 34.6333),
    ProvinceCoordinate('istanbul', 41.0082, 28.9784),
    ProvinceCoordinate('izmir', 38.4189, 27.1287),
    ProvinceCoordinate('kars', 40.6013, 43.0975),
    ProvinceCoordinate('kastamonu', 41.3887, 33.7827),
    ProvinceCoordinate('kayseri', 38.7225, 35.4875),
    ProvinceCoordinate('kirklareli', 41.7333, 27.2167),
    ProvinceCoordinate('kirsehir', 39.1425, 34.1709),
    ProvinceCoordinate('kocaeli', 40.8533, 29.8815),
    ProvinceCoordinate('konya', 37.8667, 32.4833),
    ProvinceCoordinate('kutahya', 39.4167, 29.9833),
    ProvinceCoordinate('malatya', 38.3552, 38.3095),
    ProvinceCoordinate('manisa', 38.6191, 27.4289),
    ProvinceCoordinate('kahramanmaras', 37.5858, 36.9371),
    ProvinceCoordinate('mardin', 37.3212, 40.7245),
    ProvinceCoordinate('mugla', 37.2153, 28.3636),
    ProvinceCoordinate('mus', 38.7462, 41.4942),
    ProvinceCoordinate('nevsehir', 38.6939, 34.6857),
    ProvinceCoordinate('nigde', 37.9667, 34.6833),
    ProvinceCoordinate('ordu', 40.9862, 37.8797),
    ProvinceCoordinate('rize', 41.0201, 40.5234),
    ProvinceCoordinate('sakarya', 40.6940, 30.4358),
    ProvinceCoordinate('samsun', 41.2867, 36.3300),
    ProvinceCoordinate('siirt', 37.9333, 41.9500),
    ProvinceCoordinate('sinop', 42.0231, 35.1531),
    ProvinceCoordinate('sivas', 39.7477, 37.0179),
    ProvinceCoordinate('tekirdag', 41.0000, 27.5167),
    ProvinceCoordinate('tokat', 40.3167, 36.5500),
    ProvinceCoordinate('trabzon', 41.0015, 39.7178),
    ProvinceCoordinate('tunceli', 39.1079, 39.5461),
    ProvinceCoordinate('sanliurfa', 37.1591, 38.7969),
    ProvinceCoordinate('usak', 38.6823, 29.4082),
    ProvinceCoordinate('van', 38.4891, 43.4089),
    ProvinceCoordinate('yozgat', 39.8181, 34.8147),
    ProvinceCoordinate('zonguldak', 41.4564, 31.7987),
    ProvinceCoordinate('aksaray', 38.3552, 34.0370),
    ProvinceCoordinate('bayburt', 40.2552, 40.2249),
    ProvinceCoordinate('karaman', 37.1759, 33.2287),
    ProvinceCoordinate('kirikkale', 39.8468, 33.5153),
    ProvinceCoordinate('batman', 37.8812, 41.1351),
    ProvinceCoordinate('sirnak', 37.5164, 42.4611),
    ProvinceCoordinate('bartin', 41.6344, 32.3375),
    ProvinceCoordinate('ardahan', 41.1105, 42.7022),
    ProvinceCoordinate('igdir', 39.9237, 44.0450),
    ProvinceCoordinate('yalova', 40.6500, 29.2667),
    ProvinceCoordinate('karabuk', 41.2061, 32.6204),
    ProvinceCoordinate('kilis', 36.7184, 37.1212),
    ProvinceCoordinate('osmaniye', 37.0742, 36.2464),
    ProvinceCoordinate('duzce', 40.8438, 31.1565),
  ];
}

class ProvinceCoordinate {
  final String name;
  final double lat;
  final double lon;
  const ProvinceCoordinate(this.name, this.lat, this.lon);
}
