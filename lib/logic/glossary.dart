import '../models/glossary.dart';

/// 本文を、ふつうの文字と、用語（タップできる）に分けたかたまり。
class TextSegment {
  const TextSegment(this.text, [this.entryId]);
  final String text;

  /// 用語のとき、その id。
  final String? entryId;
}

class _Hit {
  _Hit(this.start, this.end, this.id);
  final int start;
  final int end;
  final String id;
}

/// [text] の中の用語を探して、分けて返す。
/// - 日本語は文字どおり、英語は大文字小文字を区別せず、前後が英字でないものだけ一致とする。
/// - 重なったときは、先に始まるもの・長いものを優先する。
/// - 同じ用語は、最初に出てきた1か所だけをリンクにする（読みやすさのため）。
List<TextSegment> segmentGlossary(
  String text,
  Iterable<GlossaryEntry> entries,
  String language,
) {
  final hits = <_Hit>[];
  for (final e in entries) {
    final t = e.forLanguage(language);
    if (t == null) continue;
    for (final pattern in t.match) {
      if (pattern.isEmpty) continue;
      if (language == 'ja') {
        var from = 0;
        while (true) {
          final i = text.indexOf(pattern, from);
          if (i < 0) break;
          hits.add(_Hit(i, i + pattern.length, e.id));
          from = i + pattern.length;
        }
      } else {
        final re = RegExp('(?<![A-Za-z])${RegExp.escape(pattern)}(?![A-Za-z])',
            caseSensitive: false);
        for (final m in re.allMatches(text)) {
          hits.add(_Hit(m.start, m.end, e.id));
        }
      }
    }
  }
  hits.sort((a, b) {
    final c = a.start.compareTo(b.start);
    return c != 0 ? c : (b.end - b.start).compareTo(a.end - a.start);
  });

  final chosen = <_Hit>[];
  final used = <String>{};
  var cursor = 0;
  for (final h in hits) {
    if (h.start < cursor || used.contains(h.id)) continue;
    chosen.add(h);
    used.add(h.id);
    cursor = h.end;
  }

  final out = <TextSegment>[];
  var pos = 0;
  for (final h in chosen) {
    if (h.start > pos) out.add(TextSegment(text.substring(pos, h.start)));
    out.add(TextSegment(text.substring(h.start, h.end), h.id));
    pos = h.end;
  }
  if (pos < text.length) out.add(TextSegment(text.substring(pos)));
  return out;
}
