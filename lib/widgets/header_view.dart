import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';

class HeaderView extends StatelessWidget {
  final String language;

  const HeaderView({
    super.key,
    required this.language,
  });

  String _formattedDate() {
    final locale = language == 'tr' ? 'tr_TR' : language == 'ar' ? 'ar_SA' : 'en_US';
    final format = language == 'tr' ? 'd MMMM yyyy, EEEE' : 'EEEE, MMMM d';
    return DateFormat(format, locale).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language == 'tr' ? 'Ezan Vakitleri' : language == 'ar' ? 'أوقات الصلاة' : 'Prayer Times',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary(context),
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
