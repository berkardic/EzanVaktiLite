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
  /// Cumulative heading so AnimatedRotation never wraps the long way around.
  double _headingCumulative = 0;
  double _headingRaw = 0;
  double _qiblaDirection = 0;
  bool _isAuthorized = false;
  bool _hasLocation = false;
  bool _noSensor = false;       // device has no compass hardware
  bool _needsCalibration = false; // Android: low magnetometer accuracy
  StreamSubscription<CompassEvent>? _compassSubscription;

  static const double _headingThreshold = 0.5;

  void _updateHeading(double newRaw, double? accuracy) {
    final currentAngle = _headingCumulative % 360;
    double diff = newRaw - (currentAngle < 0 ? currentAngle + 360 : currentAngle);
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    _headingCumulative += diff;
    _headingRaw = newRaw;

    // accuracy is in degrees on Android (lower = better).
    // Values > 45° or == -1 signal unreliable magnetometer.
    if (accuracy != null && accuracy != 0) {
      _needsCalibration = accuracy > 45 || accuracy < 0;
    }
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

    // Null stream means the device has no compass sensor (common on emulators).
    if (FlutterCompass.events == null) {
      setState(() => _noSensor = true);
      return;
    }

    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (!mounted) return;
      final newRaw = event.heading;
      if (newRaw == null) return;

      final currentAngle = _headingCumulative % 360;
      double diff = (newRaw - (currentAngle < 0 ? currentAngle + 360 : currentAngle)).abs();
      if (diff > 180) diff = 360 - diff;

      if (diff >= _headingThreshold) {
        setState(() => _updateHeading(newRaw, event.accuracy));
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
    _qiblaDirection = (bearing + 360) % 360;
  }

  String get _cardinalDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((_headingRaw + 22.5) / 45).floor() % 8];
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
                  Column(
                    children: [
                      Icon(AppIcons.compass, size: 50,
                          color: AppTheme.accentColor(context)),
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
                            style: TextStyle(fontSize: 14,
                                color: AppTheme.textSecondary(context)),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),

                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      children: [
                        CompassRose(heading: _headingCumulative),
                        QiblaArrow(
                          heading: _headingCumulative,
                          qiblaDirection: _qiblaDirection,
                          language: vm.language,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

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
                        Column(children: [
                          Text(AppStrings.direction(vm.language),
                              style: TextStyle(fontSize: 12,
                                  color: AppTheme.textSecondary(context))),
                          const SizedBox(height: 4),
                          Text(_cardinalDirection,
                              style: TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary(context))),
                        ]),
                        Container(width: 1, height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: AppTheme.divider(context)),
                        Column(children: [
                          Text(AppStrings.qibla(vm.language),
                              style: TextStyle(fontSize: 12,
                                  color: AppTheme.textSecondary(context))),
                          const SizedBox(height: 4),
                          Text('${_qiblaDirection.toStringAsFixed(0)}°',
                              style: const TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenAccent)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Warnings (stacked, only visible ones shown)
                  if (_noSensor)
                    WarningCard(
                      icon: Icons.sensors_off_rounded,
                      message: vm.language == 'tr'
                          ? 'Bu cihazda pusula sensörü bulunamadı.'
                          : vm.language == 'ar'
                              ? 'لا يوجد مستشعر بوصلة في هذا الجهاز.'
                              : 'No compass sensor found on this device.',
                    ),
                  if (!_noSensor && _needsCalibration)
                    WarningCard(
                      icon: Icons.explore_off_rounded,
                      message: vm.language == 'tr'
                          ? 'Pusula kalibrasyonu gerekiyor. Telefonu 8 şeklinde hareket ettirin.'
                          : vm.language == 'ar'
                              ? 'البوصلة تحتاج إلى معايرة. حرّك الهاتف على شكل رقم 8.'
                              : 'Compass needs calibration. Move your phone in a figure-8 pattern.',
                    ),
                  if (!_isAuthorized)
                    WarningCard(
                      icon: AppIcons.locationDenied,
                      message: AppStrings.locationPermWarning(vm.language),
                    ),
                  if (_isAuthorized && !_hasLocation && !_noSensor)
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
