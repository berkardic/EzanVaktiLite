class DiyanetCountry {
  final int id;
  final String ulkeAdi;
  final String ulkeAdiEn;

  const DiyanetCountry({
    required this.id,
    required this.ulkeAdi,
    required this.ulkeAdiEn,
  });

  factory DiyanetCountry.fromJson(Map<String, dynamic> json) {
    return DiyanetCountry(
      id: int.tryParse(json['UlkeID']?.toString() ?? '') ?? 0,
      ulkeAdi: json['UlkeAdi'] ?? '',
      ulkeAdiEn: json['UlkeAdiEn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'UlkeID': id.toString(),
        'UlkeAdi': ulkeAdi,
        'UlkeAdiEn': ulkeAdiEn,
      };

  @override
  bool operator ==(Object other) => other is DiyanetCountry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
