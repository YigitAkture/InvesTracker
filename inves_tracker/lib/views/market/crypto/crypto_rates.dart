import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/core/l10n/app_localizations.dart';
import 'package:inves_tracker/shared/banner_add.dart';
import 'package:inves_tracker/views/market/crypto/widgets/crypto_box.dart';

class CryptoRates extends StatelessWidget {
  final List<CryptoData> cryptos;

  const CryptoRates({super.key, required this.cryptos});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (cryptos.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text(
          l10n.noCryptoDataAvailable,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Display crypto boxes with banner ad after the 5th item
        for (int i = 0; i < cryptos.length; i++) ...[
          CryptoBox(crypto: cryptos[i]),
          // Add banner after the 4th crypto box (index 3)
          if (i == 3) ...[_BannerWithSpacing()],
        ],
      ],
    );
  }
}

class _BannerWithSpacing extends StatefulWidget {
  const _BannerWithSpacing();

  @override
  State<_BannerWithSpacing> createState() => _BannerWithSpacingState();
}

class _BannerWithSpacingState extends State<_BannerWithSpacing> {
  bool _adLoaded = false;

  @override
  Widget build(BuildContext context) {
    return BannerAdd(
      onAdLoaded: () => setState(() => _adLoaded = true),
      onAdFailed: () => setState(() => _adLoaded = false),
      padding: _adLoaded
          ? EdgeInsets.only(top: 8.h, bottom: 16.h)
          : EdgeInsets.zero,
    );
  }
}
