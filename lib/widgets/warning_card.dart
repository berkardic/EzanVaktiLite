import 'package:flutter/material.dart';
import '../constants/colors.dart';

class WarningCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isLoading;

  const WarningCard({
    super.key,
    required this.icon,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(color: AppTheme.textPrimary(context), strokeWidth: 2),
            )
          else
            Icon(icon, color: AppTheme.textPrimary(context), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
