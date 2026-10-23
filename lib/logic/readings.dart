/// 「血（ち）」のように漢字のあとに添えた読みを取り除く。読み上げ（TTS）で、漢字と読みを二重に読まないため。
/// 読みは、漢字の直後の全角かっこの中のひらがな（長音を含む）だけを対象にする。
String stripReadings(String text) =>
    text.replaceAllMapped(RegExp(r'([\u4E00-\u9FFF々]+)（[ぁ-んー]+）'), (m) => m.group(1)!);
