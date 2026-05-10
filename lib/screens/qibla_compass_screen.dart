import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../viewmodels/prayer_time_viewmodel.dart';
import '../services/location_service.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/strings.dart';
import '../widgets/compass_rose.dart';
import '../widgets/qibla_arrow.dart';
import '../widgets/warning_card.dart';
import '../widgets/banner_ad_container.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  /// Cumulative heading (not clamped to 0-360) so AnimatedRotation never
  /// animates the long way around when crossing the 0°/360° boundary.
  double _headingCumulative = 0;
  double _headingRaw = 0; // for display only (cardinal direction)
  double _qiblaDirection = 0;
  bool _isAuthorized = false;
  bool _hasLocation = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Eşik: 0.5 dereceden küçük değişimlerde setState çağırma (pil tasarrufu).
  static const double _headingThreshold = 0.5;

  void _updateHeading(double newRaw) {
    // Current angle in [0, 360)
    double currentAngle = _headingCumulative % 360;
    if (currentAngle < 0) currentAngle += 360;
    // Shortest angular diff
    double diff = newRaw - currentAngle;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    _headingCumulative += diff;
    _headingRaw = newRaw;
  }

  @override
  void initState() {
    super.initState();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startCompass() async {
    final permission = await LocationService.shared.checkPermission();
    _isAuthorized = LocationService.shared.isAuthorized(permission);

    if (!_isAuthorized) {
      setState(() {});
      return;
    }

    try {
      final position = await LocationService.shared.getCurrentPosition();
      _calculateQiblaDirection(position.latitude, position.longitude);
      _hasLocation = true;
    } catch (_) {}

    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading == null || !mounted) return;
      final newRaw = event.heading!;
      // Yalnızca eşik değeri aşıldığında rebuild yap
      double currentAngle = _headingCumulative % 360;
      if (currentAngle < 0) currentAngle += 360;
      double diff = (newRaw - currentAngle).abs();
      if (diff > 180) diff = 360 - diff;
      if (diff >= _headingThreshold) {
        setState(() => _updateHeading(newRaw));
      }
    });

    if (mounted) setState(() {});
  }

  void _calculateQiblaDirection(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    final lat1 = lat * pi / 180;
    final lon1 = lon * pi / 180;
    final lat2 = kaabaLat * pi / 180;
    final lon2 = kaabaLon * pi / 180;
    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    var bearing = atan2(y, x) * 180 / pi;
    bearing = (bearing + 360) % 360;

    _qiblaDirection = bearing;
  }

  String get _cardinalDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((_headingRaw + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(context),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back arrow row
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.textPrimary(context), size: 22),
                        ),
                      ],
                    ),
                  ),
                  // Header
                  Column(
                    children: [
                      Icon(
                        AppIcons.compass,
                        size: 50,
                        color: AppTheme.accentColor(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.qiblaCompass(vm.language),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      if (vm.selectedCity != null && vm.selectedDistrict != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            vm.locationLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),

                  // Compass (2 layers)
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      children: [
                        // Layer 1: Rotating compass rose
                        CompassRose(heading: _headingCumulative),
                        // Layer 2: Qibla arrow (independent rotation)
                        QiblaArrow(
                          heading: _headingCumulative,
                          qiblaDirection: _qiblaDirection,
                          language: vm.language,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Direction info
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              AppStrings.direction(vm.language),
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _cardinalDirection,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: AppTheme.divider(context),
                        ),
                        Column(
                          children: [
                            Text(
                              AppStrings.qibla(vm.language),
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_qiblaDirection.toStringAsFixed(0)}\u00B0',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Warnings
                  if (!_isAuthorized)
                    WarningCard(
                      icon: AppIcons.locationDenied,
                      message: AppStrings.locationPermWarning(vm.language),
                    ),
                  if (_isAuthorized && !_hasLocation)
                    WarningCard(
                      icon: AppIcons.gpsNotFixed,
                      message: AppStrings.gettingLocation(vm.language),
                      isLoading: true,
                    ),

                  const Spacer(),
                  const BannerAdContainer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
