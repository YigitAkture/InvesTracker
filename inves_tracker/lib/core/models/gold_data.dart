class GoldData {
  final String code;
  final String name;
  final double buying;
  final double selling;
  final double changeRate;
  final bool isIncreasing;

  GoldData({
    required this.code,
    required this.name,
    required this.buying,
    required this.selling,
    required this.changeRate,
    required this.isIncreasing,
  });

  factory GoldData.fromJson(String code, Map<String, dynamic> json) {
    final buying = (json['Buying'] ?? 0.0).toDouble();
    final change = (json['Change'] ?? 0.0).toDouble();
    
    return GoldData(
      code: code,
      name: _getGoldName(code),
      buying: buying,
      selling: (json['Selling'] ?? 0.0).toDouble(),
      changeRate: change.abs(),
      isIncreasing: change >= 0,
    );
  }

  static String _getGoldName(String code) {
    const Map<String, String> names = {
      'HAS': 'Has Altın',
      'GRA': 'Gram Altın',
      'CEYREKALTIN': 'Çeyrek Altın',
      'YARIMALTIN': 'Yarım Altın',
      'TAMALTIN': 'Tam Altın',
      'ATAALTIN': 'Ata Altın',
      'RESATALTIN': 'Reşat Altın',
      'CUMHURIYETALTINI': 'Cumhuriyet Altını',
      'GREMSEALTIN': 'Gremse Altın',
      '14AYARALTIN': '14 Ayar Altın',
      '18AYARALTIN': '18 Ayar Altın',
      'YIA': '22 Ayar Bilezik',
      'IKIBUCUKALTIN': 'İkibuçuk Altın',
      'BESLIALTIN': 'Beşli Altın',
    };
    return names[code] ?? code;
  }
}