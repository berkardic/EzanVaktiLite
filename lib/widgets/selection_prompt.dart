import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/strings.dart';

class SelectionPrompt extends StatelessWidget {
  final String language;
  final VoidCallback onSelectTap;

  const SelectionPrompt({
    super.key,
    required this.language,
    required this.onSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.promptBg(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.locationPin,
            size: 44,
            color: AppColors.gold80,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.selectPrompt(language),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSelectTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenButton,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              AppStrings.selectLocation(language),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
