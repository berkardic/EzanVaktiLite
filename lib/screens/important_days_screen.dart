import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/banner_ad_container.dart';

enum _DayType { kandil, bayram, onemli }

class _IslamicDay {
  final DateTime date;
  final int durationDays;
  final String nameTr;
  final String nameEn;
  final String nameAr;
  final String descTr;
  final String descEn;
  final String descAr;
  final _DayType type;

  const _IslamicDay({
    required this.date,
    this.durationDays = 1,
    required this.nameTr,
    required this.nameEn,
    required this.nameAr,
    required this.descTr,
    required this.descEn,
    required this.descAr,
    required this.type,
  });

  DateTime get endDate => date.add(Duration(days: durationDays - 1));
}

// ---------------------------------------------------------------------------
// İslami önemli günler — Diyanet İşleri Başkanlığı takvimine göre (yaklaşık)
// Hicrî takvim ay görüşüne göre 1-2 gün değişebilir.
// ---------------------------------------------------------------------------
final List<_IslamicDay> _days = [
  // 2025 — 1446 Hicri
  _IslamicDay(
    date: DateTime(2025, 1, 2),
    nameTr: 'Regaib Kandili',
    nameEn: 'Night of Raghaib',
    nameAr: 'ليلة الرغائب',
    descTr: 'Recep ayının ilk Perşembe gecesi',
    descEn: 'First Thursday night of Rajab',
    descAr: 'ليلة أول خميس من شهر رجب',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2025, 1, 27),
    nameTr: 'Miraç Kandili',
    nameEn: "Mi'raj Night",
    nameAr: 'ليلة المعراج',
    descTr: "Hz. Muhammed'in miraca çıkışının yıl dönümü",
    descEn: "Anniversary of the Prophet's Ascension",
    descAr: 'ذكرى معراج النبي محمد ﷺ',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2025, 2, 13),
    nameTr: 'Berat Kandili',
    nameEn: 'Night of Forgiveness',
    nameAr: 'ليلة البراءة',
    descTr: "Şabanın 15. gecesi, günahların bağışlandığı gece",
    descEn: "Night of 15th Sha'ban, night of forgiveness",
    descAr: 'ليلة النصف من شعبان، ليلة المغفرة',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2025, 3, 1),
    nameTr: 'Ramazan Başlangıcı',
    nameEn: 'Ramadan Start',
    nameAr: 'بداية رمضان',
    descTr: 'Oruç ve bereketin mübarek ayı başlıyor',
    descEn: 'The blessed month of fasting begins',
    descAr: 'بداية الشهر الكريم شهر الصيام',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2025, 3, 27),
    nameTr: 'Kadir Gecesi',
    nameEn: 'Night of Power',
    nameAr: 'ليلة القدر',
    descTr: "Bin aydan hayırlı, Kur'an'ın indirildiği mübarek gece",
    descEn: 'Better than a thousand months; the night Quran was revealed',
    descAr: 'خير من ألف شهر، ليلة نزول القرآن الكريم',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2025, 3, 30),
    durationDays: 3,
    nameTr: 'Ramazan Bayramı',
    nameEn: 'Eid al-Fitr',
    nameAr: 'عيد الفطر',
    descTr: 'Ramazan orucunun ardından üç günlük mübarek bayram',
    descEn: 'Three-day celebration marking the end of Ramadan',
    descAr: 'احتفال ثلاثة أيام بانتهاء رمضان المبارك',
    type: _DayType.bayram,
  ),
  _IslamicDay(
    date: DateTime(2025, 6, 5),
    nameTr: 'Kurban Bayramı Arefesi',
    nameEn: 'Day of Arafah',
    nameAr: 'يوم عرفة',
    descTr: 'Hacıların Arafat dağında toplandığı, duaların kabul olduğu gün',
    descEn: "Pilgrims gather at Mount Arafah; a day of forgiveness",
    descAr: 'يجتمع الحجاج في جبل عرفات، يوم المغفرة والدعاء',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2025, 6, 6),
    durationDays: 4,
    nameTr: 'Kurban Bayramı',
    nameEn: 'Eid al-Adha',
    nameAr: 'عيد الأضحى',
    descTr: "Hz. İbrahim'in sünnetini yaşatan dört günlük büyük bayram",
    descEn: "Four-day celebration commemorating Prophet Ibrahim's sacrifice",
    descAr: 'احتفال أربعة أيام ذكرى تضحية سيدنا إبراهيم عليه السلام',
    type: _DayType.bayram,
  ),
  _IslamicDay(
    date: DateTime(2025, 6, 27),
    nameTr: 'Hicrî Yılbaşı 1447',
    nameEn: 'Islamic New Year 1447',
    nameAr: 'رأس السنة الهجرية 1447',
    descTr: "Hz. Muhammed'in Mekke'den Medine'ye hicreti anısına",
    descEn: "Commemorating the Prophet's migration from Mecca to Medina",
    descAr: 'ذكرى هجرة النبي ﷺ من مكة المكرمة إلى المدينة المنورة',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2025, 7, 6),
    nameTr: 'Aşure Günü',
    nameEn: 'Day of Ashura',
    nameAr: 'يوم عاشوراء',
    descTr: "Muharremin 10. günü; Hz. Nuh'un gemisinin karaya oturduğu gün",
    descEn: "10th of Muharram; a day of historical significance",
    descAr: 'اليوم العاشر من شهر محرم، يوم تاريخي عظيم',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2025, 9, 4),
    nameTr: 'Mevlid Kandili',
    nameEn: "Prophet's Birthday",
    nameAr: 'المولد النبوي الشريف',
    descTr: "Hz. Muhammed'in doğumunun yıl dönümü",
    descEn: "Anniversary of the birth of Prophet Muhammad",
    descAr: 'ذكرى ميلاد سيدنا محمد ﷺ',
    type: _DayType.kandil,
  ),
  // 2025–2026 geçişi — 1447 Hicri
  _IslamicDay(
    date: DateTime(2025, 12, 25),
    nameTr: 'Regaib Kandili',
    nameEn: 'Night of Raghaib',
    nameAr: 'ليلة الرغائب',
    descTr: 'Recep ayının ilk Perşembe gecesi',
    descEn: 'First Thursday night of Rajab',
    descAr: 'ليلة أول خميس من شهر رجب',
    type: _DayType.kandil,
  ),
  // 2026 — 1447 Hicri
  _IslamicDay(
    date: DateTime(2026, 1, 16),
    nameTr: 'Miraç Kandili',
    nameEn: "Mi'raj Night",
    nameAr: 'ليلة المعراج',
    descTr: "Hz. Muhammed'in miraca çıkışının yıl dönümü",
    descEn: "Anniversary of the Prophet's Ascension",
    descAr: 'ذكرى معراج النبي محمد ﷺ',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2026, 2, 3),
    nameTr: 'Berat Kandili',
    nameEn: 'Night of Forgiveness',
    nameAr: 'ليلة البراءة',
    descTr: "Şabanın 15. gecesi, günahların bağışlandığı gece",
    descEn: "Night of 15th Sha'ban, night of forgiveness",
    descAr: 'ليلة النصف من شعبان، ليلة المغفرة',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2026, 2, 18),
    nameTr: 'Ramazan Başlangıcı',
    nameEn: 'Ramadan Start',
    nameAr: 'بداية رمضان',
    descTr: 'Oruç ve bereketin mübarek ayı başlıyor',
    descEn: 'The blessed month of fasting begins',
    descAr: 'بداية الشهر الكريم شهر الصيام',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2026, 3, 16),
    nameTr: 'Kadir Gecesi',
    nameEn: 'Night of Power',
    nameAr: 'ليلة القدر',
    descTr: "Bin aydan hayırlı, Kur'an'ın indirildiği mübarek gece",
    descEn: 'Better than a thousand months; the night Quran was revealed',
    descAr: 'خير من ألف شهر، ليلة نزول القرآن الكريم',
    type: _DayType.kandil,
  ),
  _IslamicDay(
    date: DateTime(2026, 3, 20),
    durationDays: 3,
    nameTr: 'Ramazan Bayramı',
    nameEn: 'Eid al-Fitr',
    nameAr: 'عيد الفطر',
    descTr: 'Ramazan orucunun ardından üç günlük mübarek bayram',
    descEn: 'Three-day celebration marking the end of Ramadan',
    descAr: 'احتفال ثلاثة أيام بانتهاء رمضان المبارك',
    type: _DayType.bayram,
  ),
  _IslamicDay(
    date: DateTime(2026, 5, 25),
    nameTr: 'Kurban Bayramı Arefesi',
    nameEn: 'Day of Arafah',
    nameAr: 'يوم عرفة',
    descTr: 'Hacıların Arafat dağında toplandığı, duaların kabul olduğu gün',
    descEn: "Pilgrims gather at Mount Arafah; a day of forgiveness",
    descAr: 'يجتمع الحجاج في جبل عرفات، يوم المغفرة والدعاء',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2026, 5, 26),
    durationDays: 4,
    nameTr: 'Kurban Bayramı',
    nameEn: 'Eid al-Adha',
    nameAr: 'عيد الأضحى',
    descTr: "Hz. İbrahim'in sünnetini yaşatan dört günlük büyük bayram",
    descEn: "Four-day celebration commemorating Prophet Ibrahim's sacrifice",
    descAr: 'احتفال أربعة أيام ذكرى تضحية سيدنا إبراهيم عليه السلام',
    type: _DayType.bayram,
  ),
  _IslamicDay(
    date: DateTime(2026, 6, 16),
    nameTr: 'Hicrî Yılbaşı 1448',
    nameEn: 'Islamic New Year 1448',
    nameAr: 'رأس السنة الهجرية 1448',
    descTr: "Hz. Muhammed'in Mekke'den Medine'ye hicreti anısına",
    descEn: "Commemorating the Prophet's migration from Mecca to Medina",
    descAr: 'ذكرى هجرة النبي ﷺ من مكة المكرمة إلى المدينة المنورة',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2026, 6, 25),
    nameTr: 'Aşure Günü',
    nameEn: 'Day of Ashura',
    nameAr: 'يوم عاشوراء',
    descTr: "Muharremin 10. günü; Hz. Nuh'un gemisinin karaya oturduğu gün",
    descEn: "10th of Muharram; a day of historical significance",
    descAr: 'اليوم العاشر من شهر محرم، يوم تاريخي عظيم',
    type: _DayType.onemli,
  ),
  _IslamicDay(
    date: DateTime(2026, 8, 25),
    nameTr: 'Mevlid Kandili',
    nameEn: "Prophet's Birthday",
    nameAr: 'المولد النبوي الشريف',
    descTr: "Hz. Muhammed'in doğumunun yıl dönümü",
    descEn: "Anniversary of the birth of Prophet Muhammad",
    descAr: 'ذكرى ميلاد سيدنا محمد ﷺ',
    type: _DayType.kandil,
  ),
];

