import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdd extends StatefulWidget {
  const BannerAdd({super.key});

  @override
  State<BannerAdd> createState() => _BannerAddState();
}

class _BannerAddState extends State<BannerAdd> {
  BannerAd? _bannerAd;
  bool _isAddLoaded = false;

  // Add Unit ID
  // Test Ad Unit ID: 'ca-app-pub-3940256099942544/6300978111'
  // Real Ad Unit ID: 'ca-app-pub-2938969901665451/8416786222'
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-2938969901665451/8416786222' // Ad Unit ID for Android
      : 'ca-app-pub-3940256099942544/2435281174'; // Test Ad Unit ID for iOS

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAddLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isAddLoaded) {
      return const SizedBox.shrink();
    } else {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }
  }
}