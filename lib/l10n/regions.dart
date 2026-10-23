/// 国・地域の選択肢（ISO 3166-1 の2文字コード → 各言語の名前）。
const regionNames = <String, ({String ja, String en, String zh, String ko, String es})>{
  'JP': (ja: '日本', en: 'Japan', zh: '日本', ko: '일본', es: 'Japón'),
  'US': (ja: 'アメリカ', en: 'United States', zh: '美国', ko: '미국', es: 'Estados Unidos'),
  'GB': (ja: 'イギリス', en: 'United Kingdom', zh: '英国', ko: '영국', es: 'Reino Unido'),
  'CA': (ja: 'カナダ', en: 'Canada', zh: '加拿大', ko: '캐나다', es: 'Canadá'),
  'AU': (ja: 'オーストラリア', en: 'Australia', zh: '澳大利亚', ko: '호주', es: 'Australia'),
  'NZ': (ja: 'ニュージーランド', en: 'New Zealand', zh: '新西兰', ko: '뉴질랜드', es: 'Nueva Zelanda'),
  'DE': (ja: 'ドイツ', en: 'Germany', zh: '德国', ko: '독일', es: 'Alemania'),
  'FR': (ja: 'フランス', en: 'France', zh: '法国', ko: '프랑스', es: 'Francia'),
  'ES': (ja: 'スペイン', en: 'Spain', zh: '西班牙', ko: '스페인', es: 'España'),
  'IT': (ja: 'イタリア', en: 'Italy', zh: '意大利', ko: '이탈리아', es: 'Italia'),
  'BR': (ja: 'ブラジル', en: 'Brazil', zh: '巴西', ko: '브라질', es: 'Brasil'),
  'MX': (ja: 'メキシコ', en: 'Mexico', zh: '墨西哥', ko: '멕시코', es: 'México'),
  'IN': (ja: 'インド', en: 'India', zh: '印度', ko: '인도', es: 'India'),
  'KR': (ja: '韓国', en: 'South Korea', zh: '韩国', ko: '대한민국', es: 'Corea del Sur'),
  'CN': (ja: '中国', en: 'China', zh: '中国', ko: '중국', es: 'China'),
  'TW': (ja: '台湾', en: 'Taiwan', zh: '台湾', ko: '대만', es: 'Taiwán'),
};

String regionName(String code, String language) {
  final n = regionNames[code.toUpperCase()];
  if (n == null) return code;
  return switch (language) {
    'ja' => n.ja,
    'zh' => n.zh,
    'ko' => n.ko,
    'es' => n.es,
    _ => n.en,
  };
}
