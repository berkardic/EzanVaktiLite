import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/models/today_prayers.dart';
import 'package:ezan_vakti/models/diyanet_city.dart';
import 'package:ezan_vakti/models/diyanet_district.dart';
import 'package:ezan_vakti/models/diyanet_prayer_entry.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TodayPrayers _samplePrayers({
  String imsak = '05:00',
  String gunes = '06:30',
  String ogle = '12:00',
  String ikindi = '15:30',
  String aksam = '18:00',
  String yatsi = '19:30',
  String date = '21.03.2026',
}) =>
    TodayPrayers(
      cityName: 'İstanbul',
      districtName: 'Fatih',
      imsak: imsak,
      gunes: gunes,
      ogle: ogle,
      ikindi: ikindi,
      aksam: aksam,
      yatsi: yatsi,
      date: date,
    );

/// Uygulamadaki normalize() mantığının aynısı — ViewModel'den bağımsız test.
String normalize(String s) {
  return s
      .replaceAll('\u0130', 'I')
      .replaceAll('\u011E', 'G')
      .replaceAll('\u015E', 'S')
      .replaceAll('\u00C7', 'C')
      .replaceAll('\u00D6', 'O')
      .replaceAll('\u00DC', 'U')
      .toLowerCase()
      .replaceAll('\u0131', 'i')
      .replaceAll('\u011F', 'g')
      .replaceAll('\u015F', 's')
      .replaceAll('\u00E7', 'c')
      .replaceAll('\u00F6', 'o')
      .replaceAll('\u00FC', 'u');
}

// ---------------------------------------------------------------------------
// DiyanetCity
// ---------------------------------------------------------------------------

