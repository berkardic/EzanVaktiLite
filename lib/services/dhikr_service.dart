import 'package:shared_preferences/shared_preferences.dart';

class DhikrService {
  DhikrService._();
  static final shared = DhikrService._();

  // Raw tap count key (total taps regardless of rounds)
  String _tapKey(String dhikrKey, DateTime date) =>
      'dhikr_${dhikrKey}_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

  // Increment by 1 tap
  Future<void> increment(String dhikrKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _tapKey(dhikrKey, DateTime.now());
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  // Reset today's raw tap count to 0
  Future<void> resetToday(String dhikrKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tapKey(dhikrKey, DateTime.now()), 0);
  }

  // Reset ALL dhikr counts for today
  Future<void> resetAllToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final suffix =
        '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
    final keys = prefs.getKeys()
        .where((k) => k.startsWith('dhikr_') && k.endsWith('_$suffix'))
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  // Total raw taps today
  Future<int> todayTaps(String dhikrKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tapKey(dhikrKey, DateTime.now())) ?? 0;
  }

  // Completed rounds today (every 99 taps = 1 round)
  Future<int> todayRounds(String dhikrKey) async {
    return (await todayTaps(dhikrKey)) ~/ 99;
  }

  // Current position within the active round (0–98)
  Future<int> currentInRound(String dhikrKey) async {
    return (await todayTaps(dhikrKey)) % 99;
  }

  // Last 30 days — returns completed rounds per day
  Future<List<int>> last30Days(String dhikrKey) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      final taps = prefs.getInt(_tapKey(dhikrKey, date)) ?? 0;
      return taps ~/ 99;
    });
  }
}
