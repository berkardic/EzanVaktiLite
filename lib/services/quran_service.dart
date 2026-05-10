import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_verse.dart';

class QuranService {
  static final QuranService shared = QuranService._();
  QuranService._();

  final _dio = Dio(BaseOptions(
    baseUrl: 'https://api.alquran.cloud/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static const _cacheKey = 'cache_quran_verse_v5_';

  // Günün ayetini belirle.
  // Sabit bir epoch (2024-01-01) üzerinden gün sayısını alıp 17 (6236 ile
  // aralarında asal) ile çarpıyoruz. Bu sayede her gün Kur'an'ın tamamen
  // farklı bir bölümünden ayet gösterilir; aynı sure art arda gelmez.
  int get _todayVerseNumber {
    final now = DateTime.now();
    final epoch = DateTime(2024, 1, 1);
    final daysSinceEpoch = now.difference(epoch).inDays;
    return (daysSinceEpoch * 17) % 6236 + 1;
  }

  Future<QuranVerse> fetchVerseOfDay() async {
    final verseNum = _todayVerseNumber;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cacheKey = '$_cacheKey${today}_$verseNum';

    // Önce cache'e bak
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw != null) {
      return QuranVerse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }

    final response = await _dio.get(
      '/ayah/$verseNum/editions/quran-uthmani,tr.diyanet,en.asad',
    );

    final data = response.data['data'] as List;
    final verse = QuranVerse.fromApiResponse(data, verseNum);

    prefs.setString(cacheKey, jsonEncode(verse.toJson()));
    return verse;
  }
}
