import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'ja_styles.dart';

/// 画面の文言の「表記」。日本語では、モード（年代）で書き方を変える。
/// - kids: ひらがなと分かち書き
/// - junior: ひらがな（分かち書きなし）
/// - adult: 漢字まじりの、ふつうの表記（Teen / Adult）
/// ほかの言語は、モードで変えない。
enum UiStyle { kids, junior, adult }

/// [AppLocalizations] を読み込む。日本語のときだけ、[style] に合わせた表記にする。
/// 年代が変わると [style] が変わり、画面の文言がすぐに入れ替わる。
class KnowlyLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const KnowlyLocalizationsDelegate(this.style);
  final UiStyle style;

  @override
  bool isSupported(Locale locale) => AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    if (locale.languageCode == 'ja') {
      final name = locale.toString();
      return SynchronousFuture(switch (style) {
        UiStyle.kids => lookupAppLocalizations(locale),
        UiStyle.junior => AppLocalizationsJaJunior(name),
        UiStyle.adult => AppLocalizationsJaAdult(name),
      });
    }
    return SynchronousFuture(lookupAppLocalizations(locale));
  }

  @override
  bool shouldReload(KnowlyLocalizationsDelegate old) => old.style != style;
}
