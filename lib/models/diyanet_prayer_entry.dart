class DiyanetPrayerEntry {
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;
  final String miladiTarihKisa;

  DiyanetPrayerEntry({
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
    required this.miladiTarihKisa,
  });

  factory DiyanetPrayerEntry.fromJson(Map<String, dynamic> json) {
    return DiyanetPrayerEntry(
      imsak: (json['Imsak'] as String?) ?? '',
      gunes: (json['Gunes'] as String?) ?? '',
      ogle: (json['Ogle'] as String?) ?? '',
      ikindi: (json['Ikindi'] as String?) ?? '',
      aksam: (json['Aksam'] as String?) ?? '',
      yatsi: (json['Yatsi'] as String?) ?? '',
      miladiTarihKisa: (json['MiladiTarihKisa'] as String?) ?? '',
    );
  }
}
