import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/colors.dart';
import '../widgets/banner_ad_container.dart';

// Per-verse everyayah.com URLs — confirmed to work on Android & iOS.
// cdn.islamic.network whole-surah files fail silently on Android.
const _base = 'https://everyayah.com/data/Alafasy_128kbps/';
const _roundUrls = [
  // Felak 113:1-5
  '${_base}113001.mp3', '${_base}113002.mp3', '${_base}113003.mp3',
  '${_base}113004.mp3', '${_base}113005.mp3',
  // Nas 114:1-6
  '${_base}114001.mp3', '${_base}114002.mp3', '${_base}114003.mp3',
  '${_base}114004.mp3', '${_base}114005.mp3', '${_base}114006.mp3',
  // Ayet-el Kürsi 2:255
  '${_base}002255.mp3',
];
const _roundSize = 12; // 5 + 6 + 1

class _Prayer {
  final String nameTr;
  final String nameAr;
  final String arabic;
  final String okunusTr;
  final String mealTr;
  final String mealEn;

  const _Prayer({
    required this.nameTr,
    required this.nameAr,
    required this.arabic,
    required this.okunusTr,
    required this.mealTr,
    required this.mealEn,
  });
}


const _prayers = [
  _Prayer(
    nameTr: 'Felak Suresi',
    nameAr: 'سورة الفلق',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    okunusTr:
        'Kul e\'ûzü birabbilfelak. Min şerri mâ halak. Ve min şerri ğâsikın izâ vekab. Ve min şerrinneffâsâti fil\'ukad. Ve min şerri hâsidin izâ hased.',
    mealTr:
        'De ki: "Yarattığı şeylerin şerrinden, karanlığı çöktüğünde gecenin şerrinden, düğümlere üfürenlerin şerrinden, kıskandığında kıskanç kimsenin şerrinden sabahın Rabbine sığınırım."',
    mealEn:
        'Say: "I seek refuge in the Lord of the daybreak, from the evil of what He has created, from the evil of darkness when it settles, from the evil of the blowers in knots, and from the evil of an envier when he envies."',
  ),
  _Prayer(
    nameTr: 'Nas Suresi',
    nameAr: 'سورة الناس',
    arabic:
        'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    okunusTr:
        'Kul e\'ûzü birabbinnâs. Melikinnâs. İlâhinnâs. Min şerrilvesvâsilhannâs. Ellezî yüvesvisü fî sudûrinnâsi. Minelcinneti vennâs.',
    mealTr:
        'De ki: "İnsanların Rabbine sığınırım; insanların melikine, insanların ilahına; vesvesecinin, sinsi şeytanın şerrinden ki o, insanların kalplerine vesvese verir; cinlerden ve insanlardan olan o şeytanın şerrinden."',
    mealEn:
        'Say: "I seek refuge in the Lord of mankind, the Sovereign of mankind, the God of mankind, from the evil of the retreating whisperer who whispers evil into the hearts of mankind, from among the jinn and mankind."',
  ),
  _Prayer(
    nameTr: 'Ayet-el Kürsi',
    nameAr: 'آية الكرسي',
    arabic:
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    okunusTr:
        'Allâhü lâ ilâhe illâ hüvel hayyül kayyûm. Lâ te\'huzühü sinetün velâ nevm. Lehû mâ fis semâvâti ve mâ fil ard. Men zellezî yeşfe\'u indehû illâ bi iznih. Ya\'lemü mâ beyne eydîhim ve mâ halfehüm. Ve lâ yühîtûne bi şey\'in min ilmihî illâ bimâ şâe. Vesia kürsiyyühüssemâvâti vel ard. Ve lâ yeûdühü hıfzuhumâ ve hüvel aliyyül azîm.',
    mealTr:
        'Allah, kendisinden başka hiçbir ilah bulunmayandır. O, Hayy\'dır, Kayyûm\'dur. O\'nu ne bir uyuklama ne de uyku tutar. Göklerdeki her şey ve yerdeki her şey O\'nundur. O\'nun izni olmaksızın katında kim şefaat edebilir? O, kullarının önündeki ve arkasındaki her şeyi bilir. Onlar ise O\'nun ilminden, ancak dilediği kadarını kavrayabilirler. O\'nun kürsüsü gökleri ve yeri kaplamıştır. Onların ikisini de koruyup gözetmek O\'na ağır gelmez. O, Aliyy\'dir, Azîm\'dir.',
    mealEn:
        'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Throne extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
  ),
];

class PrayerProtectionsScreen extends StatefulWidget {
  final String language;
  const PrayerProtectionsScreen({super.key, required this.language});

  @override
  State<PrayerProtectionsScreen> createState() =>
      _PrayerProtectionsScreenState();
}

class _PrayerProtectionsScreenState extends State<PrayerProtectionsScreen> {
  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _stateSub;

