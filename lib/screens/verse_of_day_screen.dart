import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quran_verse.dart';
import '../services/quran_service.dart';
import '../constants/colors.dart';
import '../widgets/banner_ad_container.dart';

class VerseOfDayScreen extends StatefulWidget {
  final String language;

  const VerseOfDayScreen({super.key, required this.language});

  @override
  State<VerseOfDayScreen> createState() => _VerseOfDayScreenState();
}

class _VerseOfDayScreenState extends State<VerseOfDayScreen> {
  QuranVerse? _verse;
  bool _isLoading = true;
  String? _error;

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _loadVerse();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadVerse() async {
    try {
      final verse = await QuranService.shared.fetchVerseOfDay();
      if (mounted) setState(() { _verse = verse; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = widget.language == 'tr' ? 'Ayet yüklenemedi. İnternet bağlantınızı kontrol edin.' : widget.language == 'ar' ? 'تعذر تحميل الآية. تحقق من اتصالك.' : 'Could not load verse. Check your connection.'; _isLoading = false; });
    }
  }

  Future<void> _toggleAudio() async {
    if (_verse == null || _verse!.audioUrl.isEmpty) return;

    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(_verse!.audioUrl));
      }
    } catch (e) {
      debugPrint('[VerseAudio] play error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Header with back arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary(context), size: 22),
                    ),
                    Icon(Icons.menu_book_rounded, color: AppTheme.accentColor(context), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      widget.language == 'tr' ? 'Günün Ayeti' : widget.language == 'ar' ? 'آية اليوم' : 'Verse of the Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppTheme.accentColor(context)))
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.wifi_off, color: AppTheme.textSecondary(context), size: 48),
                                const SizedBox(height: 16),
                                Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary(context))),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadVerse(); },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                                  child: Text(widget.language == 'tr' ? 'Tekrar Dene' : widget.language == 'ar' ? 'إعادة المحاولة' : 'Retry', style: const TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Column(
                            children: [
                              // Surah info
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor(context).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.accentColor(context).withOpacity(0.3)),
                                ),
                                child: Text(
                                  '${_verse!.surahNameArabic}  •  ${_verse!.surahNameTurkish}  ${_verse!.surahNumber}:${_verse!.verseInSurah}',
                                  style: TextStyle(color: AppTheme.accentColor(context), fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Arabic text
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBg(context),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _verse!.arabicText,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: AppTheme.textPrimary(context),
                                    height: 2.0,
                                    fontFamily: 'Arial',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Audio button
                              GestureDetector(
                                onTap: _toggleAudio,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _playerState == PlayerState.playing
                                        ? AppColors.greenAccent.withOpacity(0.2)
                                        : AppTheme.cardBg(context),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: _playerState == PlayerState.playing
                                          ? AppColors.greenAccent
                                          : AppTheme.divider(context),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _playerState == PlayerState.playing
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        color: _playerState == PlayerState.playing
                                            ? AppColors.greenAccent
                                            : AppTheme.textPrimary(context),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _playerState == PlayerState.playing
                                            ? (widget.language == 'tr' ? 'Durdur' : widget.language == 'ar' ? 'إيقاف' : 'Pause')
                                            : (widget.language == 'tr' ? 'Sesli Dinle' : widget.language == 'ar' ? 'استماع' : 'Listen'),
                                        style: TextStyle(
                                          color: _playerState == PlayerState.playing
                                              ? AppColors.greenAccent
                                              : AppTheme.textPrimary(context),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: AppTheme.divider(context))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      widget.language == 'tr' ? 'Türkçe Meal' : widget.language == 'ar' ? 'الترجمة الإنجليزية' : 'Translation',
                                      style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 12),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: AppTheme.divider(context))),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Turkish translation
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBg(context),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.divider(context)),
                                ),
                                child: Text(
                                  '"${widget.language == 'tr' ? _verse!.turkishText : _verse!.englishText}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.textSecondary(context),
                                    height: 1.7,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.language == 'tr'
                                    ? 'Kaynak: Diyanet İşleri Başkanlığı Meali'
                                    : widget.language == 'ar'
                                        ? 'المصدر: ترجمة محمد أسد (الإنجليزية)'
                                        : 'Source: Muhammad Asad (English)',
                                style: TextStyle(color: AppTheme.textSecondary(context).withOpacity(0.6), fontSize: 11),
                              ),
                            ],
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
