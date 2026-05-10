class DiyanetDistrict {
  final int id;
  final String ilceAdi;
  final String ilceAdiEn;

  DiyanetDistrict({
    required this.id,
    required this.ilceAdi,
    required this.ilceAdiEn,
  });

  factory DiyanetDistrict.fromJson(Map<String, dynamic> json) {
    return DiyanetDistrict(
      id: _parseId(json['IlceID']),
      ilceAdi: json['IlceAdi'] as String,
      ilceAdiEn: json['IlceAdiEn'] as String,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot parse IlceID: $value');
  }

  Map<String, dynamic> toJson() => {
    'IlceID': id,
    'IlceAdi': ilceAdi,
    'IlceAdiEn': ilceAdiEn,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DiyanetDistrict && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
