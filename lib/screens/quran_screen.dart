import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/colors.dart';
import '../widgets/banner_ad_container.dart';

// ── Surah metadata (114 surahs, static) ─────────────────────────────────────

class _Surah {
  final int number;
  final String arabic;
  final String turkish;
  final int verses;
  final bool isMekki;
  const _Surah(this.number, this.arabic, this.turkish, this.verses, this.isMekki);
}

const _surahs = [
  _Surah(1,'الْفَاتِحَة','Fatiha',7,true), _Surah(2,'الْبَقَرَة','Bakara',286,false),
  _Surah(3,'آلِ عِمْرَان','Ali İmran',200,false), _Surah(4,'النِّسَاء','Nisa',176,false),
  _Surah(5,'الْمَائِدَة','Maide',120,false), _Surah(6,'الْأَنْعَام','Enam',165,true),
  _Surah(7,'الْأَعْرَاف','Araf',206,true), _Surah(8,'الْأَنْفَال','Enfal',75,false),
  _Surah(9,'التَّوْبَة','Tevbe',129,false), _Surah(10,'يُونُس','Yunus',109,true),
  _Surah(11,'هُود','Hud',123,true), _Surah(12,'يُوسُف','Yusuf',111,true),
  _Surah(13,'الرَّعْد','Ra\'d',43,false), _Surah(14,'إِبْرَاهِيم','İbrahim',52,true),
  _Surah(15,'الْحِجْر','Hicr',99,true), _Surah(16,'النَّحْل','Nahl',128,true),
  _Surah(17,'الْإِسْرَاء','İsra',111,true), _Surah(18,'الْكَهْف','Kehf',110,true),
  _Surah(19,'مَرْيَم','Meryem',98,true), _Surah(20,'طه','Taha',135,true),
  _Surah(21,'الْأَنْبِيَاء','Enbiya',112,true), _Surah(22,'الْحَجّ','Hac',78,false),
  _Surah(23,'الْمُؤْمِنُون','Müminun',118,true), _Surah(24,'النُّور','Nur',64,false),
  _Surah(25,'الْفُرْقَان','Furkan',77,true), _Surah(26,'الشُّعَرَاء','Şuara',227,true),
  _Surah(27,'النَّمْل','Neml',93,true), _Surah(28,'الْقَصَص','Kasas',88,true),
  _Surah(29,'الْعَنْكَبُوت','Ankebut',69,true), _Surah(30,'الرُّوم','Rum',60,true),
  _Surah(31,'لُقْمَان','Lokman',34,true), _Surah(32,'السَّجْدَة','Secde',30,true),
  _Surah(33,'الْأَحْزَاب','Ahzab',73,false), _Surah(34,'سَبَأ','Sebe',54,true),
  _Surah(35,'فَاطِر','Fatır',45,true), _Surah(36,'يس','Yasin',83,true),
  _Surah(37,'الصَّافَّات','Saffat',182,true), _Surah(38,'ص','Sad',88,true),
  _Surah(39,'الزُّمَر','Zümer',75,true), _Surah(40,'غَافِر','Mümin',85,true),
  _Surah(41,'فُصِّلَت','Fussilet',54,true), _Surah(42,'الشُّورَى','Şura',53,true),
  _Surah(43,'الزُّخْرُف','Zuhruf',89,true), _Surah(44,'الدُّخَان','Duhan',59,true),
  _Surah(45,'الْجَاثِيَة','Casiye',37,true), _Surah(46,'الْأَحْقَاف','Ahkaf',35,true),
  _Surah(47,'مُحَمَّد','Muhammed',38,false), _Surah(48,'الْفَتْح','Fetih',29,false),
  _Surah(49,'الْحُجُرَات','Hucurat',18,false), _Surah(50,'ق','Kaf',45,true),
  _Surah(51,'الذَّارِيَات','Zariyat',60,true), _Surah(52,'الطُّور','Tur',49,true),
  _Surah(53,'النَّجْم','Necm',62,true), _Surah(54,'الْقَمَر','Kamer',55,true),
  _Surah(55,'الرَّحْمَن','Rahman',78,false), _Surah(56,'الْوَاقِعَة','Vakıa',96,true),
  _Surah(57,'الْحَدِيد','Hadid',29,false), _Surah(58,'الْمُجَادَلَة','Mücadele',22,false),
  _Surah(59,'الْحَشْر','Haşr',24,false), _Surah(60,'الْمُمْتَحَنَة','Mümtehine',13,false),
  _Surah(61,'الصَّف','Saf',14,false), _Surah(62,'الْجُمُعَة','Cuma',11,false),
  _Surah(63,'الْمُنَافِقُون','Münafikun',11,false), _Surah(64,'التَّغَابُن','Tegabün',18,false),
  _Surah(65,'الطَّلَاق','Talak',12,false), _Surah(66,'التَّحْرِيم','Tahrim',12,false),
  _Surah(67,'الْمُلْك','Mülk',30,true), _Surah(68,'الْقَلَم','Kalem',52,true),
  _Surah(69,'الْحَاقَّة','Hakka',52,true), _Surah(70,'الْمَعَارِج','Mearic',44,true),
  _Surah(71,'نُوح','Nuh',28,true), _Surah(72,'الْجِنّ','Cin',28,true),
  _Surah(73,'الْمُزَّمِّل','Müzzemmil',20,true), _Surah(74,'الْمُدَّثِّر','Müddessir',56,true),
  _Surah(75,'الْقِيَامَة','Kıyame',40,true), _Surah(76,'الْإِنْسَان','İnsan',31,false),
  _Surah(77,'الْمُرْسَلَات','Mürselat',50,true), _Surah(78,'النَّبَأ','Nebe',40,true),
  _Surah(79,'النَّازِعَات','Naziat',46,true), _Surah(80,'عَبَسَ','Abese',42,true),
  _Surah(81,'التَّكْوِير','Tekvir',29,true), _Surah(82,'الْإِنْفِطَار','İnfitar',19,true),
  _Surah(83,'الْمُطَفِّفِين','Mutaffifin',36,true), _Surah(84,'الْإِنْشِقَاق','İnşikak',25,true),
  _Surah(85,'الْبُرُوج','Buruc',22,true), _Surah(86,'الطَّارِق','Tarık',17,true),
  _Surah(87,'الْأَعْلَى','Ala',19,true), _Surah(88,'الْغَاشِيَة','Gaşiye',26,true),
  _Surah(89,'الْفَجْر','Fecr',30,true), _Surah(90,'الْبَلَد','Beled',20,true),
  _Surah(91,'الشَّمْس','Şems',15,true), _Surah(92,'اللَّيْل','Leyl',21,true),
  _Surah(93,'الضُّحَى','Duha',11,true), _Surah(94,'الشَّرْح','İnşirah',8,true),
  _Surah(95,'التِّين','Tin',8,true), _Surah(96,'الْعَلَق','Alak',19,true),
  _Surah(97,'الْقَدْر','Kadir',5,true), _Surah(98,'الْبَيِّنَة','Beyyine',8,false),
  _Surah(99,'الزَّلْزَلَة','Zilzal',8,false), _Surah(100,'الْعَادِيَات','Adiyat',11,true),
  _Surah(101,'الْقَارِعَة','Karia',11,true), _Surah(102,'التَّكَاثُر','Tekasür',8,true),
  _Surah(103,'الْعَصْر','Asr',3,true), _Surah(104,'الْهُمَزَة','Hümeze',9,true),
  _Surah(105,'الْفِيل','Fil',5,true), _Surah(106,'قُرَيْش','Kureyş',4,true),
  _Surah(107,'الْمَاعُون','Maun',7,true), _Surah(108,'الْكَوْثَر','Kevser',3,true),
  _Surah(109,'الْكَافِرُون','Kafirun',6,true), _Surah(110,'النَّصْر','Nasr',3,false),
  _Surah(111,'الْمَسَد','Tebbet',5,true), _Surah(112,'الْإِخْلَاص','İhlas',4,true),
  _Surah(113,'الْفَلَق','Felak',5,true), _Surah(114,'النَّاس','Nas',6,true),
];

