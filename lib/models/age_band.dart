/// 年代モード。就学前(kids)・小学生(junior)・中高生(teen)・大人(adult)。
enum AgeBand {
  kids,
  junior,
  teen,
  adult;

  /// 13歳未満。個人データの取得・広告・外部リンクを避ける。
  bool get isChild => index <= junior.index;

  /// 利用シーンフィルター・シェア・出典表示・他アプリ紹介を出す年代。
  bool get isTeenOrAdult => index >= teen.index;

  /// 他アプリ紹介（外部ストアへのリンク）を出してよい年代。
  bool get allowsPromo => isTeenOrAdult;

  /// 就学前は読み上げを標準で使う。
  bool get autoSpeak => this == kids;

  static AgeBand? parse(String? name) {
    for (final b in values) {
      if (b.name == name) return b;
    }
    return null;
  }

  /// 生まれた年から、最初に提案する年代を決める。
  ///
  /// 年だけでは誕生日前後が分からないため、年齢は「若いほう」に見積もる
  /// （安全側。例: 2008年生まれ・2026年は 17〜18歳なので 17歳として扱う）。
  static AgeBand fromBirthYear(int birthYear, {DateTime? now}) {
    final year = (now ?? DateTime.now()).year;
    final age = (year - birthYear - 1).clamp(0, 150);
    if (age <= 6) return kids;
    if (age <= 12) return junior;
    if (age <= 17) return teen;
    return adult;
  }
}
