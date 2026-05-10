import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/banner_ad_container.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class _InfoItem {
  final String titleTr;
  final String titleEn;
  final String titleAr;
  final List<_InfoEntry> entries;

  const _InfoItem({
    required this.titleTr,
    required this.titleEn,
    required this.titleAr,
    required this.entries,
  });
}

class _InfoEntry {
  final String tr;
  final String en;
  final String ar;

  const _InfoEntry({required this.tr, required this.en, required this.ar});
}

// ── Static data ──────────────────────────────────────────────────────────────

const _infoList = [
  _InfoItem(
    titleTr: "İslam'ın Şartları",
    titleEn: "Pillars of Islam",
    titleAr: "أركان الإسلام",
    entries: [
      _InfoEntry(tr: "1. Kelime-i Şehadet", en: "1. Shahada", ar: "١. الشهادة"),
      _InfoEntry(tr: "2. Namaz kılmak", en: "2. Salah (Prayer)", ar: "٢. الصلاة"),
      _InfoEntry(tr: "3. Zekât vermek", en: "3. Zakat", ar: "٣. الزكاة"),
      _InfoEntry(tr: "4. Oruç tutmak", en: "4. Sawm (Fasting)", ar: "٤. الصوم"),
      _InfoEntry(tr: "5. Hacca gitmek", en: "5. Hajj", ar: "٥. الحج"),
    ],
  ),
  _InfoItem(
    titleTr: "İmanın Şartları",
    titleEn: "Pillars of Faith",
    titleAr: "أركان الإيمان",
    entries: [
      _InfoEntry(tr: "1. Allah'a iman", en: "1. Belief in Allah", ar: "١. الإيمان بالله"),
      _InfoEntry(tr: "2. Meleklere iman", en: "2. Belief in Angels", ar: "٢. الإيمان بالملائكة"),
      _InfoEntry(tr: "3. Kitaplara iman", en: "3. Belief in Holy Books", ar: "٣. الإيمان بالكتب"),
      _InfoEntry(tr: "4. Peygamberlere iman", en: "4. Belief in Prophets", ar: "٤. الإيمان بالرسل"),
      _InfoEntry(tr: "5. Ahiret gününe iman", en: "5. Belief in the Last Day", ar: "٥. الإيمان باليوم الآخر"),
      _InfoEntry(tr: "6. Kader ve kazaya iman", en: "6. Belief in Divine Decree", ar: "٦. الإيمان بالقدر"),
    ],
  ),
  _InfoItem(
    titleTr: "Namazın Farzları",
    titleEn: "Obligations of Prayer",
    titleAr: "فرائض الصلاة",
    entries: [
      _InfoEntry(tr: "Dış Farzlar (Şartlar):", en: "Outer Conditions:", ar: "الشروط الخارجية:"),
      _InfoEntry(tr: "1. Hadesten taharet (abdest/gusül)", en: "1. Ritual purity (wudu/ghusl)", ar: "١. الطهارة من الحدث"),
      _InfoEntry(tr: "2. Necasetten taharet (temiz elbise/yer)", en: "2. Cleanliness of body and place", ar: "٢. الطهارة من النجاسة"),
      _InfoEntry(tr: "3. Setr-i avret (avret örtme)", en: "3. Covering the awrah", ar: "٣. ستر العورة"),
      _InfoEntry(tr: "4. İstikbal-i kıble (kıbleye yönelme)", en: "4. Facing the Qibla", ar: "٤. استقبال القبلة"),
      _InfoEntry(tr: "5. Vakit (namaz vaktinin girmesi)", en: "5. Prayer time", ar: "٥. الوقت"),
      _InfoEntry(tr: "6. Niyet etmek", en: "6. Intention (niyyah)", ar: "٦. النية"),
      _InfoEntry(tr: "İç Farzlar (Rükünler):", en: "Inner Pillars:", ar: "الأركان الداخلية:"),
      _InfoEntry(tr: "1. İftitah tekbiri (başlangıç tekbiri)", en: "1. Opening takbir", ar: "١. تكبيرة الإحرام"),
      _InfoEntry(tr: "2. Kıyam (ayakta durmak)", en: "2. Standing (qiyam)", ar: "٢. القيام"),
      _InfoEntry(tr: "3. Kıraat (Fatiha okumak)", en: "3. Recitation (al-Fatiha)", ar: "٣. القراءة"),
      _InfoEntry(tr: "4. Rükû (eğilmek)", en: "4. Bowing (ruku)", ar: "٤. الركوع"),
      _InfoEntry(tr: "5. Secde (iki secde)", en: "5. Prostration (sujud)", ar: "٥. السجود"),
      _InfoEntry(tr: "6. Ka'de-i âhire (son oturuş)", en: "6. Final sitting (tashahhud)", ar: "٦. القعدة الأخيرة"),
    ],
  ),
  _InfoItem(
    titleTr: "Abdestin Farzları",
    titleEn: "Obligations of Wudu",
    titleAr: "فرائض الوضوء",
    entries: [
      _InfoEntry(tr: "1. Yüzü yıkamak", en: "1. Washing the face", ar: "١. غسل الوجه"),
      _InfoEntry(tr: "2. Kolları dirseğe kadar yıkamak", en: "2. Washing arms to elbows", ar: "٢. غسل اليدين إلى المرفقين"),
      _InfoEntry(tr: "3. Başın dörtte birini meshetmek", en: "3. Wiping a quarter of the head", ar: "٣. مسح ربع الرأس"),
      _InfoEntry(tr: "4. Ayakları topuğa kadar yıkamak", en: "4. Washing feet to ankles", ar: "٤. غسل الرجلين إلى الكعبين"),
    ],
  ),
  _InfoItem(
    titleTr: "Orucun Farzları",
    titleEn: "Obligations of Fasting",
    titleAr: "فرائض الصوم",
    entries: [
      _InfoEntry(tr: "1. Niyet etmek", en: "1. Making intention (niyyah)", ar: "١. النية"),
      _InfoEntry(tr: "2. İmsak: Fecirden (tan yerinin ağarmasından) başlamak", en: "2. Begin at Fajr (dawn)", ar: "٢. الإمساك من الفجر"),
      _InfoEntry(tr: "3. İftar: Güneş batımına kadar orucu sürdürmek", en: "3. Continue until sunset (Maghrib)", ar: "٣. الاستمرار حتى الغروب"),
    ],
  ),
  _InfoItem(
    titleTr: "Gusül (Boy Abdesti) Farzları",
    titleEn: "Obligations of Ghusl",
    titleAr: "فرائض الغسل",
    entries: [
      _InfoEntry(tr: "1. Ağız içini yıkamak (mazmaza)", en: "1. Rinsing the mouth", ar: "١. المضمضة"),
      _InfoEntry(tr: "2. Burnu içini yıkamak (istinşak)", en: "2. Rinsing the nostrils", ar: "٢. الاستنشاق"),
      _InfoEntry(tr: "3. Tüm vücudu yıkamak", en: "3. Washing the entire body", ar: "٣. غسل جميع البدن"),
    ],
  ),
  _InfoItem(
    titleTr: "Namaz Vakitleri",
    titleEn: "Daily Prayer Times",
    titleAr: "أوقات الصلاة",
    entries: [
      _InfoEntry(tr: "1. Sabah (Fajr) — Tan yerinin ağarmasından güneş doğana kadar", en: "1. Fajr — From dawn until sunrise", ar: "١. الفجر — من طلوع الفجر حتى طلوع الشمس"),
      _InfoEntry(tr: "2. Öğle (Zuhr) — Güneş en yükseğe çıkıp alçalmaya başladığında", en: "2. Zuhr — After solar noon", ar: "٢. الظهر — بعد زوال الشمس"),
      _InfoEntry(tr: "3. İkindi (Asr) — Öğleden güneş batımına kadar (ikinci yarı)", en: "3. Asr — Afternoon until sunset", ar: "٣. العصر — بعد الظهر حتى الغروب"),
      _InfoEntry(tr: "4. Akşam (Maghrib) — Güneş battıktan sonra", en: "4. Maghrib — After sunset", ar: "٤. المغرب — بعد غروب الشمس"),
      _InfoEntry(tr: "5. Yatsı (Isha) — Akşamın kızıllığı kaybolunca", en: "5. Isha — After twilight disappears", ar: "٥. العشاء — بعد غياب الشفق"),
    ],
  ),
  _InfoItem(
    titleTr: "Kur'an-ı Kerim Hakkında",
    titleEn: "About the Quran",
    titleAr: "حول القرآن الكريم",
    entries: [
      _InfoEntry(tr: "Sure sayısı: 114", en: "Number of surahs: 114", ar: "عدد السور: ١١٤"),
      _InfoEntry(tr: "Ayet sayısı: 6.236", en: "Number of verses: 6,236", ar: "عدد الآيات: ٦٢٣٦"),
      _InfoEntry(tr: "Mekki sure sayısı: 86", en: "Meccan surahs: 86", ar: "السور المكية: ٨٦"),
      _InfoEntry(tr: "Medeni sure sayısı: 28", en: "Medinan surahs: 28", ar: "السور المدنية: ٢٨"),
      _InfoEntry(tr: "Cüz sayısı: 30", en: "Number of juz: 30", ar: "عدد الأجزاء: ٣٠"),
      _InfoEntry(tr: "İlk inen ayet: Alak Suresi 1-5. ayetler", en: "First revealed: Al-Alaq 1–5", ar: "أول ما نزل: العلق ١–٥"),
      _InfoEntry(tr: "Son inen sure: Nasr Suresi", en: "Last revealed surah: An-Nasr", ar: "آخر سورة نزلت: النصر"),
    ],
  ),
  _InfoItem(
    titleTr: "Peygamberlerin Sayısı",
    titleEn: "Number of Prophets",
    titleAr: "عدد الأنبياء",
    entries: [
      _InfoEntry(tr: "Kur'an'da ismi geçen peygamber sayısı: 25", en: "Prophets named in the Quran: 25", ar: "عدد الأنبياء المذكورين في القرآن: ٢٥"),
      _InfoEntry(tr: "İlk peygamber: Hz. Âdem (a.s.)", en: "First prophet: Adam (a.s.)", ar: "أول الأنبياء: آدم عليه السلام"),
      _InfoEntry(tr: "Son peygamber: Hz. Muhammed (s.a.v.)", en: "Last prophet: Muhammad (s.a.w.)", ar: "خاتم الأنبياء: محمد صلى الله عليه وسلم"),
      _InfoEntry(tr: "Ulü'l-azm peygamberler (5): Nuh, İbrahim, Musa, İsa, Muhammed", en: "Ulu'l-Azm Prophets (5): Noah, Abraham, Moses, Jesus, Muhammad", ar: "أولو العزم (٥): نوح، إبراهيم، موسى، عيسى، محمد"),
    ],
  ),
  _InfoItem(
    titleTr: "Mübarek Gece ve Günler",
    titleEn: "Holy Nights and Days",
    titleAr: "الليالي والأيام المباركة",
    entries: [
      _InfoEntry(tr: "Regaib Gecesi — Recep ayının ilk Cuma gecesi", en: "Raghaib Night — First Friday of Rajab", ar: "ليلة الرغائب — أول جمعة من رجب"),
      _InfoEntry(tr: "Miraç Gecesi — Recep ayının 27. gecesi", en: "Isra & Mi'raj — 27th of Rajab", ar: "ليلة الإسراء والمعراج — ٢٧ رجب"),
      _InfoEntry(tr: "Beraat Gecesi — Şaban ayının 15. gecesi", en: "Laylat al-Bara'ah — 15th of Sha'ban", ar: "ليلة البراءة — ١٥ شعبان"),
      _InfoEntry(tr: "Kadir Gecesi — Ramazan'ın 27. gecesi (kesin değil)", en: "Laylat al-Qadr — Last 10 nights of Ramadan", ar: "ليلة القدر — العشر الأواخر من رمضان"),
      _InfoEntry(tr: "Ramazan Bayramı — Ramazan'ın bitiminde (1 Şevval)", en: "Eid al-Fitr — End of Ramadan", ar: "عيد الفطر — ١ شوال"),
      _InfoEntry(tr: "Kurban Bayramı — Zilhicce'nin 10-13. günleri", en: "Eid al-Adha — 10–13 Dhul Hijjah", ar: "عيد الأضحى — ١٠–١٣ ذو الحجة"),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ReligiousInfoScreen extends StatelessWidget {
  final String language;
  const ReligiousInfoScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary(context), size: 22),
                    ),
                    Expanded(
                      child: Text(
                        language == 'en'
                            ? 'Islamic Knowledge'
                            : language == 'ar'
                                ? 'المعلومات الدينية'
                                : 'Dini Bilgiler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _infoList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _InfoCard(
                    item: _infoList[i],
                    language: language,
                  ),
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

// ── Expandable info card ──────────────────────────────────────────────────────

class _InfoCard extends StatefulWidget {
  final _InfoItem item;
  final String language;
  const _InfoCard({required this.item, required this.language});

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _rotate = Tween(begin: 0.0, end: 0.5).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.language == 'en') return widget.item.titleEn;
    if (widget.language == 'ar') return widget.item.titleAr;
    return widget.item.titleTr;
  }

  String _entryText(_InfoEntry e) {
    if (widget.language == 'en') return e.en;
    if (widget.language == 'ar') return e.ar;
    return e.tr;
  }

  bool get _isArabic => widget.language == 'ar';

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider(context)),
      ),
      child: Column(
        children: [
          // Title row
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.12),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _title,
                      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary(context), size: 22),
                  ),
                ],
              ),
            ),
          ),
          // Entries
          if (_expanded) ...[
            Divider(height: 1, color: AppTheme.divider(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: _isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: widget.item.entries.map((e) {
                  final text = _entryText(e);
                  final isSectionHeader = !text.startsWith(RegExp(r'\d|[١٢٣٤٥٦٧٨٩]')) &&
                      text.endsWith(':');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      text,
                      textDirection:
                          _isArabic ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: isSectionHeader ? 13 : 13,
                        fontWeight: isSectionHeader
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: isSectionHeader
                            ? accent
                            : AppTheme.textSecondary(context),
                        height: 1.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
