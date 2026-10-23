/// 国・地域の選択肢（ISO 3166-1 の2文字コード → 日本語名・英語名）。
const regionNames = <String, ({String ja, String en})>{
  'JP': (ja: '日本', en: 'Japan'),
  'US': (ja: 'アメリカ', en: 'United States'),
  'GB': (ja: 'イギリス', en: 'United Kingdom'),
  'CA': (ja: 'カナダ', en: 'Canada'),
  'AU': (ja: 'オーストラリア', en: 'Australia'),
  'NZ': (ja: 'ニュージーランド', en: 'New Zealand'),
  'DE': (ja: 'ドイツ', en: 'Germany'),
  'FR': (ja: 'フランス', en: 'France'),
  'ES': (ja: 'スペイン', en: 'Spain'),
  'IT': (ja: 'イタリア', en: 'Italy'),
  'BR': (ja: 'ブラジル', en: 'Brazil'),
  'MX': (ja: 'メキシコ', en: 'Mexico'),
  'IN': (ja: 'インド', en: 'India'),
  'KR': (ja: '韓国', en: 'South Korea'),
  'CN': (ja: '中国', en: 'China'),
  'TW': (ja: '台湾', en: 'Taiwan'),
};

String regionName(String code, String language) {
  final n = regionNames[code.toUpperCase()];
  if (n == null) return code;
  return language == 'ja' ? n.ja : n.en;
}
