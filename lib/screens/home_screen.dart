import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import '../viewmodels/prayer_time_viewmodel.dart';
import '../services/notification_service.dart';
import '../services/admob_service.dart';
import '../services/location_service.dart';
import '../services/prayer_counter_service.dart';
import '../constants/strings.dart';
import '../constants/colors.dart';
import '../widgets/islamic_background.dart';
import '../widgets/header_view.dart';
import '../widgets/location_row.dart';
import '../widgets/selection_prompt.dart';
import '../widgets/next_prayer_banner.dart';
import '../widgets/prayer_times_grid.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/banner_ad_container.dart';
import '../widgets/bottom_nav_bar.dart';
import 'settings_screen.dart';
import 'qibla_compass_screen.dart';
import 'city_district_picker_screen.dart';
import 'verse_of_day_screen.dart';
import 'important_days_screen.dart';
import 'mosque_finder_screen.dart';
import 'prayer_protections_screen.dart';
import 'zikirmatik_screen.dart';
import 'quran_screen.dart';
import 'religious_info_screen.dart';
import 'prayer_counter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastShownPromptTime; // prevents showing same prompt twice

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await NotificationService.shared.requestPermission();
    await _initAdMobWithATT();
  }

  Future<void> _initAdMobWithATT() async {
    bool personalized = false;
    try {
      // iOS 14+ ATT: check current status first
      final current = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (current == TrackingStatus.notDetermined) {
        // Small delay so the app UI is visible before the system dialog appears
        await Future.delayed(const Duration(milliseconds: 500));
        final status = await AppTrackingTransparency.requestTrackingAuthorization();
        personalized = status == TrackingStatus.authorized;
      } else {
        personalized = current == TrackingStatus.authorized;
      }
    } catch (_) {
      // ATT not available (Android or older iOS) — default to personalized
      personalized = true;
    }
    AdMobService.shared.initialize(personalized: personalized);
  }

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: const CityDistrictPickerScreen(),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: const SettingsScreen(),
      ),
    );
  }

  void _openMosqueFinder(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MosqueFinderScreen(language: language),
      ),
    );
  }

  void _openPrayerProtections(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerProtectionsScreen(language: language),
      ),
    );
  }

  void _openImportantDays(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImportantDaysScreen(language: language),
      ),
    );
  }

  void _openCompass() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QiblaCompassScreen(),
      ),
    );
  }

  void _openVerse(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerseOfDayScreen(language: language),
      ),
    );
  }

  void _openZikirmatik(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZikirmatikScreen(language: language),
      ),
    );
  }

  void _openQuran(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranScreen(language: language),
      ),
    );
  }

  void _openReligiousInfo(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReligiousInfoScreen(language: language),
      ),
    );
  }

  void _openPrayerCounter(String language) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerCounterScreen(language: language),
      ),
    );
  }

  void _showPrayerPromptDialog(
    PrayerTimeViewModel vm,
    ({String key, String nameTr, String nameEn, String time, DateTime date}) req,
  ) {
    final lang = vm.language;
    final prayerDisplay = lang == 'en' ? req.nameEn : lang == 'ar' ? req.nameTr : req.nameTr;

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) {
        final isDark = AppTheme.isDark(ctx);
        final dialogBg = isDark ? const Color(0xFF1A3350) : const Color(0xFFEEF7EE);
        final btnStyle = ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenAccent,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        );
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lang == 'en'
                      ? 'Prayer Time'
                      : lang == 'ar'
                          ? 'وقت الصلاة'
                          : 'Namaz Vakti',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lang == 'en'
                      ? 'Did you pray $prayerDisplay (${req.time})?'
                      : lang == 'ar'
                          ? 'هل صليت $prayerDisplay (${req.time})؟'
                          : '$prayerDisplay (${req.time}) namazını kıldınız mı?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, 'yes'),
                    style: btnStyle,
                    child: Text(lang == 'en' ? 'Yes' : lang == 'ar' ? 'نعم' : 'Evet'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, 'no'),
                    style: btnStyle,
                    child: Text(lang == 'en' ? 'No' : lang == 'ar' ? 'لا' : 'Hayır'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, 'later'),
                    style: btnStyle,
                    child: Text(
                      lang == 'en' ? "I'll answer later" : lang == 'ar' ? 'لاحقاً' : 'Sonra Cevap Vereceğim',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((answer) async {
      vm.clearPrayerPrompt();
      final svc = PrayerCounterService.shared;
      if (answer == 'yes') {
        await svc.setAnswer(req.key, req.date, done: true);
        await svc.clearPending();
      } else if (answer == 'no') {
        await svc.setAnswer(req.key, req.date, done: false);
        await svc.clearPending();
      } else if (answer == 'later') {
        await svc.setPending(req.key, req.date);
      }
      if (mounted) setState(() {}); // refresh pending indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<PrayerTimeViewModel>(
        builder: (context, vm, _) {
          // Show prayer prompt dialog when a new prayer time arrives
          final req = vm.prayerPromptRequest;
          if (req != null && req.time != _lastShownPromptTime) {
            _lastShownPromptTime = req.time;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showPrayerPromptDialog(vm, req);
            });
          }

          return Stack(
            children: [
              const IslamicBackground(),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header
                    HeaderView(language: vm.language),
                    // Offline banner
                    if (vm.isOffline)
                      Container(
                        width: double.infinity,
                        color: const Color.fromRGBO(180, 100, 0, 0.85),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              vm.language == 'tr'
                                  ? 'İnternet yok — önbellek gösteriliyor'
                                  : vm.language == 'ar'
                                      ? 'لا إنترنت — عرض من الذاكرة المخبئية'
                                      : 'No internet — showing cached data',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    // Location row
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: LocationRow(
                        language: vm.language,
                        locationAuthStatus: vm.locationAuthStatus,
                        isResolvingLocation: vm.isResolvingLocation,
                        locationLabel: vm.locationLabel,
                        onLocationTap: () => vm.enableLocationMode(),
                        onPickerTap: _openPicker,
                        onOpenSettings: () =>
                            LocationService.shared.openAppSettings(),
                      ),
                    ),
                    // Selection prompt
                    if (vm.selectedDistrict == null && !vm.isLoading)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: SelectionPrompt(
                          language: vm.language,
                          onSelectTap: _openPicker,
                        ),
                      ),
                    // Next prayer banner with progress bar
                    if (vm.nextPrayer() != null &&
                        vm.timeUntilNextPrayer() != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: NextPrayerBanner(
                          label: AppStrings.nextPrayer(vm.language),
                          name: vm.nextPrayer()!.name,
                          time: vm.nextPrayer()!.time,
                          icon: vm.nextPrayer()!.icon,
                          countdown: vm.timeUntilNextPrayer()!,
                          progress: vm.prayerProgress(),
                          language: vm.language,
                        ),
                      ),
                    // Prayer times grid — Expanded fills remaining space,
                    // RefreshIndicator wraps for pull-to-refresh.
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color.fromRGBO(255, 217, 102, 1),
                        onRefresh: () => vm.loadPrayerTimes(),
                        child: SingleChildScrollView(
                          // ClampingScrollPhysics prevents iOS rubber-band
                          // bounce while AlwaysScrollable enables pull-to-refresh.
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: ListenableBuilder(
                              listenable: vm.notificationManager,
                              builder: (context, _) {
                                return PrayerTimesGrid(
                                      todayPrayers: vm.todayPrayers,
                                      language: vm.language,
                                      isLoading: vm.isLoading,
                                      errorMessage: vm.errorMessage,
                                      hasSelectedDistrict:
                                          vm.selectedDistrict != null,
                                      notificationManager:
                                          vm.notificationManager,
                                      onRetry: () => vm.loadPrayerTimes(),
                                      pendingPrayerKey:
                                          PrayerCounterService.shared.pendingKey,
                                      onPromptTap: () {
                                        if (!mounted) return;
                                        // Case 1: viewmodel still has the request
                                        final req = vm.prayerPromptRequest;
                                        if (req != null) {
                                          _showPrayerPromptDialog(vm, req);
                                          return;
                                        }
                                        // Case 2: request was consumed but
                                        // pendingKey is still set in the service
                                        final svc = PrayerCounterService.shared;
                                        if (svc.pendingKey != null &&
                                            svc.pendingDate != null) {
                                          final p = vm.todayPrayers?.allTimes
                                              .where((t) {
                                            switch (svc.pendingKey) {
                                              case 'fajr':    return t.nameEn == 'Fajr';
                                              case 'dhuhr':   return t.nameEn == 'Dhuhr';
                                              case 'asr':     return t.nameEn == 'Asr';
                                              case 'maghrib': return t.nameEn == 'Maghrib';
                                              case 'isha':    return t.nameEn == 'Isha';
                                              default:        return false;
                                            }
                                          }).firstOrNull;
                                          if (p != null) {
                                            _showPrayerPromptDialog(vm, (
                                              key: svc.pendingKey!,
                                              nameTr: p.name,
                                              nameEn: p.nameEn,
                                              time: p.time,
                                              date: svc.pendingDate ?? DateTime.now(),
                                            ));
                                          }
                                        }
                                      },
                                    );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom navigation
                    Container(
                      color: AppTheme.navBg(context).withOpacity(0.97),
                      child: BottomNavBar(
                        language: vm.language,
                        onCompassTap: _openCompass,
                        onVerseTap: () => _openVerse(vm.language),
                        onMosqueFinderTap: () =>
                            _openMosqueFinder(vm.language),
                        onImportantDaysTap: () =>
                            _openImportantDays(vm.language),
                        onPrayerProtectionsTap: () =>
                            _openPrayerProtections(vm.language),
                        onSettingsTap: _openSettings,
                        onZikirmatikTap: () => _openZikirmatik(vm.language),
                        onQuranTap: () => _openQuran(vm.language),
                        onReligiousInfoTap: () =>
                            _openReligiousInfo(vm.language),
                        onPrayerCounterTap: () =>
                            _openPrayerCounter(vm.language),
                      ),
                    ),
                    // AdMob banner — kendi arka planıyla (AdMob beyaz/gri verir).
                    // iOS home indicator alanı reklamın üzerine transparan gelir,
                    // siyah boşluk oluşmaz.
                    const BannerAdContainer(),
                  ],
                ),
              ),
              // Loading overlay
              if (vm.isLoading) LoadingOverlay(language: vm.language),
            ],
          );
        },
      ),
    );
  }
}
