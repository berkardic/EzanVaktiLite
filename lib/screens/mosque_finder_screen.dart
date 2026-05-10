import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' show Distance, LengthUnit;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../services/location_service.dart';
import '../widgets/banner_ad_container.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------
class _Mosque {
  final double lat;
  final double lng;
  final String name;
  double distanceMeters;

  _Mosque({
    required this.lat,
    required this.lng,
    required this.name,
    this.distanceMeters = 0,
  });

  String get displayName => name.isNotEmpty ? name : 'Cami / Mescit';

  String get distanceStr {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class MosqueFinderScreen extends StatefulWidget {
  final String language;
  const MosqueFinderScreen({super.key, required this.language});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

// Uygulama oturumu boyunca geçerli bellek önbelleği
class _MosqueCache {
  static List<_Mosque>? mosques;
  static double? lat;
  static double? lng;
  static DateTime? fetchedAt;

  static bool isValid(double newLat, double newLng) {
    if (mosques == null || fetchedAt == null || lat == null) return false;
    // 15 dakikadan eskiyse veya 2km'den uzaksa geçersiz
    if (DateTime.now().difference(fetchedAt!).inMinutes > 15) return false;
    final dist = const Distance().as(LengthUnit.Meter,
        LatLng(lat!, lng!), LatLng(newLat, newLng));
    return dist < 2000;
  }
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final MapController _mapController = MapController();
  Position? _userPos;
  List<_Mosque> _mosques = [];
  bool _isLoading = true;
  bool _isRefreshing = false; // arka plan yenileme — hata göstermez
  String? _error;
  _Mosque? _selected;

  String _l(String tr, String en, [String? ar]) {
    if (widget.language == 'en') return en;
    if (widget.language == 'ar') return ar ?? en;
    return tr;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = _mosques.isEmpty;
      _error = null;
    });

    try {
      final permission = await LocationService.shared.checkPermission();
      if (!LocationService.shared.isAuthorized(permission)) {
        final req = await LocationService.shared.requestPermission();
        if (!LocationService.shared.isAuthorized(req)) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _error = _l(
              'Konum izni verilmedi. Lütfen ayarlardan izin verin.',
              'Location permission denied. Please enable it in Settings.',
              'تم رفض إذن الموقع. يرجى تفعيله من الإعدادات.',
            );
          });
          return;
        }
      }

      final pos = await LocationService.shared.getCurrentPosition();
      if (!mounted) return;
      setState(() => _userPos = pos);

      // Önbellekte geçerli veri varsa hemen göster, arka planda yenile
      if (!forceRefresh && _MosqueCache.isValid(pos.latitude, pos.longitude)) {
        setState(() {
          _mosques = _MosqueCache.mosques!;
          _isLoading = false;
        });
        try { _mapController.move(LatLng(pos.latitude, pos.longitude), 14.5); } catch (_) {}
        // Arka planda sessizce yenile
        _refreshInBackground(pos.latitude, pos.longitude);
        return;
      }

