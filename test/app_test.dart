import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/app.dart';
import 'package:knowly/data/trivia_repository.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/quiz.dart';
import 'package:knowly/models/trivia.dart';
import 'package:knowly/services/notifications.dart';
import 'package:knowly/widgets/ja_wrap_text.dart';
import 'package:knowly/services/tts.dart';
import 'package:knowly/state/providers.dart';
import 'package:knowly/state/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTts implements TtsService {
  final spoken = <String>[];
  @override
  Future<void> speak(String text, {required String language}) async => spoken.add(text);
  @override
  Future<void> stop() async {}
}

class FakeNotifications implements NotificationService {
  FakeNotifications({this.grant = true});
  final bool grant;
  int permissionRequests = 0;
  int cancels = 0;
  List<NotificationItem>? lastScheduled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> schedule(List<NotificationItem> items, {required String channelName}) async =>
      lastScheduled = items;

  @override
  Future<void> cancelAll() async {
    cancels++;
    lastScheduled = null;
  }
}

TriviaRepository _repo() {
  final raw = jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
      as Map<String, dynamic>;
  final quiz = jsonDecode(File('assets/trivia/quiz.json').readAsStringSync())
      as Map<String, dynamic>;
  return TriviaRepository(
    (raw['items'] as List)
        .map((e) => Trivia.fromJson(e as Map<String, dynamic>))
        .toList(),
    quizzes: (quiz['items'] as List)
        .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

FakeNotifications? _lastNotifications;

Future<FakeTts> _pump(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String deviceLanguage = 'ja',
  FakeNotifications? notifications,
}) async {
  final notif = _lastNotifications = notifications ?? FakeNotifications();
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final tts = FakeTts();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      triviaRepositoryProvider.overrideWithValue(_repo()),
      deviceLanguageProvider.overrideWithValue(deviceLanguage),
      nowProvider.overrideWithValue(DateTime(2026, 10, 23)),
      ttsProvider.overrideWithValue(tts),
      notificationServiceProvider.overrideWithValue(notif),
    ],
    child: const KnowlyApp(),
  ));
  await tester.pumpAndSettle();
  return tts;
}

/// 年のドロップダウンが開いている状態で、指定の年までスクロールして選ぶ。
Future<void> _pickYear(WidgetTester tester, int year) async {
  await tester.scrollUntilVisible(find.text('$year'), 100,
      scrollable: find.byType(Scrollable).last);
  await tester.tap(find.text('$year').last);
  await tester.pumpAndSettle();
}