// ---------------------------------------------------------------------------

class ImportantDaysScreen extends StatelessWidget {
  final String language;
  const ImportantDaysScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Sadece bu yılın günleri
    final currentYearDays = _days.where((d) => d.date.year == today.year).toList();

    // Bir sonraki yaklaşan etkinlik (bu yıl içinden)
    final _IslamicDay? upcoming = currentYearDays.cast<_IslamicDay?>().firstWhere(
      (d) => d != null && !d.endDate.isBefore(todayDate),
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(context),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textPrimary(context), size: 22),
                ),
                Expanded(
                  child: Text(
                    language == 'tr'
                        ? 'Önemli İslami Günler'
                        : language == 'ar'
                            ? 'المناسبات الإسلامية'
                            : 'Important Islamic Days',
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Yaklaşan etkinlik kartı
          if (upcoming != null)
            _UpcomingCard(day: upcoming, today: todayDate, language: language),

          const SizedBox(height: 4),

          // Not
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              language == 'tr'
                  ? '* Hicrî takvim ay görüşüne göre 1-2 gün değişebilir.'
                  : language == 'ar'
                      ? '* قد تتغير التواريخ يومًا أو يومين وفق رؤية الهلال.'
                      : '* Dates may shift ±1-2 days based on moon sighting.',
              style: TextStyle(
                color: AppTheme.textSecondary(context).withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),

          // Liste
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: currentYearDays.length,
              itemBuilder: (context, i) {
                final day = currentYearDays[i];
                final isPast = day.endDate.isBefore(todayDate);
                final isToday = !day.date.isAfter(todayDate) &&
                    !day.endDate.isBefore(todayDate);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DayTile(
                      day: day,
                      today: todayDate,
                      isPast: isPast,
                      isToday: isToday,
                      language: language,
                    ),
                  ],
                );
              },
            ),
          ),
          const BannerAdContainer(),
        ],
      ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Yaklaşan etkinlik kartı
