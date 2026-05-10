import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'viewmodels/prayer_time_viewmodel.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — iOS plist'ten (GoogleService-Info.plist) otomatik okur
  try {
    await Firebase.initializeApp();
    // Analytics instance'ı aktive et
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    debugPrint('Firebase initialized. App Instance ID: ${await FirebaseAnalytics.instance.appInstanceId}');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // iOS audio session: playback category — sesli modda ve sessiz modda çalışır.
  // Bu çağrı olmadan iOS soloAmbient defaultunu kullanır (sessiz switche göre değişir).
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  } catch (e) {
    debugPrint('AudioContext init failed: $e');
  }

  // Initialize date formatting for Turkish, English and Arabic locales
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('ar_SA', null);

  // Notification initialization
  try {
    await NotificationService.shared.initialize();
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }

  // Lock orientation to portrait globally; stats screens override this temporarily
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exceptionAsString()}');
    debugPrint('Stack: ${details.stack}');
  };

  runApp(const EzanVaktiApp());
}

class EzanVaktiApp extends StatelessWidget {
  const EzanVaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrayerTimeViewModel(),
      child: Consumer<PrayerTimeViewModel>(
        builder: (_, vm, __) => MaterialApp(
          title: 'Ezan Vakti',
          debugShowCheckedModeBanner: false,
          themeMode: vm.themeMode,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0A1628),
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF1B4332),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
