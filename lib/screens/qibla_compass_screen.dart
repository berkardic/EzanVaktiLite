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

// accuracy constants from flutter_compass Android plugin:
// HIGH=15, MEDIUM=30, LOW=45, UNRELIABLE=-1
// 0 = Java default before first onAccuracyChanged fires (treat as unreliable)
const double _kHigh = 15;
const double _kMedium = 30;

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  double _headingCumulative = 0;
  double _headingRaw = 0;
  double _qiblaDirection = 0;
  bool _isAuthorized = false;
  bool _hasLocation = false;
  bool _noSensor = false;
  bool _calibrationShownThisSession = false;

  // ValueNotifier lets the dialog and calibration button react to accuracy
  // changes without subscribing to FlutterCompass.events a second time
  // (EventChannel = single-listener stream).
  final ValueNotifier<double> _accuracyNotifier = ValueNotifier(0);

  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _calibrationCheckTimer;

  static const double _headingThreshold = 0.5;

  bool _needsCalibration(double a) => a <= 0 || a >= _kMedium;

  @override
  void initState() {
    super.initState();
    _accuracyNotifier.addListener(_onAccuracyChanged);
    _startCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _calibrationCheckTimer?.cancel();
    _accuracyNotifier.removeListener(_onAccuracyChanged);
    _accuracyNotifier.dispose();
    super.dispose();
  }

  // Called every time accuracy changes. Shows calibration dialog once per
  // session if accuracy is bad, with a small delay so the UI is fully built.
  void _onAccuracyChanged() {
    if (_calibrationShownThisSession) return;
    if (!_needsCalibration(_accuracyNotifier.value)) return;
    if (!_isAuthorized || _noSensor || !mounted) return;

    _calibrationShownThisSession = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _showCalibrationDialog();
    });
  }

  Future<void> _startCompass() async {
    var permission = await LocationService.shared.checkPermission();
    if (!LocationService.shared.isAuthorized(permission)) {
      permission = await LocationService.shared.requestPermission();
    }
    _isAuthorized = LocationService.shared.isAuthorized(permission);

    if (!_isAuthorized) {
      if (mounted) setState(() {});
      return;
    }

    // Fetch location (non-blocking for compass start)
    LocationService.shared.getCurrentPosition().then((pos) {
      _calculateQiblaDirection(pos.latitude, pos.longitude);
      if (mounted) setState(() => _hasLocation = true);
    }).catchError((_) {});

    if (FlutterCompass.events == null) {
      if (mounted) setState(() => _noSensor = true);
      return;
    }

    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (!mounted) return;
      final newRaw = event.heading;
      if (newRaw == null) return;

      final currentAngle = _headingCumulative % 360;
      final normalised = currentAngle < 0 ? currentAngle + 360 : currentAngle;
      double diff = (newRaw - normalised).abs();
      if (diff > 180) diff = 360 - diff;

      bool changed = false;
      if (diff >= _headingThreshold) {
        double delta = newRaw - normalised;
        if (delta > 180) delta -= 360;
        if (delta < -180) delta += 360;
        _headingCumulative += delta;
        _headingRaw = newRaw;
        changed = true;
      }
      if (changed) setState(() {});

      // Update accuracy notifier (triggers _onAccuracyChanged listener)
      if (event.accuracy != null && event.accuracy != _accuracyNotifier.value) {
        _accuracyNotifier.value = event.accuracy!;
      }
    });

    if (mounted) setState(() {});

    // Fallback: if accuracy listener never fires (sensor always reports 0/null),
    // check once after 3 seconds and show dialog if still looks uncalibrated.
    _calibrationCheckTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _calibrationShownThisSession) return;
      if (_needsCalibration(_accuracyNotifier.value) && _isAuthorized && !_noSensor) {
        _calibrationShownThisSession = true;
        _showCalibrationDialog();
      }
    });
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
    _qiblaDirection = (atan2(y, x) * 180 / pi + 360) % 360;
  }

  String get _cardinalDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((_headingRaw + 22.5) / 45).floor() % 8];
  }

  void _showCalibrationDialog() {
    if (!mounted) return;
    final lang = context.read<PrayerTimeViewModel>().language;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _CalibrationDialog(
        language: lang,
        accuracyNotifier: _accuracyNotifier,
      ),
    );
  }

  Color _accuracyColor(double a) {
    if (a == _kHigh) return Colors.green;
    if (a == _kMedium) return Colors.orange;
    if (a > 0) return Colors.red;
    return Colors.red;
  }

  String _accuracyDot(double a) {
    if (a == _kHigh) return '●';
    if (a == _kMedium) return '●';
    return '●';
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
                    child: Row(children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textPrimary(context), size: 22),
                      ),
                    ]),
                  ),
                  Column(children: [
                    Icon(AppIcons.compass, size: 50,
                        color: AppTheme.accentColor(context)),
                    const SizedBox(height: 8),
                    Text(AppStrings.qiblaCompass(vm.language),
                        style: TextStyle(fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary(context))),
                    if (vm.selectedCity != null && vm.selectedDistrict != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(vm.locationLabel,
                            style: TextStyle(fontSize: 14,
                                color: AppTheme.textSecondary(context))),
                      ),
                  ]),
                  const Spacer(),

                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(children: [
                      CompassRose(heading: _headingCumulative),
                      QiblaArrow(
                        heading: _headingCumulative,
                        qiblaDirection: _qiblaDirection,
                        language: vm.language,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

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

                  if (_noSensor)
                    WarningCard(
                      icon: Icons.sensors_off_rounded,
                      message: vm.language == 'tr'
                          ? 'Bu cihazda pusula sensörü bulunamadı.'
                          : vm.language == 'ar'
                              ? 'لا يوجد مستشعر بوصلة في هذا الجهاز.'
                              : 'No compass sensor found on this device.',
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

                  // Calibration button with live accuracy indicator
                  if (!_noSensor && _isAuthorized)
                    ValueListenableBuilder<double>(
                      valueListenable: _accuracyNotifier,
                      builder: (_, accuracy, __) {
                        final bad = _needsCalibration(accuracy);
                        final dotColor = _accuracyColor(accuracy);
                        final label = vm.language == 'tr'
                            ? 'Pusulayı Kalibre Et'
                            : vm.language == 'ar'
                                ? 'معايرة البوصلة'
                                : 'Calibrate Compass';
                        final accLabel = accuracy == _kHigh
                            ? (vm.language == 'tr' ? 'Yüksek' : accuracy == _kHigh ? 'High' : 'عالية')
                            : accuracy == _kMedium
                                ? (vm.language == 'tr' ? 'Orta' : 'Medium')
                                : (vm.language == 'tr' ? 'Düşük' : 'Low');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            // Accuracy level indicator
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(_accuracyDot(accuracy),
                                  style: TextStyle(color: dotColor, fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                accuracy <= 0
                                    ? (vm.language == 'tr'
                                        ? 'Hassasiyet ölçülüyor...'
                                        : 'Measuring accuracy...')
                                    : (vm.language == 'tr'
                                        ? 'Hassasiyet: $accLabel'
                                        : 'Accuracy: $accLabel'),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: accuracy <= 0
                                        ? AppTheme.textSecondary(context)
                                        : dotColor),
                              ),
                            ]),
                            TextButton.icon(
                              onPressed: () {
                                _calibrationShownThisSession = false;
                                _showCalibrationDialog();
                                _calibrationShownThisSession = true;
                              },
                              icon: Icon(Icons.explore_rounded, size: 18,
                                  color: bad
                                      ? Colors.orange
                                      : AppTheme.textSecondary(context)),
                              label: Text(label,
                                  style: TextStyle(fontSize: 13,
                                      color: bad
                                          ? Colors.orange
                                          : AppTheme.textSecondary(context))),
                            ),
                          ]),
                        );
                      },
                    ),

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

