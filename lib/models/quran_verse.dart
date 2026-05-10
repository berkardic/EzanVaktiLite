class QuranVerse {
  final int number;
  final String arabicText;
  final String turkishText;
  final String englishText;
  final String audioUrl;
  final String surahNameArabic;
  final String surahNameTurkish;
  final int surahNumber;
  final int verseInSurah;

  const QuranVerse({
    required this.number,
    required this.arabicText,
    required this.turkishText,
    required this.englishText,
    required this.audioUrl,
    required this.surahNameArabic,
    required this.surahNameTurkish,
    required this.surahNumber,
    required this.verseInSurah,
  });

  factory QuranVerse.fromApiResponse(List<dynamic> editions, int globalVerseNumber) {
    if (editions.length < 3) {
      throw Exception('Kur\'an API beklenen format dışı: ${editions.length} bölüm döndü');
    }
    // editions[0] = quran-uthmani (Arabic), [1] = tr.diyanet, [2] = en.asad
    final arabic = editions[0] as Map<String, dynamic>;
    final turkish = editions[1] as Map<String, dynamic>;
    final english = editions[2] as Map<String, dynamic>;

    final surah = arabic['surah'] as Map<String, dynamic>;
    final surahNum = surah['number'] as int;
    final verseNum = arabic['numberInSurah'] as int;

    // everyayah.com: reliable HTTPS CDN, Alafasy recitation, individual ayah files.
    // Format: {surah 3 digits}{verse 3 digits}.mp3
    final s = surahNum.toString().padLeft(3, '0');
    final v = verseNum.toString().padLeft(3, '0');
    final audioUrl = 'https://everyayah.com/data/Alafasy_128kbps/$s$v.mp3';

    return QuranVerse(
      number: globalVerseNumber,
      arabicText: arabic['text'] as String,
      turkishText: turkish['text'] as String,
      englishText: english['text'] as String,
      audioUrl: audioUrl,
      surahNameArabic: surah['name'] as String,
      surahNameTurkish: surah['englishName'] as String, // e.g. "Al-Baqara"
      surahNumber: surahNum,
      verseInSurah: verseNum,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'arabicText': arabicText,
        'turkishText': turkishText,
        'englishText': englishText,
        'audioUrl': audioUrl,
        'surahNameArabic': surahNameArabic,
        'surahNameTurkish': surahNameTurkish,
        'surahNumber': surahNumber,
        'verseInSurah': verseInSurah,
      };

  factory QuranVerse.fromJson(Map<String, dynamic> json) => QuranVerse(
        number: json['number'] as int,
        arabicText: json['arabicText'] as String,
        turkishText: json['turkishText'] as String,
        englishText: (json['englishText'] as String?) ?? '',
        audioUrl: json['audioUrl'] as String,
        surahNameArabic: json['surahNameArabic'] as String,
        surahNameTurkish: json['surahNameTurkish'] as String,
        surahNumber: json['surahNumber'] as int,
        verseInSurah: json['verseInSurah'] as int,
      );
}
