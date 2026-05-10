import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_badge_plus/app_badge_plus.dart';

class PrayerCounterService {
  PrayerCounterService._();
  static final shared = PrayerCounterService._();

  static const List<String> prayerKeys = [
    'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'
  ];

  // ── Storage keys ────────────────────────────────────────────────────────────

  String _key(String prayer, DateTime date) =>
      'namaz_${prayer}_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

  String _kazaKey(DateTime date) =>
      'namaz_kaza_${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

  // ── Install date ────────────────────────────────────────────────────────────

  Future<DateTime> installDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('prayer_counter_install_ts');
    if (ts != null) return DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    await prefs.setInt('prayer_counter_install_ts', now.millisecondsSinceEpoch);
    return now;
  }

  // ── Answer tracking ─────────────────────────────────────────────────────────

  /// Returns true = done, false = not done, null = never answered
  Future<bool?> getAnswer(String prayerKey, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final k = _key(prayerKey, date);
    if (!prefs.containsKey(k)) return null;
    return prefs.getBool(k);
  }

  Future<bool> hasAnswer(String prayerKey, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key(prayerKey, date));
  }

  Future<void> setAnswer(String prayerKey, DateTime date,
      {required bool done}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(prayerKey, date), done);
    if (done) _syncBadge();
  }

  // ── Pending (user chose "Later") ─────────────────────────────────────────────

  String? _pendingKey;
  DateTime? _pendingDate;

  String? get pendingKey => _pendingKey;
  DateTime? get pendingDate => _pendingDate;

  Future<void> loadPendingState() async {
    final prefs = await SharedPreferences.getInstance();
    _pendingKey = prefs.getString('namaz_pending_key');
    final ds = prefs.getString('namaz_pending_date');
    _pendingDate = ds != null ? DateTime.tryParse(ds) : null;
    _syncBadge();
  }

  Future<void> setPending(String key, DateTime date) async {
    _pendingKey = key;
    _pendingDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('namaz_pending_key', key);
    await prefs.setString('namaz_pending_date', date.toIso8601String());
    _syncBadge();
  }

  Future<void> clearPending() async {
    _pendingKey = null;
    _pendingDate = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('namaz_pending_key');
    await prefs.remove('namaz_pending_date');
    _syncBadge();
  }

  void _syncBadge() {
    try {
      if (_pendingKey != null) {
        AppBadgePlus.updateBadge(1);
      } else {
        AppBadgePlus.updateBadge(0);
      }
    } catch (_) {}
  }

  // ── Kaza namazı ─────────────────────────────────────────────────────────────

  /// Add performed kaza prayers for the given date.
  Future<void> addKaza(int count, DateTime date) async {
    if (count <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final k = _kazaKey(date);
    final existing = prefs.getInt(k) ?? 0;
    await prefs.setInt(k, existing + count);
  }

  /// How many kaza prayers were recorded for the given date.
  Future<int> getKazaCountForDay(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kazaKey(date)) ?? 0;
  }

  /// Total kaza prayers performed from install date to today.
  Future<int> totalKazaPerformed() async {
    final prefs = await SharedPreferences.getInstance();
    final install = await installDate();
    final from = DateTime(install.year, install.month, install.day);
    final toDay = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int total = 0;
    DateTime day = from;
    while (!day.isAfter(toDay)) {
      total += prefs.getInt(_kazaKey(day)) ?? 0;
      day = day.add(const Duration(days: 1));
    }
    return total;
  }

  /// 52 weeks of weekly kaza totals (index 0 = oldest, index 51 = current week).
  Future<List<double>> weeklyKazaSums() async {
    final prefs = await SharedPreferences.getInstance();
    final install = await installDate();
    final installDay = DateTime(install.year, install.month, install.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekMonday =
        today.subtract(Duration(days: today.weekday - 1));

    final sums = <double>[];
    for (int w = 51; w >= 0; w--) {
      final weekStart =
          currentWeekMonday.subtract(Duration(days: w * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final effectiveStart =
          weekStart.isBefore(installDay) ? installDay : weekStart;
      final effectiveEnd = weekEnd.isAfter(today) ? today : weekEnd;

      if (effectiveStart.isAfter(effectiveEnd)) {
        sums.add(0.0);
        continue;
      }

      int total = 0;
      DateTime day = effectiveStart;
      while (!day.isAfter(effectiveEnd)) {
        total += prefs.getInt(_kazaKey(day)) ?? 0;
        day = day.add(const Duration(days: 1));
      }
      sums.add(total.toDouble());
    }
    return sums;
  }

  // ── Missed prayer count ──────────────────────────────────────────────────────

  /// Total vakit namazı not confirmed as done, from install date to today.
  /// Includes both explicitly answered false and unanswered prayers.
  Future<int> missedPrayerCount() async {
    final prefs = await SharedPreferences.getInstance();
    final install = await installDate();
    final from = DateTime(install.year, install.month, install.day);
    final now = DateTime.now();
    final toDay = DateTime(now.year, now.month, now.day);
    int missed = 0;
    DateTime day = from;
    while (!day.isAfter(toDay)) {
      for (final p in prayerKeys) {
        if (prefs.getBool(_key(p, day)) != true) missed++;
      }
      day = day.add(const Duration(days: 1));
    }
    return missed;
  }

  // ── Rate calculations ────────────────────────────────────────────────────────

  /// Overall rate from install date to today [0.0–1.0]
  Future<double> overallRate({String? prayerKey}) async {
    final install = await installDate();
    final from = DateTime(install.year, install.month, install.day);
    return _rateFor(prayerKey: prayerKey, from: from, to: DateTime.now());
  }

  Future<double> currentMonthRate({String? prayerKey}) async {
    final now = DateTime.now();
    return _rateFor(
        prayerKey: prayerKey, from: DateTime(now.year, now.month, 1), to: now);
  }

  Future<double> currentYearRate({String? prayerKey}) async {
    final now = DateTime.now();
    return _rateFor(
        prayerKey: prayerKey, from: DateTime(now.year, 1, 1), to: now);
  }

  Future<double> _rateFor({
    String? prayerKey,
    required DateTime from,
    required DateTime to,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prayers = prayerKey != null ? [prayerKey] : prayerKeys;
    int done = 0, expected = 0;
    DateTime day = DateTime(from.year, from.month, from.day);
    final toDay = DateTime(to.year, to.month, to.day);
    while (!day.isAfter(toDay)) {
      for (final p in prayers) {
        expected++;
        if (prefs.getBool(_key(p, day)) == true) done++;
      }
      day = day.add(const Duration(days: 1));
    }
    return expected == 0 ? 0.0 : done / expected;
  }

  /// 52 weeks of weekly completion rates (index 0 = oldest, index 51 = current week)
  Future<List<double>> weeklyRates({String? prayerKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final install = await installDate();
    final installDay = DateTime(install.year, install.month, install.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekMonday = today.subtract(Duration(days: today.weekday - 1));
    final prayers = prayerKey != null ? [prayerKey] : prayerKeys;

    final rates = <double>[];
    for (int w = 51; w >= 0; w--) {
      final weekStart = currentWeekMonday.subtract(Duration(days: w * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final effectiveStart = weekStart.isBefore(installDay) ? installDay : weekStart;
      final effectiveEnd = weekEnd.isAfter(today) ? today : weekEnd;

      if (effectiveStart.isAfter(effectiveEnd)) {
        rates.add(0.0);
        continue;
      }

      int done = 0, expected = 0;
      DateTime day = effectiveStart;
      while (!day.isAfter(effectiveEnd)) {
        for (final p in prayers) {
          expected++;
          if (prefs.getBool(_key(p, day)) == true) done++;
        }
        day = day.add(const Duration(days: 1));
      }
      rates.add(expected == 0 ? 0.0 : done / expected);
    }
    return rates;
  }

  /// Last [days] days of daily completion rates (index 0 = oldest, index days-1 = today)
  Future<List<double>> dailyRates(int days, {String? prayerKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final install = await installDate();
    final installDay = DateTime(install.year, install.month, install.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final prayers = prayerKey != null ? [prayerKey] : prayerKeys;

    final rates = <double>[];
    for (int d = days - 1; d >= 0; d--) {
      final day = today.subtract(Duration(days: d));
      if (day.isBefore(installDay)) {
        rates.add(0.0);
        continue;
      }
      int done = 0, expected = 0;
      for (final p in prayers) {
        expected++;
        if (prefs.getBool(_key(p, day)) == true) done++;
      }
      rates.add(expected == 0 ? 0.0 : done / expected);
    }
    return rates;
  }

  /// Last [days] days of daily kaza totals (index 0 = oldest, index days-1 = today)
  Future<List<double>> dailyKazaSums(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final install = await installDate();
    final installDay = DateTime(install.year, install.month, install.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final sums = <double>[];
    for (int d = days - 1; d >= 0; d--) {
      final day = today.subtract(Duration(days: d));
      if (day.isBefore(installDay)) {
        sums.add(0.0);
        continue;
      }
      sums.add((prefs.getInt(_kazaKey(day)) ?? 0).toDouble());
    }
    return sums;
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys()
        .where((k) =>
            k.startsWith('namaz_') || k == 'prayer_counter_install_ts')
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    _pendingKey = null;
    _pendingDate = null;
    _syncBadge();
  }
}