// ---------------------------------------------------------------------------
class _UpcomingCard extends StatelessWidget {
  final _IslamicDay day;
  final DateTime today;
  final String language;

  const _UpcomingCard({required this.day, required this.today, required this.language});

  String _dayName() {
    if (language == 'ar') return day.nameAr;
    if (language == 'en') return day.nameEn;
    return day.nameTr;
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = day.date.difference(today).inDays;
    final isToday = daysLeft <= 0;
    final color = _typeColor(day.type, context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.25), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(_typeIcon(day.type), color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'tr'
                        ? 'Yaklaşan etkinlik'
                        : language == 'ar'
                            ? 'الفعالية القادمة'
                            : 'Upcoming',
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dayName(),
                    style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(day.date, language, day.durationDays),
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isToday
                    ? (language == 'tr' ? 'Bugün 🌙' : language == 'ar' ? 'اليوم 🌙' : 'Today 🌙')
                    : (language == 'tr' ? '$daysLeft gün' : language == 'ar' ? '$daysLeft يوم' : '$daysLeft days'),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liste öğesi
// ---------------------------------------------------------------------------
class _DayTile extends StatelessWidget {
  final _IslamicDay day;
  final DateTime today;
  final bool isPast;
  final bool isToday;
  final String language;

  const _DayTile({
    required this.day,
    required this.today,
    required this.isPast,
    required this.isToday,
    required this.language,
  });

  String _dayName() {
    if (language == 'ar') return day.nameAr;
    if (language == 'en') return day.nameEn;
    return day.nameTr;
  }

  @override
  Widget build(BuildContext context) {
    final color = isPast
        ? AppTheme.textPrimary(context).withOpacity(0.3)
        : _typeColor(day.type, context);
    final daysLeft = day.date.difference(today).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isPast
            ? AppTheme.textPrimary(context).withOpacity(0.04)
            : _typeColor(day.type, context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPast
              ? AppTheme.textPrimary(context).withOpacity(0.08)
              : _typeColor(day.type, context).withOpacity(isToday ? 0.5 : 0.2),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // İkon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _typeColor(day.type, context).withOpacity(isPast ? 0.06 : 0.15),
            ),
            child: Icon(
              _typeIcon(day.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // İsim + tarih
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dayName(),
                  style: TextStyle(
                    color: isPast ? AppTheme.textPrimary(context).withOpacity(0.45) : AppTheme.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(day.date, language, day.durationDays),
                  style: TextStyle(
                    color: AppTheme.textSecondary(context).withOpacity(isPast ? 0.5 : 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Kalan süre / Geçti
          if (isPast)
            Text(
              language == 'tr' ? 'Geçti' : language == 'ar' ? 'مضى' : 'Past',
              style: TextStyle(
                color: AppTheme.textSecondary(context).withOpacity(0.5),
                fontSize: 12,
              ),
            )
          else if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _typeColor(day.type, context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                language == 'tr' ? 'Bugün' : language == 'ar' ? 'اليوم' : 'Today',
                style: TextStyle(
                  color: _typeColor(day.type, context),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              language == 'tr' ? '$daysLeft gün' : language == 'ar' ? '$daysLeft يوم' : '$daysLeft d',
              style: TextStyle(
                color: _typeColor(day.type, context).withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Yardımcı fonksiyonlar
// ---------------------------------------------------------------------------
Color _typeColor(_DayType type, BuildContext context) {
  final dark = AppTheme.isDark(context);
  switch (type) {
    case _DayType.kandil:
      return dark ? AppColors.gold : const Color(0xFF8B6200);
    case _DayType.bayram:
      return dark ? AppColors.greenAccent : AppColors.greenButton;
    case _DayType.onemli:
      return dark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0);
  }
}

IconData _typeIcon(_DayType type) {
  switch (type) {
    case _DayType.kandil:
      return Icons.nights_stay_rounded;
    case _DayType.bayram:
      return Icons.celebration_rounded;
    case _DayType.onemli:
      return Icons.star_rounded;
  }
}

String _formatDate(DateTime date, String language, int durationDays) {
  const monthsTr = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];
  const monthsEn = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  const monthsAr = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  if (durationDays == 1) {
    if (language == 'tr') return '${date.day} ${monthsTr[date.month]} ${date.year}';
    if (language == 'ar') return '${date.day} ${monthsAr[date.month]} ${date.year}';
    return '${monthsEn[date.month]} ${date.day}, ${date.year}';
  }

  final end = date.add(Duration(days: durationDays - 1));
  if (language == 'tr') {
    return end.month == date.month
        ? '${date.day}–${end.day} ${monthsTr[date.month]} ${date.year}'
        : '${date.day} ${monthsTr[date.month]} – ${end.day} ${monthsTr[end.month]} ${date.year}';
  } else if (language == 'ar') {
    return end.month == date.month
        ? '${date.day}–${end.day} ${monthsAr[date.month]} ${date.year}'
        : '${date.day} ${monthsAr[date.month]} – ${end.day} ${monthsAr[end.month]} ${date.year}';
  } else {
    return end.month == date.month
        ? '${monthsEn[date.month]} ${date.day}–${end.day}, ${date.year}'
        : '${monthsEn[date.month]} ${date.day} – ${monthsEn[end.month]} ${end.day}, ${date.year}';
  }
}