      if (Platform.isIOS) {
        await _fetchMosquesIOS(pos.latitude, pos.longitude);
      } else {
        await _fetchMosques(pos.latitude, pos.longitude);
      }
    } catch (e) {
      if (!mounted) return;
      // Önbellekte veri varsa hatayı gösterme
      if (_MosqueCache.mosques != null) {
        setState(() {
          _mosques = _MosqueCache.mosques!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = _l(
            'Konum alınamadı. Lütfen tekrar deneyin.',
            'Could not get location. Please try again.',
            'تعذر الحصول على الموقع. يرجى المحاولة مرة أخرى.',
          );
        });
      }
    }
  }

  Future<void> _refreshInBackground(double lat, double lng) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    if (Platform.isIOS) {
      await _fetchMosquesIOS(lat, lng, silent: true);
    } else {
      await _fetchMosques(lat, lng, silent: true);
    }
    _isRefreshing = false;
  }

  static const _mosqueChannel = MethodChannel('com.yba.ezanvakti/mosque_finder');

  static const _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.openstreetmap.fr/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  Future<void> _fetchMosquesIOS(double lat, double lng, {bool silent = false}) async {
    if (!silent && mounted) setState(() => _isLoading = true);

    try {
      final List<dynamic> items = await _mosqueChannel.invokeMethod(
        'findNearby',
        {'lat': lat, 'lng': lng},
      );

      final mosques = <_Mosque>[];
      for (final item in items) {
        final m = Map<Object?, Object?>.from(item as Map);
        final mLat = (m['lat'] as num).toDouble();
        final mLng = (m['lng'] as num).toDouble();
        final name = (m['name'] as String?) ?? '';
        final dist = Geolocator.distanceBetween(lat, lng, mLat, mLng);
        mosques.add(_Mosque(lat: mLat, lng: mLng, name: name, distanceMeters: dist));
      }

      mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      _MosqueCache.mosques = mosques;
      _MosqueCache.lat = lat;
      _MosqueCache.lng = lng;
      _MosqueCache.fetchedAt = DateTime.now();

      if (!mounted) return;
      setState(() {
        _mosques = mosques;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('[MosqueFinder] iOS MKLocalSearch hatası (${e.runtimeType}): $e\n$st');
      // MKLocalSearch başarısız — Overpass ile yeniden dene
      await _fetchMosques(lat, lng, silent: silent);
      return;
    }

    try {
      _mapController.move(LatLng(lat, lng), 14.5);
    } catch (e) {
      debugPrint('[MosqueFinder] mapController.move hatası: $e');
    }
  }

  Future<void> _fetchMosques(double lat, double lng, {bool silent = false}) async {
    if (!silent && mounted) setState(() => _isLoading = true);

    final query = '''
[out:json][timeout:30];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:3000,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:3000,$lat,$lng);
);
out center;
''';

    Object? lastError;
    Response<dynamic>? response;

    for (final endpoint in _overpassEndpoints) {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'User-Agent': 'EzanVaktiApp/1.0 (Flutter; iOS)'},
        ));
        response = await dio.post(
          endpoint,
          data: 'data=${Uri.encodeComponent(query)}',
          options: Options(contentType: 'application/x-www-form-urlencoded'),
        );
        debugPrint('[MosqueFinder] $endpoint başarılı (${response?.statusCode})');
        break;
      } catch (e) {
        if (e is DioException) {
          debugPrint('[MosqueFinder] $endpoint DioError type=${e.type} status=${e.response?.statusCode} msg=${e.message}');
        } else {
          debugPrint('[MosqueFinder] $endpoint hatası (${e.runtimeType}): $e');
        }
        lastError = e;
      }
    }

    if (response == null) {
      final errDetail = lastError is DioException
          ? 'DioErr type=${(lastError as DioException).type}'
          : lastError?.runtimeType.toString() ?? 'null';
      debugPrint('[MosqueFinder] Tüm endpointler başarısız: $errDetail — $lastError');
      if (!mounted) return;
      // Önbellekte veri varsa hata gösterme — sessizce eski veriyi bırak
      if (_MosqueCache.mosques != null && _mosques.isNotEmpty) {
        if (!silent) setState(() => _isLoading = false);
        return;
      }
      if (!silent) {
        setState(() {
          _isLoading = false;
          _error = _l(
            'Camiler şu an yüklenemiyor. Lütfen tekrar deneyin.',
            'Could not load mosques. Please try again.',
            'تعذر تحميل المساجد. يرجى المحاولة مرة أخرى.',
          );
        });
      }
      return;
    }

    try {
      final elements = (response.data as Map<String, dynamic>)['elements'] as List<dynamic>;
      final mosques = <_Mosque>[];

      for (final e in elements) {
        double? elLat;
        double? elLng;

        if (e['type'] == 'node') {
          elLat = (e['lat'] as num).toDouble();
          elLng = (e['lon'] as num).toDouble();
        } else if (e['type'] == 'way' && e['center'] != null) {
          elLat = (e['center']['lat'] as num).toDouble();
          elLng = (e['center']['lon'] as num).toDouble();
        }

        if (elLat == null || elLng == null) continue;

        final tags = e['tags'] as Map<String, dynamic>? ?? {};
        final name = (tags['name:tr'] ?? tags['name'] ?? '') as String;

        final dist = Geolocator.distanceBetween(lat, lng, elLat, elLng);
        mosques.add(_Mosque(lat: elLat, lng: elLng, name: name, distanceMeters: dist));
      }

      mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      // Önbelleği güncelle
      _MosqueCache.mosques = mosques;
      _MosqueCache.lat = lat;
      _MosqueCache.lng = lng;
      _MosqueCache.fetchedAt = DateTime.now();

      if (!mounted) return;
      setState(() {
        _mosques = mosques;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[MosqueFinder] Veri işleme hatası: $e');
      if (!mounted || silent) return;
      if (_mosques.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = _l(
            'Camiler şu an yüklenemiyor. Lütfen tekrar deneyin.',
            'Could not load mosques. Please try again.',
            'تعذر تحميل المساجد. يرجى المحاولة مرة أخرى.',
          );
        });
      } else {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      _mapController.move(LatLng(lat, lng), 14.5);
    } catch (e) {
      debugPrint('[MosqueFinder] mapController.move hatası: $e');
    }
  }

  void _showDirectionsSheet(_Mosque mosque) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DirectionsSheet(mosque: mosque, language: widget.language),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userLatLng = _userPos != null
        ? LatLng(_userPos!.latitude, _userPos!.longitude)
        : const LatLng(39.92, 32.85); // Ankara fallback

    return Scaffold(
      backgroundColor: AppTheme.isDark(context) ? const Color(0xFF0D1F40) : AppColors.lightBgBottom,
      body: Stack(
        children: [
          // ── Harita ──────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 14.5,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.yba.ezanvakti',
              ),

              // Cami işaretleri
              MarkerLayer(
                markers: _mosques.map((m) {
                  final isSelected = _selected == m;
                  return Marker(
                    point: LatLng(m.lat, m.lng),
                    width: isSelected ? 48 : 38,
                    height: isSelected ? 48 : 38,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = m),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.greenButton
                              : const Color(0xFF2E7D52),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.greenAccent
                                : Colors.white.withOpacity(0.6),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mosque_rounded,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                          size: isSelected ? 26 : 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Kullanıcı konumu
              if (_userPos != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLatLng,
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.15),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Üst bar ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Geri butonu
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.sheetBg(context).withOpacity(0.95),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPrimary(context),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Başlık
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.sheetBg(context).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mosque_rounded,
                              color: AppColors.greenAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _l('Cami Bulucu', 'Mosque Finder', 'الباحث عن المساجد'),
                            style: TextStyle(
                              color: AppTheme.textPrimary(context),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!_isLoading && _mosques.isNotEmpty)
                            Text(
                              _l('${_mosques.length} yer', '${_mosques.length} found', '${_mosques.length} مسجد'),
                              style: TextStyle(
                                color: AppColors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Yenile butonu
                  GestureDetector(
                    onTap: _isLoading ? null : () => _init(forceRefresh: true),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.sheetBg(context).withOpacity(0.95),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                color: AppColors.greenAccent,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.textPrimary(context),
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Hata ekranı ─────────────────────────────────────────────────
          if (_error != null && !_isLoading)
            Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.sheetBg(context).withOpacity(0.97),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider(context)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_rounded,
                        color: AppTheme.textSecondary(context), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _init,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenButton,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_l('Tekrar Dene', 'Retry', 'إعادة المحاولة')),
                    ),
                  ],
                ),
              ),
            ),

          // ── Reklam bandı ────────────────────────────────────────────────
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BannerAdContainer(),
          ),

          // ── Seçili cami kartı ────────────────────────────────────────────
          if (_selected != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: _SelectedMosqueCard(
                mosque: _selected!,
                language: widget.language,
                onDirections: () => _showDirectionsSheet(_selected!),
                onClose: () => setState(() => _selected = null),
              ),
            )
          // ── Alt cami listesi ─────────────────────────────────────────────
          else if (!_isLoading && _error == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: _MosqueListPanel(
                mosques: _mosques,
                language: widget.language,
                onTap: (m) {
                  setState(() => _selected = m);
                  _mapController.move(LatLng(m.lat, m.lng), 16);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seçili cami kartı
// ---------------------------------------------------------------------------
class _SelectedMosqueCard extends StatelessWidget {
  final _Mosque mosque;
  final String language;
  final VoidCallback onDirections;
  final VoidCallback onClose;

  const _SelectedMosqueCard({
    required this.mosque,
    required this.language,
    required this.onDirections,
    required this.onClose,
  });

  String _l(String tr, String en, [String? ar]) {
    if (language == 'en') return en;
    if (language == 'ar') return ar ?? en;
    return tr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.sheetBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greenAccent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenButton.withOpacity(0.2),
                ),
                child: Icon(Icons.mosque_rounded,
                    color: AppColors.greenAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.displayName,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_l('Uzaklık', 'Distance', 'المسافة')}: ${mosque.distanceStr}',
                      style: TextStyle(
                        color: AppColors.greenAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardBg(context),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: AppTheme.textPrimary(context), size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.directions_rounded, size: 20),
              label: Text(_l('Yol Tarifi Al', 'Get Directions', 'الحصول على الاتجاهات')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenButton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Alt cami listesi paneli
// ---------------------------------------------------------------------------
class _MosqueListPanel extends StatelessWidget {
  final List<_Mosque> mosques;
  final String language;
  final void Function(_Mosque) onTap;

  const _MosqueListPanel({
    required this.mosques,
    required this.language,
    required this.onTap,
  });

  String _l(String tr, String en, [String? ar]) {
    if (language == 'en') return en;
    if (language == 'ar') return ar ?? en;
    return tr;
  }

  @override
  Widget build(BuildContext context) {
    if (mosques.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.sheetBg(context).withOpacity(0.97),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider(context)),
        ),
        child: Text(
          _l('Yakında cami bulunamadı (3 km içinde).', 'No mosques found nearby (within 3 km).', 'لم يتم العثور على مساجد قريبة (في نطاق 3 كم).'),
          style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    final displayList = mosques.take(8).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: AppTheme.sheetBg(context).withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.mosque_rounded,
                    color: AppColors.greenAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  _l('Yakındaki İbadet Yerleri', 'Nearby Places of Worship', 'أماكن العبادة القريبة'),
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              scrollDirection: Axis.horizontal,
              itemCount: displayList.length,
              itemBuilder: (context, i) {
                final m = displayList[i];
                return GestureDetector(
                  onTap: () => onTap(m),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greenButton.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.greenAccent.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.greenButton.withOpacity(0.3),
                          ),
                          child: Icon(Icons.mosque_rounded,
                              color: AppColors.greenButton, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m.displayName,
                          style: TextStyle(
                            color: AppTheme.textPrimary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.near_me_rounded,
                                color: AppColors.greenButton, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              m.distanceStr,
                              style: TextStyle(
                                color: AppColors.greenButton,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Yol tarifi seçim sayfası
// ---------------------------------------------------------------------------
class _DirectionsSheet extends StatelessWidget {
  final _Mosque mosque;
  final String language;

  const _DirectionsSheet({required this.mosque, required this.language});

  String _l(String tr, String en, [String? ar]) {
    if (language == 'en') return en;
    if (language == 'ar') return ar ?? en;
    return tr;
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = mosque.lat;
    final lng = mosque.lng;

    final options = [
      (
        label: 'Google Maps',
        icon: Icons.map_rounded,
        color: const Color(0xFF4285F4),
        url: 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
      ),
      (
        label: 'Apple Maps',
        icon: Icons.map_outlined,
        color: const Color(0xFF34AADC),
        url: 'maps://?daddr=$lat,$lng&dirflg=w',
      ),
      (
        label: 'Yandex Haritalar',
        icon: Icons.navigation_rounded,
        color: const Color(0xFFFF6600),
        url: 'https://yandex.com.tr/maps/?rtext=~$lat,$lng&rtt=pd',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.sheetBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l('Harita Uygulaması Seç', 'Choose Map App', 'اختر تطبيق الخريطة'),
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mosque.displayName,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ...options.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _launch(opt.url);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: opt.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: opt.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(opt.icon, color: opt.color, size: 24),
                      const SizedBox(width: 14),
                      Text(
                        opt.label,
                        style: TextStyle(
                          color: AppTheme.textPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textPrimary(context).withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
