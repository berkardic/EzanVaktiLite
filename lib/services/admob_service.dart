import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService extends ChangeNotifier {
  static final AdMobService shared = AdMobService._();
  AdMobService._();

  bool isInitialized = false;
  bool _personalized = false;

  static String get bannerAdUnitID => kDebugMode
      ? 'ca-app-pub-3940256099942544/2934735716' // Google test unit
      : 'ca-app-pub-7016816375186028/5975263554'; // Production

  // Personalized ads when ATT authorized, non-personalized otherwise
  AdRequest get _adRequest => _personalized
      ? const AdRequest()
      : const AdRequest(extras: {'npa': '1'});

  void initialize({bool personalized = false}) {
    if (isInitialized) return;
    _personalized = personalized;

    MobileAds.instance.initialize().then((_) {
      isInitialized = true;
      notifyListeners();
    });
  }

  BannerAd createBannerAd({VoidCallback? onLoaded, Function(String)? onFailed}) {
    int retryCount = 0;
    const maxRetries = 3;

    late BannerAd ad;
    ad = BannerAd(
      adUnitId: bannerAdUnitID,
      size: AdSize.banner,
      request: _adRequest,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          retryCount = 0;
          onLoaded?.call();
        },
        onAdFailedToLoad: (failedAd, error) {
          if (retryCount < maxRetries) {
            retryCount++;
            Future.delayed(Duration(seconds: retryCount * 5), () {
              (failedAd as BannerAd).load();
            });
          }
          onFailed?.call(error.message);
        },
      ),
    );

    return ad;
  }
}