// ---------------------------------------------------------------------------

class _CalibrationDialog extends StatefulWidget {
  final String language;
  final ValueNotifier<double> accuracyNotifier;

  const _CalibrationDialog({
    required this.language,
    required this.accuracyNotifier,
  });

  @override
  State<_CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<_CalibrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _figureEightCtrl;

  @override
  void initState() {
    super.initState();
    _figureEightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    widget.accuracyNotifier.addListener(_onAccuracyChanged);
  }

  void _onAccuracyChanged() {
    if (!mounted) return;
    setState(() {});
    // Auto-close when accuracy reaches MEDIUM or HIGH
    final a = widget.accuracyNotifier.value;
    if (a > 0 && a <= _kMedium) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    widget.accuracyNotifier.removeListener(_onAccuracyChanged);
    _figureEightCtrl.dispose();
    super.dispose();
  }

  String get _accuracyLabel {
    final a = widget.accuracyNotifier.value;
    final tr = widget.language == 'tr';
    final ar = widget.language == 'ar';
    if (a == _kHigh) return tr ? 'Yüksek ✓' : ar ? 'عالية ✓' : 'High ✓';
    if (a == _kMedium) return tr ? 'Orta ✓' : ar ? 'متوسطة ✓' : 'Medium ✓';
    if (a == 45) return tr ? 'Düşük' : ar ? 'منخفضة' : 'Low';
    return tr ? 'Kalibre değil' : ar ? 'غير موثوق' : 'Uncalibrated';
  }

