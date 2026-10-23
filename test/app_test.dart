import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/app.dart';
import 'package:knowly/data/trivia_repository.dart';
import 'package:knowly/models/quiz.dart';
import 'package:knowly/models/trivia.dart';
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

Future<FakeTts> _pump(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String deviceLanguage = 'ja',
}) async {
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

    Text title(WidgetTester tester) =>
        tester.widget<Text>(find.byKey(const Key('detail_title')));

    testWidgets('親子モード: 大人が「就学前向け」の説明に切り替えられる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openFirstDetail(tester);
      final own = title(tester).data;
      expect(find.byKey(const Key('view_kids')), findsOneWidget);
      expect(find.byKey(const Key('view_junior')), findsOneWidget);

      await tester.tap(find.byKey(const Key('view_kids')));
      await tester.pumpAndSettle();
      final kids = title(tester).data;
      expect(kids, isNot(equals(own)));

      await tester.tap(find.byKey(const Key('view_own')));
      await tester.pumpAndSettle();
      expect(title(tester).data, own);
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
}
