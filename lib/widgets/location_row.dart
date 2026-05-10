import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/strings.dart';

class LocationRow extends StatelessWidget {
  final String language;
  final String locationAuthStatus;
  final bool isResolvingLocation;
  final String locationLabel;
  final VoidCallback onLocationTap;
  final VoidCallback onPickerTap;
  final VoidCallback onOpenSettings;

  const LocationRow({
    super.key,
    required this.language,
    required this.locationAuthStatus,
    required this.isResolvingLocation,
    required this.locationLabel,
    required this.onLocationTap,
    required this.onPickerTap,
    required this.onOpenSettings,
  });

  Color _locationBg(BuildContext context) {
    if (locationAuthStatus == 'denied') return Colors.red.withOpacity(0.7);
    if (locationAuthStatus == 'authorized' && !isResolvingLocation) {
      return AppColors.greenButton;
    }
    return AppTheme.pickerBg(context);
  }

  IconData get _locationIcon {
    if (locationAuthStatus == 'denied') return AppIcons.locationDenied;
    if (locationAuthStatus == 'authorized') return AppIcons.locationAuthorized;
    return AppIcons.locationSearching;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Location button
          GestureDetector(
            onTap: () {
              if (locationAuthStatus == 'denied') {
                _showDeniedDialog(context);
              } else {
                onLocationTap();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _locationBg(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isResolvingLocation)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(_locationIcon, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.location(language),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // City/District picker button
          GestureDetector(
            onTap: onPickerTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.pickerBg(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.locationPinFilled,
                    size: 14,
                    color: AppTheme.accentColor(context),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.45,
                    ),
                    child: Text(
                      locationLabel,
                      style: TextStyle(
                        color: AppTheme.pickerText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    AppIcons.dropDown,
                    size: 14,
                    color: AppTheme.pickerSecondary(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.locationPermRequired(language)),
        content: Text(AppStrings.locationDeniedMsg(language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel(language)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onOpenSettings();
            },
            child: Text(AppStrings.openSettings(language)),
          ),
        ],
      ),
    );
  }
}
