import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';

class PrayerRow extends StatelessWidget {
  final String name;
  final String time;
  final IconData icon;
  final bool isNext;
  final bool isLast;
  final bool isNotificationEnabled;
  final VoidCallback onBellTap;
  // Prayer counter prompt
  final bool showPrompt;
  final String? promptLabel;
  final VoidCallback? onPromptTap;

  const PrayerRow({
    super.key,
    required this.name,
    required this.time,
    required this.icon,
    required this.isNext,
    required this.isLast,
    required this.isNotificationEnabled,
    required this.onBellTap,
    this.showPrompt = false,
    this.promptLabel,
    this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontSize: 16,
      fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
      color: AppTheme.prayerNameFg(context, isNext: isNext),
    );

    final bell = GestureDetector(
      onTap: onBellTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          isNotificationEnabled ? AppIcons.bellOn : AppIcons.bellOff,
          size: 16,
          color: isNotificationEnabled
              ? AppColors.greenAccent
              : AppTheme.bellOffFg(context),
        ),
      ),
    );

    final timeWidget = SizedBox(
      width: 70,
      child: Text(
        time,
        maxLines: 1,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.prayerTimeFg(context, isNext: isNext),
          letterSpacing: 1.0,
        ),
      ),
    );

    return Container(
      color: AppTheme.prayerRowBg(context, isNext: isNext),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Prayer icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.iconBg(context, isNext: isNext),
                  ),
                  child: Icon(icon, size: 16,
                      color: AppTheme.iconFg(context, isNext: isNext)),
                ),
                const SizedBox(width: 14),

                if (showPrompt && promptLabel != null) ...[
                  // ── Prompt layout ──────────────────────────────────────────
                  // IntrinsicWidth → name takes EXACTLY its natural pixel width.
                  // Two equal Spacers → badge is equidistant from name-end and
                  // bell-start, i.e. truly centred between the two.
                  ConstrainedBox(
                    // Safety cap so very long names don't crowd the badge.
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: IntrinsicWidth(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: nameStyle,
                      ),
                    ),
                  ),
                  const Spacer(), // equal gap (A)
                  GestureDetector(
                    onTap: onPromptTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            AppColors.greenAccent.withValues(alpha: 0.15),
                        border: Border.all(
                            color: AppColors.greenAccent
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        promptLabel!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenAccent,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(), // equal gap (B)
                ] else
                  // ── Normal layout ──────────────────────────────────────────
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                  ),

                // Bell and time: always fixed on the right
                const SizedBox(width: 8),
                bell,
                const SizedBox(width: 8),
                timeWidget,
              ],
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Divider(height: 1, color: AppTheme.divider(context)),
            ),
        ],
      ),
    );
  }
}
