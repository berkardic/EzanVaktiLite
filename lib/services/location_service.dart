import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService shared = LocationService._();
  LocationService._();

  static const _channel = MethodChannel('com.yba.ezanvakti/location');

  Position? _cachedPosition;
  DateTime? _cacheTime;

  Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('isServiceEnabled error: $e');
      return false;
    }
  }

  Future<LocationPermission> checkPermission() async {
    // Native channel primary — geolocator_apple'ın deprecated class method bug'ını bypass et
    try {
      final status = await _channel.invokeMethod<String>('checkLocationPermission');
      if (status != null) return _fromNative(status);
    } catch (e) {
      debugPrint('native checkPermission error: $e');
    }
    // Fallback
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('checkPermission fallback error: $e');
      return LocationPermission.denied;
    }
  }

  Future<LocationPermission> requestPermission() async {
    // Native channel primary — iOS 26'da doğru instance-based API kullanır
    try {
      final status = await _channel.invokeMethod<String>('requestLocationPermission');
      if (status != null) return _fromNative(status);
    } catch (e) {
      debugPrint('native requestPermission error: $e');
    }
    // Fallback
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('requestPermission fallback error: $e');
      return LocationPermission.denied;
    }
  }

  LocationPermission _fromNative(String status) {
    switch (status) {
      case 'authorized':
        return LocationPermission.whileInUse;
      case 'deniedForever':
        return LocationPermission.deniedForever;
      case 'denied':
      case 'unknown':
      default:
        return LocationPermission.denied;
    }
  }

  bool isAuthorized(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  String authStatusString(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return 'authorized';
      case LocationPermission.deniedForever:
        return 'deniedForever';
      case LocationPermission.denied:
        return 'denied';
      default:
        return 'unknown';
    }
  }

  Future<Position> getCurrentPosition() async {
    if (_cachedPosition != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inSeconds < 60) {
      return _cachedPosition!;
    }
    // Try last known position first (instant on Android)
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _cachedPosition = last;
        _cacheTime = DateTime.now();
        // Also kick off a fresh fix in the background to update cache
        Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 15),
          ),
        ).then((p) {
          _cachedPosition = p;
          _cacheTime = DateTime.now();
        }).catchError((_) {});
        return last;
      }
    } catch (_) {}
    // No last known — wait for fresh fix
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );
    _cachedPosition = position;
    _cacheTime = DateTime.now();
    return position;
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
