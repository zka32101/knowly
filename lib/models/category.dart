/// カテゴリー（雑学の分類）。assets/trivia/categories.json で増やせる。
class TriviaCategory {
  const TriviaCategory({
    required this.id,
    required this.order,
    required this.emoji,
    required this.labels,
    this.parent,
    this.active = true,
  });

  final String id;
  final int order;
  final String emoji;
  final bool active;

  /// 親のカテゴリー（なければ、いちばん上のカテゴリー）。親を選ぶと、子の雑学もふくむ。
  final String? parent;

  /// 言語 → 名前。日本語は {kids, junior, adult}（なければ kids → adult の順で代用）、ほかは文字列。
  final Map<String, Object> labels;

  factory TriviaCategory.fromJson(Map<String, dynamic> json) => TriviaCategory(
        id: json['id'] as String,
        order: json['order'] as int? ?? 1000,
        emoji: json['emoji'] as String? ?? '💡',
        parent: json['parent'] as String?,
        active: (json['status'] as String? ?? 'active') == 'active',
        labels: Map<String, Object>.from(json['labels'] as Map),
      );

  /// [style] は日本語の表記（kids / junior / adult）。名前がなければ英語、それもなければ id。
  String label(String lang, {String style = 'adult'}) {
    final v = labels[lang] ?? labels['en'];
    if (v is String) return v;
    if (v is Map) {
      return (v[style] ?? v['adult'] ?? v['kids'] ?? v.values.first) as String;
    }
    return id;
  }
}

/// 読み込んだカテゴリー（画面の名前の引き当て用）。ARB にない新しいカテゴリーは、ここから名前を出す。
class CategoryRegistry {
  static Map<String, TriviaCategory> _byId = const {};

  static void set(Iterable<TriviaCategory> categories) {
    _byId = {for (final c in categories) c.id: c};
  }

  static TriviaCategory? get(String id) => _byId[id];

  /// [id] の親・祖父母…（近い順）。ループしても止まるようにする。
  static List<String> ancestors(String id) {
    final out = <String>[];
    var p = _byId[id]?.parent;
    while (p != null && !out.contains(p) && out.length < 8) {
      out.add(p);
      p = _byId[p]?.parent;
    }
    return out;
  }

  /// [id] の階層の深さ（いちばん上は0）。
  static int depth(String id) => ancestors(id).length;

  /// 雑学のカテゴリー [itemCategory] が、選んだカテゴリー [selected] のどれかに入るか（親を選ぶと子もふくむ）。
  static bool matches(Set<String> selected, String itemCategory) {
    if (selected.contains(itemCategory)) return true;
    return ancestors(itemCategory).any(selected.contains);
  }
}