  Color get _accuracyColor {
    final a = widget.accuracyNotifier.value;
    if (a == _kHigh) return Colors.green;
    if (a == _kMedium) return Colors.green;
    if (a == 45) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.language == 'tr';
    final ar = widget.language == 'ar';
    final a = widget.accuracyNotifier.value;
    final done = a > 0 && a <= _kMedium;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        const Icon(Icons.explore_rounded, color: AppColors.gold),
        const SizedBox(width: 8),
        Flexible(child: Text(
          tr ? 'Pusula Kalibrasyonu'
             : ar ? 'معايرة البوصلة'
             : 'Compass Calibration',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!done) ...[
          SizedBox(
            width: 120,
            height: 80,
            child: AnimatedBuilder(
              animation: _figureEightCtrl,
              builder: (_, __) {
                final t = _figureEightCtrl.value * 2 * pi;
                return CustomPaint(
                  painter: _Figure8Painter(
                    dotX: 45 * sin(t),
                    dotY: 25 * sin(2 * t),
                    color: AppColors.gold,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr  ? 'Telefonu yukarıdaki gibi 8 şeklinde yavaşça hareket ettirin.'
              : ar ? 'حرّك الهاتف ببطء على شكل رقم 8.'
              : 'Slowly move your phone in a figure-8 pattern.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            tr  ? 'Telefonu düz tutmaya çalışın.'
              : ar ? 'حاول إبقاء الهاتف مستوياً.'
              : 'Try to keep the phone level.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 48),
          ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(tr ? 'Durum: ' : ar ? 'الحالة: ' : 'Status: ',
              style: const TextStyle(fontSize: 13)),
          Text(_accuracyLabel,
              style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.bold, color: _accuracyColor)),
        ]),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr ? 'Tamam' : ar ? 'موافق' : 'OK'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _Figure8Painter extends CustomPainter {
  final double dotX, dotY;
  final Color color;
  const _Figure8Painter(
      {required this.dotX, required this.dotY, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final tracePaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (int i = 0; i <= 100; i++) {
      final t = i / 100 * 2 * pi;
      final x = cx + 45 * sin(t);
      final y = cy + 25 * sin(2 * t);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, tracePaint);
    canvas.drawCircle(Offset(cx + dotX, cy + dotY), 7,
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Figure8Painter old) =>
      old.dotX != dotX || old.dotY != dotY;
}
