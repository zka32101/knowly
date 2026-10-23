import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/app.dart';
import 'package:knowly/data/trivia_repository.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/calendar_event.dart';
import 'package:knowly/models/myth.dart';
import 'package:knowly/models/quiz.dart';
import 'package:knowly/models/trivia.dart';
import 'package:knowly/models/why_link.dart';
import 'package:knowly/services/notifications.dart';
import 'package:knowly/widgets/ja_wrap_text.dart';
import 'package:knowly/services/tts.dart';
import 'package:knowly/state/providers.dart';
import 'package:knowly/state/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTts implements TtsService {
  final spoken = <String>[];
  final languages = <String>[];
  final rates = <double?>[];
  @override
  Future<void> speak(String text, {required String language, double? rate}) async {
    spoken.add(text);
    languages.add(language);
    rates.add(rate);
  }
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
  final why = jsonDecode(File('assets/trivia/why_chains.json').readAsStringSync())
      as Map<String, dynamic>;
  return TriviaRepository(
    (raw['items'] as List)
        .map((e) => Trivia.fromJson(e as Map<String, dynamic>))
        .toList(),
    quizzes: (quiz['items'] as List)
        .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    whyLinks: (why['links'] as List)
        .map((e) => WhyLink.fromJson(e as Map<String, dynamic>))
        .toList(),
    myths: ((jsonDecode(File('assets/trivia/myths.json').readAsStringSync())
            as Map<String, dynamic>)['items'] as List)
        .map((e) => Myth.fromJson(e as Map<String, dynamic>))
        .toList(),
    events: ((jsonDecode(File('assets/trivia/calendar.json').readAsStringSync())
            as Map<String, dynamic>)['items'] as List)
        .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

FakeNotifications? _lastNotifications;

Future<FakeTts> _pump(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String deviceLanguage = 'ja',
  FakeNotifications? notifications,
  String? deviceRegion = 'JP',
  DateTime? now,
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
      nowProvider.overrideWithValue(now ?? DateTime(2026, 10, 23)),
      deviceRegionProvider.overrideWithValue(deviceRegion),
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

/// 設定画面など縦に長い画面で、遅延生成される項目が見える位置までスクロールする。
Future<void> _scrollTo(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(find.byKey(key), 200,
      scrollable: find.byType(Scrollable).last);
  await tester.ensureVisible(find.byKey(key));
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
      await _scrollTo(tester, const Key('stats_tile'));
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
      await _scrollTo(tester, const Key('open_interests'));
      await tester.tap(find.byKey(const Key('open_interests')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('keyword_field')), findsOneWidget);
    });
  });

  group('国タグ（国限定の雑学）', () {
    Future<int> libraryCount(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_library')));
      await tester.pumpAndSettle();
      return int.parse(tester
          .widget<Text>(find.byKey(const Key('results_count')))
          .data!
          .replaceAll(RegExp(r'[^0-9]'), ''));
    }

    testWidgets('日本では、日本限定の雑学（4件）も出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, deviceRegion: 'JP');
      expect(await libraryCount(tester), 60);
    });

    testWidgets('アメリカでは、日本限定の雑学が出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, deviceRegion: 'US');
      expect(await libraryCount(tester), 56);
      await tester.enterText(find.byKey(const Key('search_field')), '新幹線');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('result_shinkansen_1964')), findsNothing);
    });

    testWidgets('「すべての国」を選ぶと、日本限定の雑学も出る', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'regionMode': 'all'}, deviceRegion: 'US');
      expect(await libraryCount(tester), 60);
    });

    testWidgets('国を選ぶ設定は、端末の国より優先される', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'regionMode': 'JP'}, deviceRegion: 'US');
      expect(await libraryCount(tester), 60);
    });

    testWidgets('端末に国がなくても、日本語の端末は日本として扱う', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, deviceRegion: null);
      expect(await libraryCount(tester), 60);
    });

    testWidgets('英語の端末で国が不明なら、国限定の雑学は出ない', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, deviceRegion: null, deviceLanguage: 'en');
      expect(await libraryCount(tester), 56);
    });

    testWidgets('設定で国を変えられる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, deviceRegion: 'US');
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('region_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('すべての国').last);
      await tester.pumpAndSettle();
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('regionMode'), 'all');
    });
  });

  group('季節・記念日・時間帯のおすすめ', () {
    testWidgets('夏の昼は「夏にぴったり」の雑学が出る（北半球）', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'seasonMode': 'north'}, now: DateTime(2026, 7, 15, 13));
      expect(find.byKey(const Key('timing_section')), findsOneWidget);
      expect(find.text('いまのおすすめ'), findsOneWidget);
      expect(find.text('夏にぴったり'), findsOneWidget);
    });

    testWidgets('南半球では7月は冬。「冬にぴったり」が出て、夏のおすすめは出ない', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'seasonMode': 'south'}, now: DateTime(2026, 7, 15, 13));
      expect(find.text('冬にぴったり'), findsOneWidget);
      expect(find.text('夏にぴったり'), findsNothing);
    });

    testWidgets('季節をオフにすると、季節の理由は出ない', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'seasonMode': 'off'}, now: DateTime(2026, 7, 15, 13));
      expect(find.textContaining('にぴったり'), findsNothing);
    });

    testWidgets('夜は「夜にぴったり」の雑学が出る', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'seasonMode': 'off'}, now: DateTime(2026, 7, 15, 22));
      expect(find.text('夜にぴったり'), findsOneWidget);
    });

    testWidgets('新幹線の開業日（10/1）は、日本では今日の雑学が新幹線になる', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, now: DateTime(2026, 10, 1, 9), deviceRegion: 'JP');
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      expect(container.read(feedProvider).first.id, 'shinkansen_1964');
    });

    testWidgets('同じ日でも、アメリカでは新幹線の雑学は今日の雑学にならない', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, now: DateTime(2026, 10, 1, 9), deviceRegion: 'US');
      final container = ProviderScope.containerOf(tester.element(find.byKey(const Key('open_settings'))));
      expect(container.read(feedProvider).map((t) => t.id), isNot(contains('shinkansen_1964')));
    });

    testWidgets('今日の雑学と通知の雑学は同じ（季節考慮でも一致）', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'notifyEnabled': true, 'seasonMode': 'north'},
          now: DateTime(2026, 7, 15, 6));
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      final today = container.read(feedProvider).first;
      final scheduled = _lastNotifications!.lastScheduled!;
      expect(scheduled.first.body, isNotEmpty);
      final level = container.read(levelResolverProvider)(today)!;
      expect(scheduled.first.body, level.title);
    });

    testWidgets('Kids には「いまのおすすめ」の欄が出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'}, now: DateTime(2026, 7, 15, 13));
      expect(find.byKey(const Key('timing_section')), findsNothing);
    });

    testWidgets('設定で季節の設定を変えられる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('season_mode'));
      await tester.tap(find.text('南半球'));
      await tester.pumpAndSettle();
      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('seasonMode'), 'south');
    });
  });

  group('Junior のふりがな表記と読み上げ', () {
    testWidgets('Junior の詳細は「漢字（かんじ）」の形で表示される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      final title = tester.widget<WrapText>(find.byKey(const Key('detail_title'))).text;
      expect(RegExp(r'[\u4E00-\u9FFF]+（[ぁ-んー]+）').hasMatch(title) || !RegExp(r'[\u4E00-\u9FFF]').hasMatch(title), isTrue);
    });

    testWidgets('読み上げは読み（かっこの中）を除いて渡す', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'junior'});
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('detail_listen')));
      await tester.pump();
      expect(tts.spoken, hasLength(1));
      expect(tts.spoken.first.contains('（'), isFalse);
    });
  });

  group('関連する雑学', () {
    testWidgets('詳細に関連する雑学が出て、開ける', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'regionMode': 'all'});
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      final first = container.read(feedProvider).first;
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await _scrollTo(tester, Key('related_${first.related.first}'));
      expect(find.text('関連する雑学'), findsOneWidget);
      await tester.tap(find.byKey(Key('related_${first.related.first}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
    });
  });

  group('なぜ？チェーン', () {
    Future<void> openDetail(WidgetTester tester, String id) async {
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      container.read(routerProvider).push('/detail/$id');
      await tester.pumpAndSettle();
    }

    String titleOf(WidgetTester tester) =>
        tester.widget<WrapText>(find.byKey(const Key('detail_title'))).text;

    testWidgets('詳細に「なぜ？」が出て、押すと次の雑学に進む', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openDetail(tester, 'ice_floats');
      final before = titleOf(tester);
      await _scrollTo(tester, const Key('why_card'));
      expect(find.byKey(const Key('why_card')), findsOneWidget);
      expect(find.text('では、リンゴが水に浮くのはなぜ？'), findsOneWidget);
      await tester.tap(find.byKey(const Key('why_card')));
      await tester.pumpAndSettle();
      expect(titleOf(tester), isNot(before));
      expect(titleOf(tester), contains('リンゴ'));
    });

    testWidgets('3回つなげると、ほめことばが出る（2回では出ない）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openDetail(tester, 'ice_floats'); // chain 0
      for (var i = 1; i <= 3; i++) {
        await _scrollTo(tester, const Key('why_card'));
        await tester.tap(find.byKey(const Key('why_card')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('why_cheer')), i >= 3 ? findsOneWidget : findsNothing,
            reason: '$i回目');
      }
      expect(find.text('「なぜ？」を3回つづけたよ！すごい！'), findsOneWidget);
    });

    testWidgets('つづきがない雑学には「なぜ？」が出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openDetail(tester, 'honey_never_spoils');
      expect(find.byKey(const Key('why_card')), findsNothing);
    });

    testWidgets('Junior の質問は、ひらがな（漢字なし）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openDetail(tester, 'ice_floats');
      await _scrollTo(tester, const Key('why_card'));
      final q = tester.widget<WrapText>(find.byKey(const Key('why_question'))).text;
      expect(q, 'じゃあ、りんごは どうして うくの？');
    });

    testWidgets('次の雑学が国限定で表示できないとき、「なぜ？」は出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, deviceRegion: 'US');
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      expect(container.read(whyStepProvider('shinkansen_1964')), isNull);
    });

    testWidgets('英語の端末では、質問も英語', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, deviceLanguage: 'en', deviceRegion: 'US');
      await openDetail(tester, 'ice_floats');
      await _scrollTo(tester, const Key('why_card'));
      expect(find.text('Then why does an apple float?'), findsOneWidget);
    });

    testWidgets('Kids: 「なぜ？」で次の雑学に進み、「つぎへ」で元の並びに戻る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      // 「なぜ？」のある雑学が出るまで送る
      var tries = 0;
      while (find.byKey(const Key('kids_why')).evaluate().isEmpty && tries < 30) {
        await tester.tap(find.byKey(const Key('kids_next')));
        await tester.pumpAndSettle();
        tries++;
      }
      expect(find.byKey(const Key('kids_why')), findsOneWidget, reason: '$tries 回送っても出ない');
      final before = tester.widget<WrapText>(find.byKey(const Key('kids_title'))).text;
      await tester.tap(find.byKey(const Key('kids_why')));
      await tester.pumpAndSettle();
      final after = tester.widget<WrapText>(find.byKey(const Key('kids_title'))).text;
      expect(after, isNot(before));
      await tester.tap(find.byKey(const Key('kids_next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('why_cheer')), findsNothing);
    });
  });

  group('ほんと？うそ？', () {
    Future<void> openMyths(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_myths')));
      await tester.pumpAndSettle();
    }

    int total(WidgetTester tester) {
      final t = tester.widget<Text>(find.byKey(const Key('myth_progress'))).data!;
      return int.parse(t.split('/').last.trim());
    }

    testWidgets('全年代にホームから入口がある', (tester) async {
      for (final band in ['kids', 'junior', 'teen', 'adult']) {
        await _pump(tester, prefs: {'ageBand': band});
        expect(find.byKey(const Key('open_myths')), findsOneWidget, reason: band);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('問題数は年代で変わる（Kids は難しいものを除く）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await openMyths(tester);
      expect(total(tester), 16);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openMyths(tester);
      expect(total(tester), 20);
    });

    testWidgets('答えると判定・解説が出て、つぎへ進める。最後に結果が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await openMyths(tester);
      final n = total(tester);
      for (var i = 0; i < n; i++) {
        expect(find.byKey(const Key('myth_statement')), findsOneWidget);
        expect(find.byKey(const Key('myth_verdict')), findsNothing);
        await tester.tap(find.byKey(const Key('myth_false'))); // ずっと「うそ」と答える
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('myth_verdict')), findsOneWidget);
        expect(find.byKey(const Key('myth_explanation')), findsOneWidget);
        await tester.tap(find.byKey(const Key('myth_next')));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('myth_result')), findsOneWidget);
      // Kids 向け16問のうち「本当」は4問 → 「うそ」と答え続けると12問正解
      expect(find.text('16もんちゅう 12もん せいかい！'), findsOneWidget);
      await tester.tap(find.byKey(const Key('myth_again')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('myth_statement')), findsOneWidget);
    });

    testWidgets('Kids の文章はひらがなで、Adult は一般向けの表記', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await openMyths(tester);
      final kids = tester.widget<WrapText>(find.byKey(const Key('myth_statement')));
      expect(RegExp(r'[\u4E00-\u9FFF]').hasMatch(kids.text), isFalse);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openMyths(tester);
      final adult = tester.widget<WrapText>(find.byKey(const Key('myth_statement')));
      expect(adult.wordWrap, isFalse);
    });

    testWidgets('問題の順番は日によって変わる', (tester) async {
      final firsts = <String>{};
      for (var d = 1; d <= 6; d++) {
        await _pump(tester, prefs: {'ageBand': 'adult'}, now: DateTime(2026, 10, d, 9));
        final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
        firsts.add(container.read(mythDeckProvider).first.id);
        await tester.pumpWidget(const SizedBox());
      }
      expect(firsts.length, greaterThan(1));
    });

    testWidgets('雑学とつながる問題には「くわしく よむ」が出て、雑学を開ける', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'regionMode': 'all'});
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      final deck = container.read(mythDeckProvider);
      await openMyths(tester);
      // 雑学とつながる問題が出るまで進める
      var i = 0;
      while (deck[i].factId == null) {
        await tester.tap(find.byKey(const Key('myth_true')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('myth_next')));
        await tester.pumpAndSettle();
        i++;
      }
      await tester.tap(find.byKey(const Key('myth_true')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('myth_read')), findsOneWidget);
      await tester.tap(find.byKey(const Key('myth_read')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
    });

    testWidgets('英語の端末では英語の文章', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, deviceLanguage: 'en', deviceRegion: 'US');
      await openMyths(tester);
      final text = tester.widget<WrapText>(find.byKey(const Key('myth_statement'))).text;
      expect(RegExp(r'[A-Za-z]').hasMatch(text), isTrue);
      expect(RegExp(r'[ぁ-んァ-ヶ]').hasMatch(text), isFalse);
    });
  });

  group('今日は何の日', () {
    Future<void> openToday(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_today')));
      await tester.pumpAndSettle();
    }

    testWidgets('記念日の日は、ホームにバナーが出て、画面に記念日が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, now: DateTime(2026, 4, 22, 9));
      expect(find.byKey(const Key('today_banner')), findsOneWidget);
      expect(find.text('今日は「アースデー(地球の日)」'), findsOneWidget);
      await tester.tap(find.byKey(const Key('today_banner')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('event_earth_day')), findsOneWidget);
      expect(find.text('4月22日'), findsOneWidget);
    });

    testWidgets('記念日でない日は、バナーが出ず、画面に案内が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, now: DateTime(2026, 10, 23, 9));
      expect(find.byKey(const Key('today_banner')), findsNothing);
      await openToday(tester);
      expect(find.byKey(const Key('today_none')), findsOneWidget);
    });

    testWidgets('これから2週間の記念日が、日付つきで出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, now: DateTime(2026, 4, 20, 9));
      await openToday(tester);
      // 4/22 アースデー（2日後）・4/23 世界本の日（3日後）
      expect(find.byKey(const Key('event_earth_day')), findsOneWidget);
      expect(find.byKey(const Key('event_book_day')), findsOneWidget);
      expect(find.byKey(const Key('event_date_earth_day')), findsOneWidget);
    });

    testWidgets('日本の行事は日本でだけ出る（アメリカでは出ない）', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, now: DateTime(2026, 7, 7, 9), deviceRegion: 'JP');
      expect(find.text('今日は「七夕」'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, now: DateTime(2026, 7, 7, 9), deviceRegion: 'US');
      expect(find.byKey(const Key('today_banner')), findsNothing);
    });

    testWidgets('「すべての国」を選ぶと、国限定の行事も出る', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'regionMode': 'all'},
          now: DateTime(2026, 7, 7, 9),
          deviceRegion: 'US');
      expect(find.byKey(const Key('today_banner')), findsOneWidget);
    });

    testWidgets('記念日つきの雑学（新幹線 10/1）も、今日は何の日に出て、雑学を開ける', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, now: DateTime(2026, 10, 1, 9));
      await openToday(tester);
      expect(find.byKey(const Key('event_fact:shinkansen_1964')), findsOneWidget);
      await tester.tap(find.byKey(const Key('event_read_fact:shinkansen_1964')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
    });

    testWidgets('同じ雑学につながる記念日は、重ねて出さない（バレンタインとカカオ）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, now: DateTime(2026, 2, 14, 9));
      await openToday(tester);
      expect(find.byKey(const Key('event_valentine')), findsOneWidget);
      expect(find.byKey(const Key('event_fact:cacao_money')), findsNothing);
    });

    testWidgets('Kids の入口からも見られて、文章はひらがな', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'}, now: DateTime(2026, 4, 22, 9));
      expect(find.byKey(const Key('today_banner')), findsNothing); // Kids のホームにバナーはない
      await openToday(tester);
      expect(find.text('アースデイ'), findsOneWidget);
    });

    testWidgets('英語の端末では、日付も記念日も英語', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'},
          now: DateTime(2026, 4, 22, 9),
          deviceLanguage: 'en',
          deviceRegion: 'US');
      await openToday(tester);
      expect(find.text('Apr 22'), findsOneWidget);
      expect(find.text('Earth Day'), findsOneWidget);
    });
  });

  group('雑学で英語', () {
    Future<void> openById(WidgetTester tester, String id) async {
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      container.read(routerProvider).push('/detail/$id');
      await tester.pumpAndSettle();
    }

    testWidgets('日本語の画面では「英語のことば」が出て、Adult は漢字も添える', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openById(tester, 'octopus_blue_blood');
      await _scrollTo(tester, const Key('vocab_section'));
      expect(tester.widget<Text>(find.byKey(const Key('vocab_title'), skipOffstage: false)).data,
          '英語のことば');
      expect(find.text('octopus'), findsOneWidget);
      expect(find.text('たこ（蛸）'), findsOneWidget);
    });

    testWidgets('Junior はかなだけ（漢字を添えない）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openById(tester, 'octopus_blue_blood');
      await _scrollTo(tester, const Key('vocab_section'));
      expect(find.text('たこ'), findsOneWidget);
      expect(find.text('たこ（蛸）'), findsNothing);
    });

    testWidgets('ことばをタップすると、英語をゆっくり発音する', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      await openById(tester, 'octopus_blue_blood');
      await _scrollTo(tester, const Key('vocab_octopus'));
      await tester.tap(find.byKey(const Key('vocab_octopus')));
      await tester.pump();
      expect(tts.spoken.last, 'octopus');
      expect(tts.languages.last, 'en');
      expect(tts.rates.last, lessThan(0.4));
    });

    testWidgets('「英語で聞く」で、雑学の英語版を英語で読み上げる', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      await openById(tester, 'octopus_blue_blood');
      await _scrollTo(tester, const Key('listen_other'));
      expect(find.text('英語で聞く'), findsOneWidget);
      await tester.tap(find.byKey(const Key('listen_other')));
      await tester.pump();
      expect(tts.languages.last, 'en');
      expect(RegExp(r'[A-Za-z]').hasMatch(tts.spoken.last), isTrue);
      expect(RegExp(r'[ぁ-んァ-ヶ一-龥]').hasMatch(tts.spoken.last), isFalse);
    });

    testWidgets('英語の画面では、日本語のことばを学べる（日本語で聞く）', (tester) async {
      final tts = await _pump(tester,
          prefs: {'ageBand': 'adult'}, deviceLanguage: 'en', deviceRegion: 'US');
      await openById(tester, 'octopus_blue_blood');
      // 「日本語で聞く」は、ことば一覧より上にある
      await _scrollTo(tester, const Key('listen_other'));
      expect(find.text('Listen in Japanese'), findsOneWidget);
      await tester.tap(find.byKey(const Key('listen_other')));
      await tester.pump();
      expect(tts.languages.last, 'ja');
      expect(RegExp(r'[ぁ-んァ-ヶ一-龥]').hasMatch(tts.spoken.last), isTrue);

      await _scrollTo(tester, const Key('vocab_octopus'));
      expect(tester.widget<Text>(find.byKey(const Key('vocab_title'), skipOffstage: false)).data,
          'Japanese words');
      expect(find.text('たこ（蛸）'), findsOneWidget); // 主役は日本語
      await tester.tap(find.byKey(const Key('vocab_octopus')));
      await tester.pump();
      expect(tts.spoken.last, 'たこ');
      expect(tts.languages.last, 'ja');
    });

    testWidgets('読み上げでは、Junior の読み（かっこ）を外す', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'junior'}, deviceLanguage: 'en', deviceRegion: 'US');
      // 英語の画面の Junior が、日本語版を聞く → 日本語版は漢字（よみ）表記
      await openById(tester, 'octopus_blue_blood');
      await _scrollTo(tester, const Key('listen_other'));
      await tester.tap(find.byKey(const Key('listen_other')));
      await tester.pump();
      expect(tts.spoken.last.contains('（'), isFalse);
    });
  });
}
