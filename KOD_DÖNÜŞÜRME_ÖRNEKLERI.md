# 🔄 Swift → Dart Kod Dönüştürme Örnekleri

## 1. MODEL DÖNÜŞTÜRMELERI

### Swift: Models.swift + DiyanetService.swift
```swift
struct DiyanetCity: Codable {
    let id: Int
    let name: String
}

struct DiyanetDistrict: Codable {
    let id: Int
    let name: String
}

struct TodayPrayers: Codable {
    let city: String
    let district: String
    let GregorianDate: String
    let HijriDate: String
    let Imsak: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
```

### Dart: models/prayer_time.dart
```dart
class DiyanetCity {
  final int id;
  final String name;

  DiyanetCity({required this.id, required this.name});

  factory DiyanetCity.fromJson(Map<String, dynamic> json) {
    return DiyanetCity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class DiyanetDistrict {
  final int id;
  final String name;

  DiyanetDistrict({required this.id, required this.name});

  factory DiyanetDistrict.fromJson(Map<String, dynamic> json) {
    return DiyanetDistrict(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class TodayPrayers {
  final String city;
  final String district;
  final String gregorianDate;
  final String hijriDate;
  final String imsak;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  TodayPrayers({
    required this.city,
    required this.district,
    required this.gregorianDate,
    required this.hijriDate,
    required this.imsak,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory TodayPrayers.fromJson(Map<String, dynamic> json) {
    return TodayPrayers(
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      gregorianDate: json['GregorianDate'] ?? '',
      hijriDate: json['HijriDate'] ?? '',
      imsak: json['Imsak'] ?? '',
      sunrise: json['Sunrise'] ?? '',
      dhuhr: json['Dhuhr'] ?? '',
      asr: json['Asr'] ?? '',
      maghrib: json['Maghrib'] ?? '',
      isha: json['Isha'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'district': district,
        'GregorianDate': gregorianDate,
        'HijriDate': hijriDate,
        'Imsak': imsak,
        'Sunrise': sunrise,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
      };
}
```

---

## 2. SERVICE DÖNÜŞTÜRMELERI

### Swift: DiyanetService.swift (Async)
```swift
class DiyanetService {
    static let baseURL = "https://vakit.rnvzr.io/api/timezoneByCity/"
    
    static func getCities() async throws -> [DiyanetCity] {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([DiyanetCity].self, from: data)
    }
}
```

### Dart: services/diyanet_service.dart (Async/Await)
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/prayer_time.dart';

class DiyanetService {
  static const String baseUrl = 'https://vakit.rnvzr.io/api/timezoneByCity/';

  static Future<List<DiyanetCity>> getCities() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((city) => DiyanetCity.fromJson(city as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching cities: $e');
      return [];
    }
  }
}
```

---

## 3. VIEW MODEL DÖNÜŞTÜRMELERI

### Swift: PrayerTimeViewModel (ObservableObject)
```swift
@MainActor
class PrayerTimeViewModel: ObservableObject {
    @Published var prayers: [Prayer] = []
    @Published var selectedCity: City?
    @Published var selectedDistrict: District?
    @Published var isLoading = false
    
    func loadPrayers(cityId: Int, districtId: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let prayers = try await DiyanetService.getPrayers(cityId, districtId)
            self.prayers = prayers
        } catch {
            print("Error: \(error)")
        }
    }
}
```

### Dart: providers/prayer_time_provider.dart (ChangeNotifier)
```dart
import 'package:flutter/foundation.dart';
import '../models/prayer_time.dart';
import '../services/diyanet_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  List<PrayerTime> prayers = [];
  DiyanetCity? selectedCity;
  DiyanetDistrict? selectedDistrict;
  bool isLoading = false;

  Future<void> loadPrayers(int cityId, int districtId) async {
    isLoading = true;
    notifyListeners();

    try {
      final todayPrayers = await DiyanetService.getPrayerTimes(cityId, districtId);
      if (todayPrayers != null) {
        prayers = todayPrayers.getPrayersList();
      }
    } catch (e) {
      debugPrint('Error loading prayers: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCity(DiyanetCity city) {
    selectedCity = city;
    notifyListeners();
  }

  void selectDistrict(DiyanetDistrict district) {
    selectedDistrict = district;
    notifyListeners();
  }
}
```

---

## 4. LOCATION SERVICE DÖNÜŞTÜRMELERI

### Swift: LocationManager (CLLocationManager)
```swift
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    
    func requestLocation() async -> Bool {
        let status = await locationManager.requestWhenInUseAuthorization()
        return status == .authorizedWhenInUse
    }
    
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        locationManager.delegate = self
        locationManager.requestLocation()
        
        // Wait for delegate callback
        return try await withCheckedThrowingContinuation { continuation in
            // Implementation
        }
    }
}
```

### Dart: services/location_service.dart (geolocator package)
```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result != LocationPermission.denied &&
          result != LocationPermission.deniedForever;
    }
    return permission != LocationPermission.deniedForever;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }
}
```

---

## 5. UI DÖNÜŞTÜRMELERI

### Swift: ContentView (SwiftUI)
```swift
struct ContentView: View {
    @EnvironmentObject var viewModel: PrayerTimeViewModel
    
    var body: some View {
        ZStack {
            IslamicBackground()
            
            VStack {
                HeaderView()
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    PrayerTimesGrid()
                }
            }
        }
    }
}
```

### Dart: screens/home_screen.dart (Flutter)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_time_provider.dart';
import '../widgets/islamic_background.dart';
import '../widgets/prayer_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const IslamicBackground(),
          Consumer<PrayerTimeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return PrayerGrid(prayers: provider.prayers);
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 6. NOTIFICATION DÖNÜŞTÜRMELERI

### Swift: NotificationManager
```swift
class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    func requestPermission() async -> Bool {
        return try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleNotification(
        title: String,
        body: String,
        at: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(...)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

### Dart: services/notification_service.dart
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'Namaz Vakti: $prayerName',
      'Namaz vakti geldi!',
      tz.TZDateTime.from(prayerTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Times',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(sound: 'Default'),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
```

---

## 🎯 ÖZETLİ DÖNÜŞTÜRME DÖNÜŞÜMLERİ

| Kavram | Swift | Dart |
|--------|-------|------|
| Observable State | @Published | notifyListeners() |
| Async Operations | async throws | Future + try-catch |
| Network Request | URLSession | http package |
| Lifecycle Hooks | onAppear | initState() / lifecycle |
| Binding | @Binding | Provider |
| Conditional UI | if-else | ternary / if statements |
| Lists | Array | List |
| Closures | { } | => lambda |

---

**Dönüştürme Tarihi:** 03 Mart 2026
