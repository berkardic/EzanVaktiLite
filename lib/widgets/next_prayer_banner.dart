import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';

class NextPrayerBanner extends StatelessWidget {
  final String label;
  final String name;
  final String time;
  final IconData icon;
  final String countdown;
  final double progress;
  final String language;

  const NextPrayerBanner({
    super.key,
    required this.label,
    required this.name,
    required this.time,
    required this.icon,
    required this.countdown,
    required this.progress,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final accent = AppTheme.accentColor(context);
    final barBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bannerBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bannerBorder(context), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Content row ──────────────────────────────────
            Stack(
              children: [
                // Mosque silhouette — starts after icon (left≈80), fills to right
                Positioned(
                  left: 80,   // icon(52) + gap(12) + padding(16)
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/mosque.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.12),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.iconBg(context, isNext: true),
                        ),
                        child: Icon(icon,
                            color: AppTheme.iconFg(context, isNext: true),
                            size: 26),
                      ),
                      const SizedBox(width: 12),
                      // Name & label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppTheme.bannerSecondaryText(context))),
                            const SizedBox(height: 3),
                            Text(name,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary(context))),
                          ],
                        ),
                      ),
                      // Time + "Kalan süre: XX"
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(time,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.prayerTimeFg(context,
                                      isNext: true))),
                          const SizedBox(height: 3),
                          Text(
                            '${AppStrings.remaining(language)} $countdown',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.bannerSecondaryText(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ── Progress bar ─────────────────────────────────
            Stack(
              children: [
                Container(height: 4, color: barBg),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.6),
                          accent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