// ── Surah List Screen ────────────────────────────────────────────────────────

class QuranScreen extends StatefulWidget {
  final String language;
  const QuranScreen({super.key, required this.language});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _search = '';

  List<_Surah> get _filtered => _surahs
      .where((s) =>
          s.turkish.toLowerCase().contains(_search.toLowerCase()) ||
          s.arabic.contains(_search) ||
          '${s.number}'.contains(_search))
      .toList();

  String _label(String tr, String en, [String? ar]) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar ?? en;
    return tr;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
                        _label('Kur\'an-ı Kerim', 'Holy Quran', 'القرآن الكريم'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ),
                    Text(
                      '114 ${_label('Sure', 'Surahs', 'سورة')}',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary(context)),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: TextField(
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: _label('Sure ara...', 'Search surah...', 'البحث عن سورة...'),
                    hintStyle: TextStyle(color: AppTheme.textSecondary(context)),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppTheme.textSecondary(context)),
                    filled: true,
                    fillColor: AppTheme.cardBg(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppTheme.divider(context)),
                  itemBuilder: (context, i) {
                    final s = filtered[i];
                    return _SurahRow(
                      surah: s,
                      language: widget.language,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuranSurahScreen(
                              surah: s, language: widget.language),
                        ),
                      ),
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

class _SurahRow extends StatelessWidget {
  final _Surah surah;
  final String language;
  final VoidCallback onTap;

