import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PrayerCountdownCard extends StatelessWidget {
  final String prayerName;
  final IconData icon;
  final String countdown;
  final double progress; // 0.0 – 1.0
  final String language;

  const PrayerCountdownCard({
    super.key,
    required this.prayerName,
    required this.icon,
    required this.countdown,
    required this.progress,
    required this.language,
  });

  String _label() {
    if (language == 'ar') return '$prayerName: الوقت المتبقي';
    if (language == 'en') return '$prayerName Remaining:';
    // Turkish dative suffix (vowel harmony)
    final suffixes = {
      'İmsak': "İmsak'a Kalan Süre:",
      'Güneş': "Güneş'e Kalan Süre:",
      'Öğle': "Öğle'ye Kalan Süre:",
      'İkindi': "İkindi'ye Kalan Süre:",
      'Akşam': "Akşam'a Kalan Süre:",
      'Yatsı': "Yatsı'ya Kalan Süre:",
    };
    return suffixes[prayerName] ?? '$prayerName Kalan Süre:';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final accent = AppTheme.accentColor(context);

    final bgColor = isDark
        ? const Color(0xFF0D1B35)
        : const Color(0xFFEAD5B8);

    final barBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.bannerBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.iconBg(context, isNext: true),
                  ),
                  child: Icon(icon,
                      color: AppTheme.iconFg(context, isNext: true), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _label(),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  countdown,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          // Progress bar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Stack(
              children: [
                // Background track
                Container(height: 4, color: barBg),
                // Filled portion
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.7),
                          accent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
