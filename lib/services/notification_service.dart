import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/today_prayers.dart';
import '../constants/strings.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService shared = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool isAuthorized = false;
  Set<String> enabledPrayers = {'imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'};

  static const String _enabledKey = 'enabledPrayers';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Android 8+ (API 26+): notification channel'ı açıkça oluştur.
    // flutter_local_notifications bunu otomatik yapar ama explicit oluşturmak
    // daha güvenilir ve kullanıcının ayarlardan özelleştirmesini sağlar.
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'prayer_times',
        'Prayer Times',
        description: 'Prayer time notifications',
        importance: Importance.high,
        playSound: true,
      ),
    );

    await _loadEnabledPrayers();
    await checkStatus();
  }

  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      isAuthorized = granted ?? false;
      notifyListeners();
      return isAuthorized;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        sound: true,
      );
      isAuthorized = granted ?? false;
      notifyListeners();
      return isAuthorized;
    }

    return false;
  }

  Future<void> checkStatus() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      isAuthorized = enabled ?? false;
      notifyListeners();
      return;
    }

    isAuthorized = true;
    notifyListeners();
  }

  void schedulePrayerNotifications(TodayPrayers prayers, String language) {
    _plugin.cancelAll();

    final prayerTimes = [
      prayers.imsak, prayers.gunes, prayers.ogle,
      prayers.ikindi, prayers.aksam, prayers.yatsi,
    ];
    final namesTR = AppStrings.prayerNamesTR;
    final namesEN = AppStrings.prayerNamesEN;
    final namesAR = AppStrings.prayerNamesAR;
    final keys = AppStrings.prayerKeys;
    final emojis = AppStrings.prayerEmojis;

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < keys.length; i++) {
      if (!enabledPrayers.contains(keys[i])) continue;

      final parts = prayerTimes[i].split(':');
      if (parts.length < 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      final prayerName = language == 'tr' ? namesTR[i] : language == 'ar' ? namesAR[i] : namesEN[i];

      final androidDetails = AndroidNotificationDetails(
        'prayer_times',
        'Prayer Times',
        channelDescription: 'Prayer time notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = '${emojis[i]} $prayerName Vakti';
      final body = language == 'tr'
          ? '${prayers.cityName} için ${prayerName.toLowerCase()} vakti girdi. (${prayerTimes[i]})'
          : language == 'ar'
              ? 'حان وقت $prayerName في ${prayers.cityName}. (${prayerTimes[i]})'
              : '$prayerName time has come for ${prayers.cityName}. (${prayerTimes[i]})';

      // Her gün aynı saatte tekrarlayan bildirim
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Vakit bugün geçtiyse yarına planla
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      _plugin.zonedSchedule(
        i,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  void togglePrayer(String key) {
    if (enabledPrayers.contains(key)) {
      enabledPrayers.remove(key);
    } else {
      enabledPrayers.add(key);
    }
    _saveEnabledPrayers();
    notifyListeners();
  }

  void rescheduleIfNeeded(TodayPrayers? prayers, String language) {
    if (prayers == null) return;
    schedulePrayerNotifications(prayers, language);
  }

  Future<void> _saveEnabledPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_enabledKey, enabledPrayers.toList());
  }

  Future<void> _loadEnabledPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_enabledKey);
    if (saved != null) {
      enabledPrayers = saved.toSet();
    }
  }
}
