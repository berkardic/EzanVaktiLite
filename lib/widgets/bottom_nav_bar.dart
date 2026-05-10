import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onCompassTap;
  final VoidCallback onVerseTap;
  final VoidCallback onImportantDaysTap;
  final VoidCallback onMosqueFinderTap;
  final VoidCallback onPrayerProtectionsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onZikirmatikTap;
  final VoidCallback onQuranTap;
  final VoidCallback onReligiousInfoTap;
  final VoidCallback onPrayerCounterTap;
  final String language;

  const BottomNavBar({
    super.key,
    required this.onCompassTap,
    required this.onVerseTap,
    required this.onImportantDaysTap,
    required this.onMosqueFinderTap,
    required this.onPrayerProtectionsTap,
    required this.onSettingsTap,
    required this.onZikirmatikTap,
    required this.onQuranTap,
    required this.onReligiousInfoTap,
    required this.onPrayerCounterTap,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.explore_rounded,
            label: language == 'tr' ? 'Kıble' : language == 'ar' ? 'القبلة' : 'Qibla',
            onTap: onCompassTap,
          ),
          _NavItem(
            icon: Icons.how_to_reg_rounded,
            label: language == 'tr' ? 'Namaz' : language == 'ar' ? 'الصلاة' : 'Prayers',
            onTap: onPrayerCounterTap,
          ),
          _NavItem(
            icon: Icons.radio_button_checked_rounded,
            label: language == 'tr' ? 'Zikir' : language == 'ar' ? 'الذكر' : 'Dhikr',
            onTap: onZikirmatikTap,
          ),
          _NavItem(
            icon: Icons.mosque_rounded,
            label: language == 'tr' ? 'Camiler' : language == 'ar' ? 'مساجد' : 'Mosques',
            onTap: onMosqueFinderTap,
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: language == 'tr' ? 'Ayarlar' : language == 'ar' ? 'الإعدادات' : 'Settings',
            onTap: onSettingsTap,
          ),
          _MoreNavItem(
            language: language,
            onImportantDaysTap: onImportantDaysTap,
            onPrayerProtectionsTap: onPrayerProtectionsTap,
            onQuranTap: onQuranTap,
            onReligiousInfoTap: onReligiousInfoTap,
            onVerseTap: onVerseTap,
          ),
        ],
      ),
    );
  }
}

// ── Standard nav item ──────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greenAccent.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: AppColors.greenAccent, size: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.greenAccent,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── "Diğer" nav item — shows popup menu above itself ──────────────────────

class _MoreNavItem extends StatelessWidget {
  final String language;
  final VoidCallback onImportantDaysTap;
  final VoidCallback onPrayerProtectionsTap;
  final VoidCallback onQuranTap;
  final VoidCallback onReligiousInfoTap;
  final VoidCallback onVerseTap;

  const _MoreNavItem({
    required this.language,
    required this.onImportantDaysTap,
    required this.onPrayerProtectionsTap,
    required this.onQuranTap,
    required this.onReligiousInfoTap,
    required this.onVerseTap,
  });

  String get _label =>
      language == 'tr' ? 'Diğer' : language == 'ar' ? 'المزيد' : 'More';

  void _showPopup(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final menuBg = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFFFF5EE);
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final box = context.findRenderObject() as RenderBox;
    final screenSize = MediaQuery.of(context).size;
    final pos = box.localToGlobal(Offset.zero);
    final menuRight = screenSize.width - (pos.dx + box.size.width);
    final menuBottom = screenSize.height - pos.dy + 8;

    final items = [
      (
        icon: Icons.shield_moon_rounded,
        label: language == 'tr'
            ? 'Nazar Duası'
            : language == 'ar'
                ? 'دعاء الحماية'
                : 'Protection Prayer',
        action: onPrayerProtectionsTap,
      ),
      (
        icon: Icons.format_quote_rounded,
        label: language == 'tr'
            ? 'Günün Ayeti'
            : language == 'ar'
                ? 'آية اليوم'
                : 'Verse of Day',
        action: onVerseTap,
      ),
      (
        icon: Icons.auto_awesome_rounded,
        label: language == 'tr'
            ? 'Önemli Günler'
            : language == 'ar'
                ? 'مناسبات إسلامية'
                : 'Islamic Days',
        action: onImportantDaysTap,
      ),
      (
        icon: Icons.menu_book_rounded,
        label: language == 'tr'
            ? "Kur'an-ı Kerim"
            : language == 'ar'
                ? 'القرآن الكريم'
                : 'Holy Quran',
        action: onQuranTap,
      ),
      (
        icon: Icons.lightbulb_outline_rounded,
        label: language == 'tr'
            ? 'Dini Bilgiler'
            : language == 'ar'
                ? 'المعلومات الدينية'
                : 'Islamic Knowledge',
        action: onReligiousInfoTap,
      ),
    ];

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, _, __) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                right: menuRight,
                bottom: menuBottom,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 200),
                  decoration: BoxDecoration(
                    color: menuBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              items[i].action();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(items[i].icon,
                                      color: AppColors.greenAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    items[i].label,
                                    style: TextStyle(
                                      color: AppColors.greenAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (i < items.length - 1)
                            Divider(height: 1, color: divColor),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.greenAccent.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.more_horiz_rounded,
                  color: AppColors.greenAccent, size: 18),
            ),
            const SizedBox(height: 2),
            Text(
              _label,
              style: TextStyle(
                color: AppColors.greenAccent,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
