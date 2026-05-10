class DiyanetCity {
  final int id;
  final String sehirAdi;
  final String sehirAdiEn;

  DiyanetCity({
    required this.id,
    required this.sehirAdi,
    required this.sehirAdiEn,
  });

  factory DiyanetCity.fromJson(Map<String, dynamic> json) {
    return DiyanetCity(
      id: _parseId(json['SehirID']),
      sehirAdi: json['SehirAdi'] as String,
      sehirAdiEn: json['SehirAdiEn'] as String,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot parse SehirID: $value');
  }

  Map<String, dynamic> toJson() => {
    'SehirID': id,
    'SehirAdi': sehirAdi,
    'SehirAdiEn': sehirAdiEn,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DiyanetCity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