  const _SurahRow({required this.surah, required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.greenAccent;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text('${surah.number}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent)),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.turkish,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(context))),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.isMekki ? (language == 'en' ? 'Meccan' : language == 'ar' ? 'مكية' : 'Mekki') : (language == 'en' ? 'Medinan' : language == 'ar' ? 'مدنية' : 'Medeni')} · ${surah.verses} ${language == 'en' ? 'verses' : language == 'ar' ? 'آية' : 'ayet'}',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary(context)),
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              surah.arabic,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary(context)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary(context), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Surah Detail Screen ──────────────────────────────────────────────────────

class QuranSurahScreen extends StatefulWidget {
  final _Surah surah;
  final String language;
  const QuranSurahScreen({super.key, required this.surah, required this.language});

  @override
  State<QuranSurahScreen> createState() => _QuranSurahScreenState();
}

class _QuranSurahScreenState extends State<QuranSurahScreen> {
  List<Map<String, dynamic>> _verses = [];
  bool _loading = true;
  String? _error;

  // Audio
  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _stateSub;
  bool _audioPlaying = false;
  bool _audioLoading = false;
  int _playingVerseIndex = -1; // index in _verses list
  bool _audioStopping = false;

  String _verseUrl(int verseNumInSurah) {
    final s = widget.surah.number.toString().padLeft(3, '0');
    final v = verseNumInSurah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$s$v.mp3';
  }

  @override
  void initState() {
    super.initState();
    _load();
    _player.setReleaseMode(ReleaseMode.stop);
    _stateSub = _player.onPlayerStateChanged.listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState state) {
    if (!mounted) return;
    switch (state) {
      case PlayerState.playing:
        setState(() => _audioLoading = false);
      case PlayerState.completed:
        if (!_audioStopping) _playNextVerse();
      default:
        break;
    }
  }

  void _playNextVerse() {
    final next = _playingVerseIndex + 1;
    if (next >= _verses.length) {
      if (mounted) setState(() { _audioPlaying = false; _audioLoading = false; _playingVerseIndex = -1; });
      _audioStopping = false;
      return;
    }
    setState(() { _playingVerseIndex = next; _audioLoading = true; });
    _player.play(UrlSource(_verseUrl(_verses[next]['number'] as int)));
  }

  Future<void> _toggleAudio() async {
    if (_audioPlaying) {
      _audioStopping = true;
      await _player.stop();
      _audioStopping = false;
      if (!mounted) return;
      setState(() { _audioPlaying = false; _audioLoading = false; _playingVerseIndex = -1; });
      return;
    }
    if (_verses.isEmpty) return;
    setState(() { _audioPlaying = true; _audioLoading = true; _playingVerseIndex = 0; });
    _player.play(UrlSource(_verseUrl(_verses[0]['number'] as int)));
  }

  @override
  void dispose() {
    _stateSub.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Dio().get(
        'https://api.alquran.cloud/v1/surah/${widget.surah.number}/editions/quran-uthmani,tr.diyanet,en.asad',
      );
      final data = res.data['data'] as List;
      final arabicAyahs = data[0]['ayahs'] as List;
      final turkishAyahs = data[1]['ayahs'] as List;
      final englishAyahs = data[2]['ayahs'] as List;
      final verses = List.generate(arabicAyahs.length, (i) => {
        'number': arabicAyahs[i]['numberInSurah'] as int,
        'arabic': arabicAyahs[i]['text'] as String,
        'turkish': turkishAyahs[i]['text'] as String,
        'english': englishAyahs[i]['text'] as String,
      });
      if (mounted) setState(() { _verses = verses; _loading = false; });
    } catch (_) {
      if (mounted) setState(() {
        _error = widget.language == 'en' ? 'Could not load verses' : widget.language == 'ar' ? 'تعذر تحميل الآيات' : 'Ayetler yüklenemedi';
        _loading = false;
      });
    }
  }

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
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary(context), size: 22),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.surah.turkish,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary(context))),
                          Text(
                            '${widget.surah.arabic}  ·  ${widget.surah.verses} ${widget.language == 'en' ? 'verses' : widget.language == 'ar' ? 'آية' : 'ayet'}',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary(context)),
                          ),
                        ],
                      ),
                    ),
                    // Sesli dinle butonu
                    if (!_loading && _error == null)
                      GestureDetector(
                        onTap: _toggleAudio,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: (_audioPlaying || _audioLoading)
                                ? AppColors.greenAccent.withOpacity(0.15)
                                : AppTheme.cardBg(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (_audioPlaying || _audioLoading)
                                  ? AppColors.greenAccent
                                  : AppTheme.divider(context),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_audioLoading)
                                SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      color: AppColors.greenAccent, strokeWidth: 2),
                                )
                              else
                                Icon(
                                  _audioPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: (_audioPlaying || _audioLoading)
                                      ? AppColors.greenAccent
                                      : AppTheme.textSecondary(context),
                                  size: 18,
                                ),
                              const SizedBox(width: 5),
                              Text(
                                _audioPlaying
                                    ? (widget.language == 'en' ? 'Stop' : 'Durdur')
                                    : (widget.language == 'en' ? 'Listen' : 'Sesli Dinle'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (_audioPlaying || _audioLoading)
                                      ? AppColors.greenAccent
                                      : AppTheme.textSecondary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Content
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _ErrorView(message: _error!, onRetry: _load)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                            itemCount: _verses.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: AppTheme.divider(context)),
                            itemBuilder: (context, i) => _VerseCard(
                              verse: _verses[i],
                              isDark: AppTheme.isDark(context),
                              language: widget.language,
                              isPlaying: _playingVerseIndex == i,
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

class _VerseCard extends StatelessWidget {
  final Map<String, dynamic> verse;
  final bool isDark;
  final String language;
  final bool isPlaying;
  const _VerseCard({required this.verse, required this.isDark, required this.language, this.isPlaying = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: isPlaying ? const EdgeInsets.symmetric(vertical: 10, horizontal: 4) : EdgeInsets.zero,
      decoration: isPlaying
          ? BoxDecoration(
              color: AppColors.greenAccent.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppColors.greenAccent.withOpacity(0.3)
                      : AppColors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${verse['number']}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenAccent),
                ),
              ),
              if (isPlaying) ...[
                const SizedBox(width: 8),
                Icon(Icons.volume_up_rounded, color: AppColors.greenAccent, size: 14),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Arabic text
          Text(
            verse['arabic'] as String,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
              height: 1.8,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          // Translation (Turkish for TR, English for EN/AR)
          Text(
            language == 'tr' ? verse['turkish'] as String : (verse['english'] as String? ?? verse['turkish'] as String),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textSecondary(context),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 40, color: AppTheme.textSecondary(context)),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: AppTheme.textSecondary(context))),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenButton,
                foregroundColor: Colors.white),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
