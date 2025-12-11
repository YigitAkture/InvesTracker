import 'package:flutter/material.dart';

class AssetColors {
  // Currency colors
  static const Color usd = Color(0xFF2ECC71);
  static const Color eur = Color(0xFF3498DB);
  static const Color gbp = Color(0xFFE74C3C);
  static const Color jpy = Color(0xFFE67E22);
  static const Color chf = Color(0xFF9B59B6);
  static const Color cad = Color(0xFF1ABC9C);
  static const Color aud = Color(0xFFF39C12);
  static const Color tryColor = Color(0xFFE74C3C);
  static const Color sar = Color(0xFF16A085);
  static const Color rub = Color(0xFF2980B9);
  static const Color aed = Color(0xFF8E44AD);
  static const Color kwd = Color(0xFF27AE60);
  static const Color dkk = Color(0xFFD35400);
  static const Color sek = Color(0xFFC0392B);
  static const Color nok = Color(0xFF2C3E50);

  // Gold colors (various shades of gold/yellow)
  static const Color hasGold = Color(0xFFFFD700);
  static const Color graGold = Color(0xFFFFC125);
  static const Color ceyrekGold = Color(0xFFFFB90F);
  static const Color yarimGold = Color(0xFFEEAD0E);
  static const Color tamGold = Color(0xFFDAA520);
  static const Color ataGold = Color(0xFFC5A572);
  static const Color resatGold = Color(0xFFB8860B);
  static const Color cumhuriyetGold = Color(0xFFD4AF37);
  static const Color gremseGold = Color(0xFFE6BE8A);
  static const Color ayar14Gold = Color(0xFFF0E68C);
  static const Color ayar18Gold = Color(0xFFFFDF00);
  static const Color yiaGold = Color(0xFFFFCC00);
  static const Color ikibucukGold = Color(0xFFFFA500);
  static const Color besliGold = Color(0xFFFF8C00);

  // Crypto colors
  static const Color btc = Color(0xFFF7931A);
  static const Color eth = Color(0xFF627EEA);
  static const Color usdt = Color(0xFF26A17B);
  static const Color xrp = Color(0xFF00AAE4);
  static const Color bnb = Color(0xFFF3BA2F);
  static const Color sol = Color(0xFF14F195);
  static const Color usdc = Color(0xFF2775CA);
  static const Color steth = Color(0xFF00A3FF);
  static const Color doge = Color(0xFFC2A633);
  static const Color trx = Color(0xFFEF0027);
  static const Color ada = Color(0xFF0033AD);
  static const Color shib = Color(0xFFFFA409);
  static const Color link = Color(0xFF2A5ADA);
  static const Color bch = Color(0xFF8DC351);
  static const Color avax = Color(0xFFE84142);
  static const Color xlm = Color(0xFF000000);
  static const Color sui = Color(0xFF6FBCF0);
  static const Color dot = Color(0xFFE6007A);
  static const Color uni = Color(0xFFFF007A);
  static const Color ltc = Color(0xFFBEBEBE);
  static const Color xmr = Color(0xFFFF6600);
  static const Color near = Color(0xFF000000);
  static const Color leo = Color(0xFF0080FF);

  // Default colors for unknown types
  static const Color defaultCurrency = Color(0xFF95A5A6);
  static const Color defaultGold = Color(0xFFFFD700);
  static const Color defaultCrypto = Color(0xFF34495E);

  static Color getColorForAsset(String code, String type) {
    switch (type.toLowerCase()) {
      case 'currency':
        return _getCurrencyColor(code);
      case 'gold':
        return _getGoldColor(code);
      case 'crypto':
        return _getCryptoColor(code);
      default:
        return defaultCurrency;
    }
  }

  static Color _getCurrencyColor(String code) {
    switch (code) {
      case 'USD':
        return usd;
      case 'EUR':
        return eur;
      case 'GBP':
        return gbp;
      case 'JPY':
        return jpy;
      case 'CHF':
        return chf;
      case 'CAD':
        return cad;
      case 'AUD':
        return aud;
      case 'TRY':
        return tryColor;
      case 'SAR':
        return sar;
      case 'RUB':
        return rub;
      case 'AED':
        return aed;
      case 'KWD':
        return kwd;
      case 'DKK':
        return dkk;
      case 'SEK':
        return sek;
      case 'NOK':
        return nok;
      default:
        return defaultCurrency;
    }
  }

  static Color _getGoldColor(String code) {
    switch (code) {
      case 'HAS':
        return hasGold;
      case 'GRA':
        return graGold;
      case 'CEYREKALTIN':
        return ceyrekGold;
      case 'YARIMALTIN':
        return yarimGold;
      case 'TAMALTIN':
        return tamGold;
      case 'ATAALTIN':
        return ataGold;
      case 'RESATALTIN':
        return resatGold;
      case 'CUMHURIYETALTINI':
        return cumhuriyetGold;
      case 'GREMSEALTIN':
        return gremseGold;
      case '14AYARALTIN':
        return ayar14Gold;
      case '18AYARALTIN':
        return ayar18Gold;
      case 'YIA':
        return yiaGold;
      case 'IKIBUCUKALTIN':
        return ikibucukGold;
      case 'BESLIALTIN':
        return besliGold;
      default:
        return defaultGold;
    }
  }

  static Color _getCryptoColor(String code) {
    switch (code) {
      case 'BTC':
        return btc;
      case 'ETH':
        return eth;
      case 'USDT':
        return usdt;
      case 'XRP':
        return xrp;
      case 'BNB':
        return bnb;
      case 'SOL':
        return sol;
      case 'USDC':
        return usdc;
      case 'STETH':
        return steth;
      case 'DOGE':
        return doge;
      case 'TRX':
        return trx;
      case 'ADA':
        return ada;
      case 'SHIB':
        return shib;
      case 'LINK':
        return link;
      case 'BCH':
        return bch;
      case 'AVAX':
        return avax;
      case 'XLM':
        return xlm;
      case 'SUI':
        return sui;
      case 'DOT':
        return dot;
      case 'UNI':
        return uni;
      case 'LTC':
        return ltc;
      case 'XMR':
        return xmr;
      case 'NEAR':
        return near;
      case 'LEO':
        return leo;
      default:
        return defaultCrypto;
    }
  }
}