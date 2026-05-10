import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/strings.dart';
import '../models/today_prayers.dart';
import '../services/notification_service.dart';
import '../services/prayer_counter_service.dart';
import 'prayer_row.dart';

class PrayerTimesGrid extends StatelessWidget {
  final TodayPrayers? todayPrayers;
  final String language;
  final bool isLoading;
  final String? errorMessage;
  final bool hasSelectedDistrict;
  final NotificationService notificationManager;
  final VoidCallback onRetry;
  final String? pendingPrayerKey;
  final VoidCallback? onPromptTap;

  const PrayerTimesGrid({
    super.key,
    required this.todayPrayers,
    required this.language,
    required this.isLoading,
    required this.errorMessage,
    required this.hasSelectedDistrict,
    required this.notificationManager,
    required this.onRetry,
    this.pendingPrayerKey,
    this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    if (todayPrayers != null) {
      final entries = todayPrayers!.allTimes;
      final nextPrayerTime = todayPrayers!.nextPrayer()?.time;

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Prayer rows — isLast is always false because kaza row follows
            ...List.generate(entries.length, (i) {
              final entry = entries[i];
              final prayerNames = AppStrings.prayerNames(language);
              final displayName = prayerNames[i];
              final isNext = entry.time == nextPrayerTime;
              final prayerKey = _prayerKey(entry.name, entry.nameEn);

              final counterKey = _counterKey(entry.nameEn);
              final isPromptRow =
                  counterKey != null && counterKey == pendingPrayerKey;

              return PrayerRow(
                name: displayName,
                time: entry.time,
                icon: entry.icon,
                isNext: isNext,
                isLast: false, // kaza row is the last item
                isNotificationEnabled:
                    notificationManager.enabledPrayers.contains(prayerKey),
                onBellTap: () {
                  notificationManager.togglePrayer(prayerKey);
                  notificationManager.rescheduleIfNeeded(todayPrayers, language);
                },
                showPrompt: isPromptRow,
                promptLabel: isPromptRow
                    ? (language == 'en'
                        ? 'Prayed?'
                        : language == 'ar'
                            ? 'هل صليت؟'
                            : 'Namaz kılındı mı?')
                    : null,
                onPromptTap: isPromptRow ? onPromptTap : null,
              );
            }),
            // Kaza namazı row — inside the same card, no extra scroll needed
            _KazaInlineRow(language: language),
          ],
        ),
      );
    }

    if (!isLoading && hasSelectedDistrict) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(AppIcons.wifiOff, size: 36, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? AppStrings.couldNotLoad(language),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenButton,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text(AppStrings.retry(language)),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _prayerKey(String nameTR, String nameEn) {
    const map = {
      'İmsak': 'imsak', 'Güneş': 'gunes', 'Öğle': 'ogle',
      'İkindi': 'ikindi', 'Akşam': 'aksam', 'Yatsı': 'yatsi',
      'Fajr': 'imsak', 'Sunrise': 'gunes', 'Dhuhr': 'ogle',
      'Asr': 'ikindi', 'Maghrib': 'aksam', 'Isha': 'yatsi',
    };
    return map[nameTR] ?? map[nameEn] ?? nameTR.toLowerCase();
  }

  static String? _counterKey(String nameEn) {
    switch (nameEn) {
      case 'Fajr':    return 'fajr';
      case 'Dhuhr':   return 'dhuhr';
      case 'Asr':     return 'asr';
      case 'Maghrib': return 'maghrib';
      case 'Isha':    return 'isha';
      default:        return null;
    }
  }
}

// ── Kaza namazı inline row (inside the prayer card) ───────────────────────────

class _KazaInlineRow extends StatefulWidget {
  final String language;
  const _KazaInlineRow({required this.language});

  @override
  State<_KazaInlineRow> createState() => _KazaInlineRowState();
}

class _KazaInlineRowState extends State<_KazaInlineRow> {
  int _todayCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await PrayerCounterService.shared
        .getKazaCountForDay(DateTime.now());
    if (mounted) setState(() => _todayCount = count);
  }

  String _l(String tr, String en, String ar) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar;
    return tr;
  }

  Future<void> _showAddDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        final isDark = AppTheme.isDark(ctx);
        final dialogBg =
            isDark ? const Color(0xFF1A3350) : const Color(0xFFEEF7EE);
        return Dialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _l('Kaza Namazı Ekle', 'Add Qada Prayer',
                      'إضافة صلاة قضاء'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(ctx),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _l('Kaç vakit kaza namazı kıldınız?',
                      'How many qada prayers did you perform?',
                      'كم صلاة قضاء أديت؟'),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary(ctx),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(ctx),
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle:
                        TextStyle(color: AppTheme.textSecondary(ctx)),
                    filled: true,
                    fillColor: AppTheme.cardBg(ctx),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppTheme.divider(ctx)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppTheme.divider(ctx)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.greenAccent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          _l('İptal', 'Cancel', 'إلغاء'),
                          style: TextStyle(
                              color: AppTheme.textSecondary(ctx)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final n = int.tryParse(ctrl.text.trim());
                          if (n != null && n > 0) Navigator.pop(ctx, n);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenAccent,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          _l('Ekle', 'Add', 'إضافة'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      await PrayerCounterService.shared.addKaza(result, DateTime.now());
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;
    return GestureDetector(
      onTap: _showAddDialog,
      child: Container(
        color: AppTheme.prayerRowBg(context, isNext: false),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 70),
                child: Divider(
                    height: 1, color: AppTheme.divider(context)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.15),
                      ),
                      child: Icon(Icons.history_edu_rounded,
                          size: 18, color: accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _l('Kaza Namazı Ekle', 'Add Qada Prayer',
                            'إضافة صلاة قضاء'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    if (_todayCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: accent.withValues(alpha: 0.12),
                          border: Border.all(
                              color: accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          _l('Bugün: $_todayCount',
                              'Today: $_todayCount',
                              'اليوم: $_todayCount'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.add_circle_outline_rounded,
                        size: 20, color: accent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