  bool _isPlaying = false;
  bool _isLoading = false;
  int _currentRound = 0;
  int _currentPrayerIndex = 0;
  bool _isStopping = false;
  static const int _totalRounds = 7;

  // Flat queue: _roundUrls repeated 7 times
  late final List<String> _queue = [
    for (var r = 0; r < _totalRounds; r++) ..._roundUrls,
  ];
  int _queueIndex = -1;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.stop);
    _stateSub = _player.onPlayerStateChanged.listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState state) {
    if (!mounted) return;
    switch (state) {
      case PlayerState.playing:
        setState(() => _isLoading = false);
      case PlayerState.completed:
        if (!_isStopping) _playNext();
      default:
        break;
    }
  }

  void _playNext() {
    _queueIndex++;
    if (_queueIndex >= _queue.length) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _currentRound = 0;
          _currentPrayerIndex = 0;
        });
      }
      _isStopping = false;
      _queueIndex = -1;
      return;
    }
    _updateProgress();
    _player.play(UrlSource(_queue[_queueIndex]));
  }

  void _updateProgress() {
    final pos = _queueIndex % _roundSize;
    final round = _queueIndex ~/ _roundSize + 1;
    final prayerIndex = pos < 5 ? 0 : pos < 11 ? 1 : 2;
    if (mounted) setState(() { _currentRound = round; _currentPrayerIndex = prayerIndex; });
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      _isStopping = true;
      await _player.stop();
      _queueIndex = -1;
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _isLoading = false;
        _currentRound = 0;
        _currentPrayerIndex = 0;
      });
      _isStopping = false;
      return;
    }

    _queueIndex = 0;
    _isStopping = false;
    setState(() {
      _isPlaying = true;
      _isLoading = true;
      _currentRound = 1;
      _currentPrayerIndex = 0;
    });
    _player.play(UrlSource(_queue[0]));
  }

  @override
  void dispose() {
    _stateSub.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = widget.language == 'tr';
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
              _buildHeader(isTr),
              _buildPlayButton(isTr),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _prayers.length,
                  itemBuilder: (context, index) =>
                      _buildPrayerCard(index, isTr),
                ),
              ),
              const BannerAdContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.sheetItemBg(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.divider(context)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary(context), size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTr ? 'Nazar Duaları' : 'Protection Prayers',
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isTr
                    ? 'Felak • Nas • Ayet-el Kürsi'
                    : 'Al-Falaq • An-Nas • Ayatul Kursi',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(bool isTr) {
    final isActive = _isPlaying || _isLoading;
    final fgColor = isActive ? AppColors.greenAccent : AppTheme.textPrimary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GestureDetector(
        onTap: _togglePlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.greenAccent.withOpacity(0.15)
                : AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isActive ? AppColors.greenAccent : AppTheme.divider(context),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: fgColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPlaying
                        ? (isTr ? 'Durdur' : 'Stop')
                        : (isTr ? '7 Kere Oku' : 'Recite 7 Times'),
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isPlaying && !_isLoading)
                    Text(
                      isTr
                          ? 'Tur $_currentRound/$_totalRounds — ${_prayers[_currentPrayerIndex].nameTr}'
                          : 'Round $_currentRound/$_totalRounds — ${_prayers[_currentPrayerIndex].nameTr}',
                      style: TextStyle(
                        color: AppColors.greenAccent.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    )
                  else if (_isLoading)
                    Text(
                      isTr ? 'Yükleniyor...' : 'Loading...',
                      style: TextStyle(
                        color: AppColors.greenAccent.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      isTr
                          ? 'Üçü art arda 7 kere okunur'
                          : 'All three recited 7 times in sequence',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(int index, bool isTr) {
    final prayer = _prayers[index];
    final isActive = _isPlaying && _currentPrayerIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.sheetItemBg(context),
        border: Border.all(
          color: isActive
              ? AppColors.greenAccent.withOpacity(0.7)
              : AppTheme.divider(context),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.greenAccent.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenAccent.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.nameTr,
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        prayer.nameAr,
                        style: TextStyle(
                          color: AppTheme.accentColor(context).withOpacity(0.85),
                          fontSize: 13,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isTr ? 'Okunuyor' : 'Playing',
                      style: TextStyle(
                        color: AppColors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Arabic text
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.cardBg(context),
            ),
            child: Text(
              prayer.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 20,
                height: 2.0,
                fontFamily: 'serif',
              ),
            ),
          ),
          // Okunuş
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.greenAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Okunuş',
                      style: TextStyle(
                        color: AppColors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  prayer.okunusTr,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 13,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Turkish/English meal
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTr ? 'Türkçe Meali' : 'Translation',
                      style: TextStyle(
                        color: AppTheme.accentColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isTr ? prayer.mealTr : prayer.mealEn,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 13,
                    height: 1.6,
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