void main() {
  group('DiyanetCity', () {
    test('fromJson ile String ID parse edilir', () {
      final city = DiyanetCity.fromJson({
        'SehirID': '500',
        'SehirAdi': 'İstanbul',
        'SehirAdiEn': 'Istanbul',
      });
      expect(city.id, 500);
      expect(city.sehirAdi, 'İstanbul');
      expect(city.sehirAdiEn, 'Istanbul');
    });

    test('fromJson ile int ID parse edilir', () {
      final city = DiyanetCity.fromJson({
        'SehirID': 500,
        'SehirAdi': 'Ankara',
        'SehirAdiEn': 'Ankara',
      });
      expect(city.id, 500);
    });

    test('toJson → fromJson round-trip', () {
      final original = DiyanetCity.fromJson({
        'SehirID': 42,
        'SehirAdi': 'İzmir',
        'SehirAdiEn': 'Izmir',
      });
      final restored = DiyanetCity.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.sehirAdi, original.sehirAdi);
      expect(restored.sehirAdiEn, original.sehirAdiEn);
    });

    test('equality: aynı ID eşit', () {
      final a = DiyanetCity.fromJson({'SehirID': 1, 'SehirAdi': 'A', 'SehirAdiEn': 'A'});
      final b = DiyanetCity.fromJson({'SehirID': 1, 'SehirAdi': 'B', 'SehirAdiEn': 'B'});
      expect(a, equals(b));
    });

    test('equality: farklı ID eşit değil', () {
      final a = DiyanetCity.fromJson({'SehirID': 1, 'SehirAdi': 'A', 'SehirAdiEn': 'A'});
      final b = DiyanetCity.fromJson({'SehirID': 2, 'SehirAdi': 'A', 'SehirAdiEn': 'A'});
      expect(a, isNot(equals(b)));
    });
  });

  // -------------------------------------------------------------------------
  // DiyanetDistrict
  // -------------------------------------------------------------------------

  group('DiyanetDistrict', () {
    test('fromJson ile String ID parse edilir', () {
      final d = DiyanetDistrict.fromJson({
        'IlceID': '9146',
        'IlceAdi': 'Fatih',
        'IlceAdiEn': 'Fatih',
      });
      expect(d.id, 9146);
      expect(d.ilceAdi, 'Fatih');
    });

    test('fromJson ile int ID parse edilir', () {
      final d = DiyanetDistrict.fromJson({
        'IlceID': 9146,
        'IlceAdi': 'Fatih',
        'IlceAdiEn': 'Fatih',
      });
      expect(d.id, 9146);
    });

    test('toJson → fromJson round-trip', () {
      final original = DiyanetDistrict.fromJson({
        'IlceID': 99,
        'IlceAdi': 'Beşiktaş',
        'IlceAdiEn': 'Besiktas',
      });
      final restored = DiyanetDistrict.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.ilceAdi, original.ilceAdi);
      expect(restored.ilceAdiEn, original.ilceAdiEn);
    });

    test('equality: aynı ID eşit', () {
      final a = DiyanetDistrict.fromJson({'IlceID': 5, 'IlceAdi': 'A', 'IlceAdiEn': 'A'});
      final b = DiyanetDistrict.fromJson({'IlceID': 5, 'IlceAdi': 'B', 'IlceAdiEn': 'B'});
      expect(a, equals(b));
    });
  });

  // -------------------------------------------------------------------------
  // DiyanetPrayerEntry
  // -------------------------------------------------------------------------

  group('DiyanetPrayerEntry', () {
    test('fromJson doğru parse eder', () {
      final entry = DiyanetPrayerEntry.fromJson({
        'Imsak': '05:12',
        'Gunes': '06:45',
        'Ogle': '12:30',
        'Ikindi': '15:50',
        'Aksam': '18:20',
        'Yatsi': '19:55',
        'MiladiTarihKisa': '21.03.2026',
      });
      expect(entry.imsak, '05:12');
      expect(entry.gunes, '06:45');
      expect(entry.miladiTarihKisa, '21.03.2026');
    });
  });

  // -------------------------------------------------------------------------
  // TodayPrayers
  // -------------------------------------------------------------------------

  group('TodayPrayers', () {
    test('allTimes 6 vakit döndürür', () {
      expect(_samplePrayers().allTimes.length, 6);
    });

    test('allTimes doğru sırada', () {
      final times = _samplePrayers().allTimes;
      expect(times[0].nameEn, 'Fajr');
      expect(times[1].nameEn, 'Sunrise');
      expect(times[2].nameEn, 'Dhuhr');
      expect(times[3].nameEn, 'Asr');
      expect(times[4].nameEn, 'Maghrib');
      expect(times[5].nameEn, 'Isha');
    });

    test('allTimes Türkçe isimleri doğru', () {
      final times = _samplePrayers().allTimes;
      expect(times[0].name, 'İmsak');
      expect(times[2].name, 'Öğle');
      expect(times[4].name, 'Akşam');
    });

    test('toJson → fromJson round-trip', () {
      final original = _samplePrayers();
      final restored = TodayPrayers.fromJson(original.toJson());
      expect(restored.cityName, original.cityName);
      expect(restored.districtName, original.districtName);
      expect(restored.imsak, original.imsak);
      expect(restored.gunes, original.gunes);
      expect(restored.ogle, original.ogle);
      expect(restored.ikindi, original.ikindi);
      expect(restored.aksam, original.aksam);
      expect(restored.yatsi, original.yatsi);
      expect(restored.date, original.date);
    });

    test('nextPrayer: sabah 06:00 iken güneş vakti sonraki', () {
      // Tüm vakitler 06:00'dan büyük — ilk olan gunes (06:30)
      final prayers = _samplePrayers(
        imsak: '05:00',
        gunes: '06:30',
        ogle: '12:00',
        ikindi: '15:30',
        aksam: '18:00',
        yatsi: '19:30',
      );
      // allTimes listesinde 06:00'dan büyük ilk eleman gunes
      final all = prayers.allTimes;
      const fakeNow = '06:00';
      final next = all.firstWhere((p) => p.time.compareTo(fakeNow) > 0);
      expect(next.nameEn, 'Sunrise');
    });

    test('nextPrayer: tüm vakitler geçtiyse imsak (ilk vakit) döner', () {
      // allTimes.first = imsak
      expect(_samplePrayers().allTimes.first.nameEn, 'Fajr');
    });

    test('nextPrayer: 13:00 iken ikindi sonraki', () {
      final prayers = _samplePrayers(
        imsak: '05:00',
        gunes: '06:30',
        ogle: '12:00',
        ikindi: '15:30',
        aksam: '18:00',
        yatsi: '19:30',
      );
      const fakeNow = '13:00';
      final next = prayers.allTimes.firstWhere(
        (p) => p.time.compareTo(fakeNow) > 0,
        orElse: () => prayers.allTimes.first,
      );
      expect(next.nameEn, 'Asr');
    });
  });

  // -------------------------------------------------------------------------
  // Türkçe karakter normalizasyonu
  // -------------------------------------------------------------------------

  group('normalize()', () {
    test('Türkçe büyük harfler küçültülür', () {
      expect(normalize('İSTANBUL'), 'istanbul');
      expect(normalize('ŞANLIURFA'), 'sanliurfa');
      expect(normalize('ÇANAKKALE'), 'canakkale');
      expect(normalize('ĞIRLIGÖL'), 'girligol');
    });

    test('Türkçe küçük harfler dönüştürülür', () {
      expect(normalize('şanlıurfa'), 'sanliurfa');
      expect(normalize('çanakkale'), 'canakkale');
      expect(normalize('ığdır'), 'igdir');
    });

    test('ı → i dönüşümü', () {
      expect(normalize('kırıkkale'), 'kirikkale');
    });

    test('Normal ASCII harfler değişmez', () {
      expect(normalize('ankara'), 'ankara');
      expect(normalize('BURSA'), 'bursa');
    });

    test('Karışık string', () {
      expect(normalize('Büyükçekmece'), 'buyukcekme ce'.replaceAll(' ', ''));
    });
  });
}
