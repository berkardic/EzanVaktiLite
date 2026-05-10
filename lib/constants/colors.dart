import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background gradient
  static const bgTop = Color.fromRGBO(13, 31, 64, 1);
  static const bgMiddle = Color.fromRGBO(20, 46, 97, 1);
  static const bgBottom = Color.fromRGBO(31, 56, 77, 1);

  // Accent colors
  static const gold = Color.fromRGBO(255, 217, 102, 1);
  static const greenButton = Color.fromRGBO(46, 133, 87, 1);
  static const greenAccent = Color.fromRGBO(102, 204, 153, 1);

  // Surface colors
  static const settingsBg = Color.fromRGBO(15, 33, 69, 1);
  static const loadingBg = Color.fromRGBO(20, 38, 77, 1);

  // Opacity helpers
  static Color white8 = Colors.white.withOpacity(0.08);
  static Color white10 = Colors.white.withOpacity(0.10);
  static Color white15 = Colors.white.withOpacity(0.15);
  static Color white70 = Colors.white.withOpacity(0.70);
  static Color white85 = Colors.white.withOpacity(0.85);
  static Color gold20 = gold.withOpacity(0.2);
  static Color gold40 = gold.withOpacity(0.4);
  static Color gold80 = gold.withOpacity(0.8);

  static const backgroundGradient = LinearGradient(
    colors: [bgTop, bgMiddle, bgBottom],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme — seashell palette (#FFF5EE tabanlı)
  static const lightBgTop    = Color(0xFFFFEDE2); // biraz daha sıcak üst
  static const lightBgMiddle = Color(0xFFFFF5EE); // ana ton — seashell
  static const lightBgBottom = Color(0xFFFFFAF7); // neredeyse beyaz alt

  static const lightBackgroundGradient = LinearGradient(
    colors: [lightBgTop, lightBgMiddle, lightBgBottom],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static bool isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  // Açık tema için koyu sarı (seçili namaz vakti icon + saat)
  static const _darkGold = Color(0xFF8B6200); // koyu hardal sarısı

  // Text
  static Color textPrimary(BuildContext ctx) =>
      isDark(ctx) ? Colors.white : const Color(0xFF150800); // neredeyse siyah kahve

  static Color textSecondary(BuildContext ctx) =>
      isDark(ctx) ? const Color(0xFFB3B3B3) : const Color(0xFF4A2800); // koyu orta kahve

  // Cards / containers
  static Color cardBg(BuildContext ctx) => isDark(ctx)
      ? Colors.white.withOpacity(0.08)
      : const Color(0xFFE8C8A8).withOpacity(0.28);

  static Color divider(BuildContext ctx) => isDark(ctx)
      ? Colors.white.withOpacity(0.10)
      : const Color(0xFFB8900A).withOpacity(0.20);

  // Icons
  static Color iconBg(BuildContext ctx, {bool isNext = false}) {
    if (isNext) return const Color(0xFF8B6200).withOpacity(0.18);
    return isDark(ctx)
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFDCBE7A).withOpacity(0.5);
  }

  static Color iconFg(BuildContext ctx, {bool isNext = false}) {
    if (isNext) return isDark(ctx) ? AppColors.gold : _darkGold;
    return isDark(ctx) ? Colors.white.withOpacity(0.70) : const Color(0xFF4A2800);
  }

  // Prayer row
  static Color prayerNameFg(BuildContext ctx, {bool isNext = false}) {
    if (isDark(ctx)) return isNext ? Colors.white : Colors.white.withOpacity(0.85);
    return const Color(0xFF150800); // her ikisi de çok koyu
  }

  static Color prayerTimeFg(BuildContext ctx, {bool isNext = false}) {
    if (isNext) return isDark(ctx) ? AppColors.gold : _darkGold;
    return isDark(ctx) ? Colors.white : const Color(0xFF1E5C30); // koyu yeşil
  }

  static Color prayerRowBg(BuildContext ctx, {bool isNext = false}) {
    if (!isNext) return Colors.transparent;
    return isDark(ctx)
        ? AppColors.gold.withOpacity(0.08)
        : const Color(0xFFD4A820).withOpacity(0.18);
  }

  static Color bellOffFg(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.30) : const Color(0xFF7A5200);

  // Next prayer banner
  static Color bannerBg(BuildContext ctx) => isDark(ctx)
      ? Colors.white.withOpacity(0.12)
      : const Color(0xFFC9A030).withOpacity(0.55);

  static Color bannerBorder(BuildContext ctx) => isDark(ctx)
      ? AppColors.gold.withOpacity(0.40)
      : const Color(0xFF8B6200);

  static Color bannerSecondaryText(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.70) : const Color(0xFF3D2000);

  // Location row picker button
  static Color pickerBg(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.15) : const Color(0xFFDCBE7A).withOpacity(0.6);

  static Color pickerText(BuildContext ctx) =>
      isDark(ctx) ? Colors.white : const Color(0xFF150800);

  static Color pickerSecondary(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.70) : const Color(0xFF4A2800);

  // Bottom nav
  static Color navBg(BuildContext ctx) =>
      isDark(ctx) ? const Color(0xFF0A1628) : const Color(0xFF1A0D00);

  // Modal sheets background
  static Color sheetBg(BuildContext ctx) =>
      isDark(ctx) ? AppColors.settingsBg : const Color(0xFFFFF5EE);

  // Sheet text & items
  static Color sheetItemBg(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.08) : const Color(0xFFDCBE7A).withOpacity(0.40);

  static Color sheetDivider(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.10) : const Color(0xFFB8900A).withOpacity(0.35);

  static Color sheetSecondary(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.60) : const Color(0xFF4A2800);

  // Selection prompt card bg
  static Color promptBg(BuildContext ctx) =>
      isDark(ctx) ? Colors.white.withOpacity(0.08) : const Color(0xFFDCBE7A).withOpacity(0.40);

  // Accent / action color (gold in dark, dark gold in light)
  static Color accentColor(BuildContext ctx) => isDark(ctx) ? AppColors.gold : _darkGold;

  // Background gradient
  static LinearGradient backgroundGradient(BuildContext ctx) =>
      isDark(ctx) ? AppColors.backgroundGradient : AppColors.lightBackgroundGradient;
}
