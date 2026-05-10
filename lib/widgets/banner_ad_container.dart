import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class BannerAdContainer extends StatefulWidget {
  const BannerAdContainer({super.key});

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdMobService.shared.isInitialized) {
      _loadAd();
    } else {
      // Wait for initialization
      AdMobService.shared.addListener(_onAdMobInit);
    }
  }

  void _onAdMobInit() {
    if (AdMobService.shared.isInitialized) {
      AdMobService.shared.removeListener(_onAdMobInit);
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = AdMobService.shared.createBannerAd(
      onLoaded: () {
        if (mounted) setState(() => _isLoaded = true);
      },
      onFailed: (err) {
        debugPrint('[AdMob] Banner failed: $err');
      },
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    AdMobService.shared.removeListener(_onAdMobInit);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        height: 50,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox(height: 50);
  }
}
