import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inves_tracker/core/models/crypto_data.dart';
import 'package:inves_tracker/l10n/app_localizations.dart';
import 'package:inves_tracker/views/market/crypto/widgets/crypto_box.dart';

class CryptoRates extends StatelessWidget {
  final List<CryptoData> cryptos;
  
  const CryptoRates({
    super.key,
    required this.cryptos,
  });

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
      children: cryptos
          .map((crypto) => CryptoBox(crypto: crypto))
          .toList(),
    );
  }
}