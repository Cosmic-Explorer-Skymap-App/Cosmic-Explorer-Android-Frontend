import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdService {
  static const String _bannerAdUnitId = 'ca-app-pub-1924469525167599/4871813295';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID

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

  static void showInterstitialAd(VoidCallback onDismissed) {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onDismissed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onDismissed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (err) {
          print('InterstitialAd failed to load: $err');
          onDismissed();
        },
      ),
    );
  }
}
