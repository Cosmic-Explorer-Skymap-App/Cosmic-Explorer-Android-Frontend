import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'auth_service.dart';

class AdService {
  static const String _bannerAdUnitId = 'ca-app-pub-1924469525167599/4871813295';
  static const String _interstitialAdUnitId = 'ca-app-pub-1924469525167599/8130866608';

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  static Future<BannerAd?> createBannerAd() async {

    final BannerAd ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('BannerAd loaded: ${ad.adUnitId}'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('BannerAd failed to load: ${ad.adUnitId}, $error');
          ad.dispose();
        },
      ),
    );
    await ad.load();
    return ad;
  }

  static Future<void> loadInterstitialAd() async {

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('InterstitialAd loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialAdReady = false;
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          loadInterstitialAd(); // Load next one
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          print('InterstitialAd failed to show: $error');
        },
      );
      await _interstitialAd!.show();
    } else {
      print('InterstitialAd is not ready yet.');
      await loadInterstitialAd(); // Try loading again
    }
  }
}
