import 'package:flutter/material.dart';
import '../constants/icons.dart';
import 'package:intl/intl.dart';

class PrayerTime {
  final String name;
  final String nameEn;
  final String time;
  final IconData icon;

  PrayerTime({
    required this.name,
    required this.nameEn,
    required this.time,
    required this.icon,
  });
}

class TodayPrayers {
  final String cityName;
  final String districtName;
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;
  final String date;

  TodayPrayers({
    required this.cityName,
    required this.districtName,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
    required this.date,
  });

  List<PrayerTime> get allTimes => [
        PrayerTime(name: 'İmsak', nameEn: 'Fajr', time: imsak, icon: AppIcons.fajr),
        PrayerTime(name: 'Güneş', nameEn: 'Sunrise', time: gunes, icon: AppIcons.sunrise),
        PrayerTime(name: 'Öğle', nameEn: 'Dhuhr', time: ogle, icon: AppIcons.dhuhr),
        PrayerTime(name: 'İkindi', nameEn: 'Asr', time: ikindi, icon: AppIcons.asr),
        PrayerTime(name: 'Akşam', nameEn: 'Maghrib', time: aksam, icon: AppIcons.maghrib),
        PrayerTime(name: 'Yatsı', nameEn: 'Isha', time: yatsi, icon: AppIcons.isha),
      ];

  Map<String, dynamic> toJson() => {
    'cityName': cityName,
    'districtName': districtName,
    'imsak': imsak,
    'gunes': gunes,
    'ogle': ogle,
    'ikindi': ikindi,
    'aksam': aksam,
    'yatsi': yatsi,
    'date': date,
  };

  factory TodayPrayers.fromJson(Map<String, dynamic> json) => TodayPrayers(
    cityName: json['cityName'] as String,
    districtName: json['districtName'] as String,
    imsak: json['imsak'] as String,
    gunes: json['gunes'] as String,
    ogle: json['ogle'] as String,
    ikindi: json['ikindi'] as String,
    aksam: json['aksam'] as String,
    yatsi: json['yatsi'] as String,
    date: json['date'] as String,
  );

  PrayerTime? nextPrayer() {
    final now = DateFormat('HH:mm').format(DateTime.now());
    for (final p in allTimes) {
      if (p.time.compareTo(now) > 0) return p;
    }
    return allTimes.first;
  }
}