/// 縦に長い詳細画面で、遅延生成されるウィジェットが見える位置までスクロールする。
Future<void> _reveal(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(find.byKey(key), 200,
      scrollable: find.byType(Scrollable).last);
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

/// ゲートのダイアログに表示された「a × b」から答えを入力する。
Future<void> _solveGate(WidgetTester tester, {bool wrong = false}) async {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((s) => s.contains('×'));
  final m = RegExp(r'(\d+) × (\d+)').firstMatch(text)!;
  final answer = int.parse(m.group(1)!) * int.parse(m.group(2)!) + (wrong ? 1 : 0);
  await tester.enterText(find.byKey(const Key('parental_gate_input')), '$answer');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('初回起動: 言語 → 生まれた年 → 興味 → ホーム（Adult）', (tester) async {
    await _pump(tester);
    expect(find.text('言語 / Language'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();

    // 年を選ぶまで進めない
    expect(tester.widget<FilledButton>(find.byKey(const Key('onboarding_next'))).onPressed,
        isNull);
    await tester.tap(find.byKey(const Key('birth_year_dropdown')));
    await tester.pumpAndSettle();
    await _pickYear(tester, 1990);
    expect(find.text('アダルト（大人）'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    expect(find.text('きょうの雑学'), findsOneWidget);
  });

  testWidgets('初回起動: 子どもの年では保護者向けの案内が出る', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('birth_year_dropdown')));
    await tester.pumpAndSettle();
    await _pickYear(tester, DateTime.now().year);
    expect(find.text('キッズ（就学前）'), findsOneWidget);
    expect(find.text('保護者の方へ'), findsOneWidget);
  });

  testWidgets('生まれた年は保存されない（年代だけを保存）', (tester) async {
    await _pump(tester);
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('birth_year_dropdown')));
    await tester.pumpAndSettle();
    await _pickYear(tester, 1990);
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_next')));
    await tester.pumpAndSettle();
    final sp = await SharedPreferences.getInstance();
    expect(sp.getString('ageBand'), 'adult');
    for (final key in sp.getKeys()) {
      expect(sp.get(key).toString().contains('1990'), isFalse, reason: key);
    }
  });

  testWidgets('Kids: 1画面1雑学・読み上げ・次へ', (tester) async {
    final tts = await _pump(tester, prefs: {'ageBand': 'kids'});
    expect(find.byKey(const Key('kids_listen')), findsOneWidget);
    // 絞り込みや保存など、大人向けの要素は出ない
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byIcon(Icons.bookmark_border), findsNothing);

    final first = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    await tester.tap(find.byKey(const Key('kids_listen')));
    await tester.pump();
    expect(tts.spoken, hasLength(1));

    await tester.tap(find.byKey(const Key('kids_next')));
    await tester.pumpAndSettle();
    final second = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();
    expect(second, isNot(equals(first)));
  });

  testWidgets('子どもモードは文字が大きく、大人モードは等倍', (tester) async {
    Future<double> scale(String band) async {
      await _pump(tester, prefs: {'ageBand': band});
      final ctx = tester.element(find.byType(Scaffold).first);
      final v = MediaQuery.textScalerOf(ctx).scale(14) / 14;
      await tester.pumpWidget(const SizedBox());
      return v;
    }

    expect(await scale('kids'), closeTo(1.3, 0.001));
    expect(await scale('junior'), closeTo(1.15, 0.001));
    expect(await scale('adult'), closeTo(1.0, 0.001));
  });

  testWidgets('Kids: モード変更には保護者ゲートが必要（不正解は通さない）', (tester) async {
    await _pump(tester, prefs: {'ageBand': 'kids'});
    await tester.tap(find.byKey(const Key('open_settings')));
    await tester.pumpAndSettle();
    // Kids は設定を開く前にもゲートがある
    expect(find.text('保護者の方へ確認'), findsOneWidget);
    await _solveGate(tester);
    // 他アプリ紹介は子どもには出さない
    expect(find.text('他のアプリもチェック！'), findsNothing);

    await tester.tap(find.byKey(const Key('change_mode')));
    await tester.pumpAndSettle();
    expect(find.text('保護者の方へ確認'), findsOneWidget);
    await _solveGate(tester, wrong: true);
    expect(find.text('答えが違います'), findsOneWidget);
    expect(find.byKey(const Key('mode_adult')), findsNothing);

    await _solveGate(tester);
    expect(find.byKey(const Key('mode_adult')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mode_adult')));
    await tester.pumpAndSettle();
    final sp = await SharedPreferences.getInstance();
    expect(sp.getString('ageBand'), 'adult');
  });

  testWidgets('Adult: 無料プランは過去分に制限があり、詳細にコピーがある', (tester) async {
    await _pump(tester, prefs: {'ageBand': 'adult'});
    expect(find.text('きょうの雑学'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('locked_note')), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('locked_note')), findsOneWidget);
    // 表示されるカード: 今日 + 過去6日 = 最大7件
    expect(find.byIcon(Icons.chevron_right).evaluate().length, lessThanOrEqualTo(7));

    await tester.tap(find.byIcon(Icons.chevron_right).last);
    await tester.pumpAndSettle();
    await _reveal(tester, const Key('copy_button'));
    expect(find.byKey(const Key('copy_button')), findsOneWidget);
    await _reveal(tester, const Key('rating_heh'));
    expect(find.byKey(const Key('rating_heh')), findsOneWidget);
  });

  testWidgets('Junior: 詳細に外部への共有（コピー）は出ない', (tester) async {
    await _pump(tester, prefs: {'ageBand': 'junior'});
    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();
    await _reveal(tester, const Key('save_button'));
    expect(find.byKey(const Key('copy_button')), findsNothing);
    expect(find.byKey(const Key('save_button')), findsOneWidget);
  });

  testWidgets('無料プランの保存上限（20件）で保存できない', (tester) async {
    await _pump(tester, prefs: {
      'ageBand': 'adult',
      'saved': [for (var i = 0; i < 20; i++) 'dummy_$i'],
    });
    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();
    await _reveal(tester, const Key('save_button'));
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pump();
    expect(find.textContaining('20件'), findsOneWidget);
  });

  testWidgets('英語の端末では英語で表示される', (tester) async {
    await _pump(tester, deviceLanguage: 'en');
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('未対応言語の端末は英語にフォールバック', (tester) async {
    await _pump(tester, deviceLanguage: 'fr');
    expect(find.text('Language'), findsOneWidget);
  });

  group('差別化機能', () {
    Future<void> openFirstDetail(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
    }

    WrapText title(WidgetTester tester) =>
        tester.widget<WrapText>(find.byKey(const Key('detail_title')));

    testWidgets('親子モード: 大人が「就学前向け」の説明に切り替えられる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openFirstDetail(tester);
      final own = title(tester).text;
      expect(find.byKey(const Key('view_kids')), findsOneWidget);
      expect(find.byKey(const Key('view_junior')), findsOneWidget);

      await tester.tap(find.byKey(const Key('view_kids')));
      await tester.pumpAndSettle();
      final kids = title(tester).text;
      expect(kids, isNot(equals(own)));

      await tester.tap(find.byKey(const Key('view_own')));
      await tester.pumpAndSettle();
      expect(title(tester).text, own);
    });

    testWidgets('親子モード: 子どもモードには切り替えが出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openFirstDetail(tester);
      expect(find.byKey(const Key('view_kids')), findsNothing);
    });

    testWidgets('二言語表示: 日本語の本文の下に英語を出せる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openFirstDetail(tester);
      expect(find.byKey(const Key('bilingual_title')), findsNothing);
      await _reveal(tester, const Key('bilingual_toggle'));
      await tester.tap(find.byKey(const Key('bilingual_toggle')));
      await tester.pumpAndSettle();
      final en = tester.widget<Text>(find.byKey(const Key('bilingual_title'))).data!;
      expect(RegExp(r'[A-Za-z]').hasMatch(en), isTrue);
    });

    testWidgets('「知ってた」を保存し、設定に知ってた率が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openFirstDetail(tester);
      await _reveal(tester, const Key('knew_it'));
      await tester.tap(find.byKey(const Key('knew_it')));
      await tester.pumpAndSettle();
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('knowledge'), hasLength(1));

      await _back(tester);
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      expect(find.textContaining('100%'), findsOneWidget);
    });

    testWidgets('Teen/Adult: 詳細を開くと読んだ日が記録され、連続日数が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(find.byKey(const Key('streak_label')), findsOneWidget);
      await openFirstDetail(tester);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('readDays'), ['2026-10-23']);
      await _back(tester);
      expect(find.text('連続1日'), findsOneWidget);
    });

    testWidgets('Junior: ストリークは出ず、読んだ日も記録しない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      expect(find.byKey(const Key('streak_label')), findsNothing);
      await openFirstDetail(tester);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('readDays'), isNull);
    });

    testWidgets('Kids: ○×クイズに答えられる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await tester.tap(find.byKey(const Key('quiz_button')));
      await tester.pumpAndSettle();
      expect(find.text('ほんとかな？'), findsOneWidget);
      await tester.tap(find.byKey(const Key('quiz_true')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quiz_result')), findsOneWidget);
    });

    testWidgets('Adult の詳細にはクイズは出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openFirstDetail(tester);
      expect(find.byKey(const Key('quiz_button')), findsNothing);
    });
  });

  group('毎日の通知（端末内）', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
    }

    testWidgets('Kids には通知の設定がなく、予定もない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids', 'notifyEnabled': true});
      expect(_lastNotifications!.lastScheduled, isNull);
      await openSettings(tester);
      await _solveGate(tester);
      expect(find.byKey(const Key('notify_switch')), findsNothing);
    });

    testWidgets('Adult: オンにすると許可を求め、14日ぶんが予定される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(_lastNotifications!.lastScheduled, isNull); // 既定はオフ
      await openSettings(tester);
      await tester.tap(find.byKey(const Key('notify_switch')));
      await tester.pumpAndSettle();

      final n = _lastNotifications!;
      expect(n.permissionRequests, 1);
      expect(n.lastScheduled, hasLength(14));
      expect(n.lastScheduled!.first.fireAt.hour, 7);
      // 通知の本文は、その日の雑学のタイトル。タイトルは空でない
      expect(n.lastScheduled!.first.body, isNotEmpty);
      expect(n.lastScheduled!.first.title, '雑学コレ！');
      final sp = await SharedPreferences.getInstance();
      expect(sp.getBool('notifyEnabled'), isTrue);
    });

    testWidgets('許可されなかったらオンにならず、案内が出る', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, notifications: FakeNotifications(grant: false));
      await openSettings(tester);
      await tester.tap(find.byKey(const Key('notify_switch')));
      await tester.pumpAndSettle();
      expect(find.textContaining('通知が許可されていません'), findsOneWidget);
      expect(_lastNotifications!.lastScheduled, isNull);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getBool('notifyEnabled'), isNot(true));
    });

    testWidgets('オフにすると予定が消える', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'notifyEnabled': true});
      expect(_lastNotifications!.lastScheduled, hasLength(14));
      await openSettings(tester);
      await tester.tap(find.byKey(const Key('notify_switch')));
      await tester.pumpAndSettle();
      expect(_lastNotifications!.lastScheduled, isNull);
    });

    testWidgets('時刻を変えると予定が作り直される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'notifyEnabled': true});
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      container.read(settingsProvider.notifier).setNotifyTime(8, 30);
      await tester.pumpAndSettle();
      final first = _lastNotifications!.lastScheduled!.first.fireAt;
      expect((first.hour, first.minute), (8, 30));
    });

    testWidgets('Junior: オンにするには保護者ゲートが必要', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openSettings(tester);
      await tester.tap(find.byKey(const Key('notify_switch')));
      await tester.pumpAndSettle();
      expect(find.text('保護者の方へ確認'), findsOneWidget);
      expect(_lastNotifications!.permissionRequests, 0);
      await _solveGate(tester);
      expect(_lastNotifications!.permissionRequests, 1);
      expect(_lastNotifications!.lastScheduled, isNotNull);
    });

    testWidgets('Junior: ゲートをやめたらオンにならない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openSettings(tester);
      await tester.tap(find.byKey(const Key('notify_switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('やめる'));
      await tester.pumpAndSettle();
      expect(_lastNotifications!.permissionRequests, 0);
      expect(_lastNotifications!.lastScheduled, isNull);
    });

    testWidgets('子どもモードに切り替えると通知はオフになる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'notifyEnabled': true});
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      container.read(settingsProvider.notifier).setAgeBand(AgeBand.junior);
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).notifyEnabled, isFalse);
      expect(_lastNotifications!.lastScheduled, isNull);
    });
  });

  group('表示の崩れ防止', () {
    testWidgets('Kids の日本語は単語の途中で折り返さない（単語ごとの Text になる）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      final title = tester.widget<WrapText>(find.byKey(const Key('kids_title')));
      expect(title.wordWrap, isTrue);
      expect(title.text.contains(' '), isTrue);
      // 単語ごとに別の Text になっている
      final words = find.descendant(
          of: find.byKey(const Key('kids_title')), matching: find.byType(Text));
      expect(words.evaluate().length, greaterThan(1));
    });

    testWidgets('Kids の下のボタンは短い文言で、2行以上に折り返さない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      for (final key in ['kids_listen', 'kids_next']) {
        final box = tester.getSize(find.byKey(Key(key)));
        expect(box.height, lessThan(90), reason: key);
      }
    });

    testWidgets('Adult のホームは絞り込みが横スクロールで、一覧が画面の上半分から始まる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      final todayLabel = tester.getTopLeft(find.text('きょうの雑学'));
      expect(todayLabel.dy, lessThan(400));
    });
  });

  group('絞り込み', () {
    testWidgets('絞り込みボタンからカテゴリーを選ぶと、一覧がそのカテゴリーだけになる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(find.byType(FilterChip), findsNothing); // ホームにチップは並べない
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'むし'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();

      expect(find.text('絞り込み（1）'), findsOneWidget);
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('categories'), ['bugs']);
      // 表示されたカードのカテゴリー表示は「むし」だけ
      expect(find.text('どうぶつ'), findsNothing);
      expect(find.text('たべもの'), findsNothing);
      expect(find.text('むし'), findsWidgets);
    });

    testWidgets('リセットで絞り込みが解除される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'categories': ['bugs']});
      expect(find.text('絞り込み（1）'), findsOneWidget);
      await tester.tap(find.text('リセット'));
      await tester.pumpAndSettle();
      expect(find.text('絞り込み'), findsOneWidget);
    });

    testWidgets('Junior にはシーンの絞り込みは出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await tester.tap(find.byKey(const Key('filter_button')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilterChip, '友だちと'), findsNothing);
      expect(find.widgetWithText(FilterChip, 'むし'), findsOneWidget);
    });
  });

  group('ライブラリ（検索・フィルター）', () {
    Future<void> openLibrary(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_library')));
      await tester.pumpAndSettle();
    }

    int count(WidgetTester tester) {
      final text = tester.widget<Text>(find.byKey(const Key('results_count'))).data!;
      return int.parse(text.replaceAll('件', ''));
    }

    testWidgets('Kids にはライブラリの入口がない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      expect(find.byKey(const Key('open_library')), findsNothing);
    });

    testWidgets('全件が出て、検索で絞れる（ひらがなでもカタカナでも）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openLibrary(tester);
      final all = count(tester);
      expect(all, 60);

      await tester.enterText(find.byKey(const Key('search_field')), 'ラッコ');
      await tester.pumpAndSettle();
      expect(count(tester), 1);

      await tester.enterText(find.byKey(const Key('search_field')), 'らっこ');
      await tester.pumpAndSettle();
      expect(count(tester), 1);
    });

    testWidgets('英語のことばでも日本語の雑学が見つかる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openLibrary(tester);
      await tester.enterText(find.byKey(const Key('search_field')), 'otter');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('result_sea_otters_hold_hands')), findsOneWidget);
    });

    testWidgets('一致しないと案内が出て、消すと全件に戻る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openLibrary(tester);
      await tester.enterText(find.byKey(const Key('search_field')), 'zzzzqqq');
      await tester.pumpAndSettle();
      expect(count(tester), 0);
      expect(find.textContaining('見つかりませんでした'), findsOneWidget);
      await tester.tap(find.byKey(const Key('search_clear')));
      await tester.pumpAndSettle();
      expect(count(tester), 60);
    });

    testWidgets('ジャンルで絞り込める', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openLibrary(tester);
      await tester.tap(find.byKey(const Key('library_filter_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'むし'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();
      expect(count(tester), 10);
      expect(find.text('絞り込み（1）'), findsOneWidget);
    });

    testWidgets('状態で絞り込める（保存済み・知らなかった・未評価）', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'saved': ['ant_strong', 'honey_never_spoils'],
        'knowledge': ['ant_strong:learned', 'rice_half_world:knew'],
      });
      await openLibrary(tester);
      Future<void> pick(String key) async {
        await tester.tap(find.byKey(const Key('library_filter_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('閉じる'));
        await tester.pumpAndSettle();
      }

      await pick('status_saved');
      expect(count(tester), 2);
      await pick('status_saved'); // 解除
      await pick('status_learned');
      expect(count(tester), 1);
      await pick('status_learned');
      await pick('status_unrated');
      expect(count(tester), 58); // 60件のうち評価済み2件を除く
    });

    testWidgets('無料の Adult は、無料の範囲外の雑学に鍵がつき、タップでプレミアム案内', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openLibrary(tester);
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
      await tester.tap(find.byIcon(Icons.lock_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('購入機能は準備中です'), findsOneWidget);
    });

    testWidgets('Junior はすべて開ける（鍵なし）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openLibrary(tester);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('保存した雑学は、無料でも鍵がつかない', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'saved': ['ant_strong'],
      });
      await openLibrary(tester);
      await tester.enterText(find.byKey(const Key('search_field')), 'アリ');
      await tester.pumpAndSettle();
      final card = find.byKey(const Key('result_ant_strong'));
      expect(card, findsOneWidget);
      expect(find.descendant(of: card, matching: find.byIcon(Icons.lock_outline)), findsNothing);
    });
  });

  group('関心事', () {
    testWidgets('未登録のホームには登録を促すカードが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(find.byKey(const Key('interests_empty')), findsOneWidget);
      expect(find.byKey(const Key('interests_section')), findsNothing);
    });

    testWidgets('ジャンルを登録すると、ホームに「あなたの関心」が出る（無料は2件）', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'interestCategories': ['bugs', 'vehicles'],
      });
      expect(find.byKey(const Key('interests_section')), findsOneWidget);
      expect(find.text('あなたの関心'), findsOneWidget);
      final section = find.byKey(const Key('interests_section'));
      final cards = find.descendant(of: section, matching: find.byIcon(Icons.chevron_right));
      expect(cards.evaluate().length, 2);
      // 出ているのは登録したジャンルのものだけ
      final labels = find.descendant(of: section, matching: find.textContaining(RegExp('^(むし|のりもの)\$')));
      expect(labels.evaluate().length, 2);
    });

    testWidgets('キーワードを登録すると、そのことばに合う雑学が出る', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'interestKeywords': ['ラッコ'],
      });
      final section = find.byKey(const Key('interests_section'));
      expect(section, findsOneWidget);
      expect(find.descendant(of: section, matching: find.textContaining('ラッコ')), findsWidgets);
    });

    testWidgets('関心の画面でジャンルとキーワードを登録・削除できる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byKey(const Key('interests_register')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('interest_cat_space')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('keyword_field')), '宇宙');
      await tester.tap(find.byKey(const Key('keyword_add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('keyword_宇宙')), findsOneWidget);

      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('interestCategories'), ['space']);
      expect(sp.getStringList('interestKeywords'), ['宇宙']);

      // 同じことばは重複して登録されない
      await tester.enterText(find.byKey(const Key('keyword_field')), '宇宙');
      await tester.tap(find.byKey(const Key('keyword_add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('keyword_宇宙')), findsOneWidget);

      // 削除
      await tester.tap(find.descendant(
          of: find.byKey(const Key('keyword_宇宙')), matching: find.byIcon(Icons.clear)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('keyword_宇宙')), findsNothing);
      expect(sp.getStringList('interestKeywords'), isEmpty);
    });

    testWidgets('キーワードは10個まで', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'interestKeywords': [for (var i = 0; i < 10; i++) 'ことば$i'],
      });
      await tester.tap(find.byKey(const Key('interests_edit')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('keyword_field')), 'あと1つ');
      await tester.tap(find.byKey(const Key('keyword_add')));
      await tester.pumpAndSettle();
      expect(find.textContaining('10個まで'), findsOneWidget);
      expect(find.byKey(const Key('keyword_あと1つ')), findsNothing);
    });

    testWidgets('オンボーディングで選んだジャンルは関心事になり、絞り込み（一覧）にはならない', (tester) async {
      await _pump(tester);
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('birth_year_dropdown')));
      await tester.pumpAndSettle();
      await _pickYear(tester, 1990);
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'むし'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding_next')));
      await tester.pumpAndSettle();
      final sp = await SharedPreferences.getInstance();
      expect(sp.getStringList('interestCategories'), ['bugs']);
      expect(sp.getStringList('categories'), isNull);
      expect(find.byKey(const Key('interests_section')), findsOneWidget);
    });

    testWidgets('Kids は登録した「すきなもの」のジャンルだけが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids', 'interestCategories': ['vehicles']});
      // 乗り物の雑学のタイトルだけが出る。読み上げ文で確認できないので、1枚送って全部乗り物か確かめる
      final seen = <String>{};
      for (var i = 0; i < 6; i++) {
        seen.add(tester.widget<WrapText>(find.byKey(const Key('kids_title'))).text);
        await tester.tap(find.byKey(const Key('kids_next')));
        await tester.pumpAndSettle();
      }
      expect(seen.length, greaterThan(1));
      // 乗り物のカテゴリーは10件、Kids 向けに全部ある
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      final pool = container.read(poolProvider);
      expect(pool.map((t) => t.category).toSet(), {'vehicles'});
    });

    testWidgets('Kids には関心事の入口がない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      expect(find.byKey(const Key('interests_empty')), findsNothing);
      expect(find.byKey(const Key('interests_section')), findsNothing);
    });

    testWidgets('設定から関心事の画面を開ける', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open_interests')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('keyword_field')), findsOneWidget);
    });
  });
}
