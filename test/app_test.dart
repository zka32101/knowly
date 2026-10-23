import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowly/app.dart';
import 'package:knowly/data/trivia_repository.dart';
import 'package:knowly/services/home_widget_service.dart';
import 'package:knowly/services/listen_background.dart';
import 'package:knowly/screens/quiz_battle_screen.dart';
import 'package:knowly/l10n/regions.dart';
import 'package:knowly/services/share.dart';
import 'package:knowly/widgets/quiz_play.dart';
import 'package:knowly/models/age_band.dart';
import 'package:knowly/models/calendar_event.dart';
import 'package:knowly/models/myth.dart';
import 'package:knowly/models/project.dart';
import 'package:knowly/models/quiz.dart';
import 'package:knowly/models/trivia.dart';
import 'package:knowly/models/why_link.dart';
import 'package:knowly/services/entitlement.dart';
import 'package:knowly/services/notifications.dart';
import 'package:knowly/widgets/ja_wrap_text.dart';
import 'package:knowly/services/tts.dart';
import 'package:knowly/state/listen_controller.dart';
import 'package:knowly/state/providers.dart';
import 'package:knowly/state/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTts implements TtsService {
  final spoken = <String>[];
  final languages = <String>[];
  final rates = <double?>[];

  /// false にすると、`speakAndWait` は [completeCurrent] を呼ぶまで終わらない（連続再生のテスト用）。
  bool autoComplete = true;
  final _pending = <Completer<void>>[];

  @override
  Future<void> speak(String text, {required String language, double? rate}) async {
    spoken.add(text);
    languages.add(language);
    rates.add(rate);
  }

  @override
  Future<void> speakAndWait(String text, {required String language, double? rate}) async {
    await speak(text, language: language, rate: rate);
    if (autoComplete) return;
    final c = Completer<void>();
    _pending.add(c);
    await c.future;
  }

  /// いま読んでいる雑学の読み上げを終わらせる。
  void completeCurrent() {
    if (_pending.isNotEmpty) _pending.removeAt(0).complete();
  }
  @override
  Future<void> stop() async {
    stops++;
    // 本物と同じく、止めると待っていた読み上げが終わる。
    for (final c in _pending) {
      if (!c.isCompleted) c.complete();
    }
    _pending.clear();
  }

  int stops = 0;
}

class FakeListenBackground implements ListenBackground {
  void Function()? onPlay, onPause, onNext, onPrevious;
  final updates = <({String title, bool playing})>[];
  int stops = 0;
  @override
  void bind({
    required void Function() onPlay,
    required void Function() onPause,
    required void Function() onNext,
    required void Function() onPrevious,
  }) {
    this.onPlay = onPlay;
    this.onPause = onPause;
    this.onNext = onNext;
    this.onPrevious = onPrevious;
  }

  @override
  Future<void> update({
    required String title,
    required String appName,
    required bool playing,
    required bool hasPrevious,
    required bool hasNext,
  }) async =>
      updates.add((title: title, playing: playing));

  @override
  Future<void> stop() async => stops++;
}

FakeListenBackground? _lastBackground;

class FakeHomeWidget implements HomeWidgetService {
  WidgetContent? last;
  int updates = 0;
  int clears = 0;
  @override
  Future<void> update(WidgetContent content) async {
    last = content;
    updates++;
  }

  @override
  Future<void> clear() async => clears++;
}

FakeHomeWidget? _lastWidget;

class FakeShare implements ShareService {
  Uint8List? png;
  String? text;
  String? sharedText;
  @override
  Future<void> shareText(String text) async => sharedText = text;
  @override
  Future<void> shareImage(Uint8List png, {required String text}) async {
    this.png = png;
    this.text = text;
  }
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

TriviaRepository _repo({bool withSources = false}) {
  final raw = jsonDecode(File('assets/trivia/trivia.json').readAsStringSync())
      as Map<String, dynamic>;
  final quiz = jsonDecode(File('assets/trivia/quiz.json').readAsStringSync())
      as Map<String, dynamic>;
  final why = jsonDecode(File('assets/trivia/why_chains.json').readAsStringSync())
      as Map<String, dynamic>;
  return TriviaRepository(
    (raw['items'] as List).map((e) {
      final m = e as Map<String, dynamic>;
      if (withSources) {
        m['sources'] = [
          {'title': 'テスト出典', 'publisher': '国立テスト館', 'url': 'https://example.com'},
        ];
      }
      return Trivia.fromJson(m);
    }).toList(),
    quizzes: (quiz['items'] as List)
        .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    choiceQuizzes: ((jsonDecode(File('assets/trivia/quiz_choice.json').readAsStringSync())
            as Map<String, dynamic>)['items'] as List)
        .map((e) => ChoiceQuiz.fromJson(e as Map<String, dynamic>))
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
    projects: ((jsonDecode(File('assets/trivia/projects.json').readAsStringSync())
            as Map<String, dynamic>)['items'] as List)
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class FakePurchases implements EntitlementService {
  FakePurchases({
    this.premium = false,
    this.offerList = const [
      PurchaseOffer(id: 'monthly', period: PurchasePeriod.monthly, priceString: '¥300'),
      PurchaseOffer(
          id: 'annual', period: PurchasePeriod.annual, priceString: '¥1,800', hasFreeTrial: true),
    ],
    this.outcome = PurchaseOutcome.success,
    this.restoreResult = true,
  });

  bool premium;
  final List<PurchaseOffer> offerList;
  PurchaseOutcome outcome;
  bool restoreResult;
  int isPremiumCalls = 0;
  int offersCalls = 0;
  final purchased = <String>[];

  @override
  Future<bool> isPremium() async {
    isPremiumCalls++;
    return premium;
  }

  @override
  Future<List<PurchaseOffer>> offers() async {
    offersCalls++;
    return offerList;
  }

  @override
  Future<PurchaseOutcome> purchase(PurchaseOffer offer) async {
    purchased.add(offer.id);
    if (outcome == PurchaseOutcome.success) premium = true;
    return outcome;
  }

  @override
  Future<bool> restore() async {
    if (restoreResult) premium = true;
    return restoreResult;
  }
}

FakeNotifications? _lastNotifications;

Future<FakeTts> _pump(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String deviceLanguage = 'ja',
  FakeNotifications? notifications,
  String? deviceRegion = 'JP',
  DateTime? now,
  EntitlementService? entitlement,
  bool withSources = false,
  ShareService? share,
}) async {
  final notif = _lastNotifications = notifications ?? FakeNotifications();
  final homeWidget = _lastWidget = FakeHomeWidget();
  final background = _lastBackground = FakeListenBackground();
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final tts = FakeTts();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      triviaRepositoryProvider.overrideWithValue(_repo(withSources: withSources)),
      if (share != null) shareServiceProvider.overrideWithValue(share),
      deviceLanguageProvider.overrideWithValue(deviceLanguage),
      nowProvider.overrideWithValue(now ?? DateTime(2026, 10, 23)),
      deviceRegionProvider.overrideWithValue(deviceRegion),
      if (entitlement != null) entitlementServiceProvider.overrideWithValue(entitlement),
      ttsProvider.overrideWithValue(tts),
      notificationServiceProvider.overrideWithValue(notif),
      homeWidgetServiceProvider.overrideWithValue(homeWidget),
      listenBackgroundProvider.overrideWithValue(background),
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

/// 下のタブをたどって、キーのボタンを見つけて押す（ホーム → あそぶ → あつめる → さがす の順に探す）。
Future<void> _open(WidgetTester tester, Key key) async {
  if (find.byKey(key).evaluate().isEmpty) {
    for (final t in const ['tab_home', 'tab_play', 'tab_collect', 'tab_explore']) {
      final tab = find.byKey(Key(t));
      if (tab.evaluate().isEmpty) continue;
      await tester.tap(tab);
      await tester.pumpAndSettle();
      if (find.byKey(key).evaluate().isNotEmpty) break;
    }
  }
  final vertical =
      find.byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical);
  if (find.byKey(key).evaluate().isNotEmpty && vertical.evaluate().isNotEmpty) {
    await tester.ensureVisible(find.byKey(key));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

/// 下のタブを切り替える。
Future<void> _tab(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
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
      expect(n.lastScheduled!.first.title, 'ノウリー');
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
      await _open(tester, const Key('open_library'));
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
      await _scrollTo(tester, const Key('interests_empty'));
      expect(find.byKey(const Key('interests_empty')), findsOneWidget);
      expect(find.byKey(const Key('interests_section')), findsNothing);
    });

    testWidgets('ジャンルを登録すると、ホームに「あなたの関心」が出る（無料は2件）', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'interestCategories': ['bugs', 'vehicles'],
      });
      await _scrollTo(tester, const Key('interests_section'));
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
      await _scrollTo(tester, const Key('interests_section'));
      final section = find.byKey(const Key('interests_section'));
      expect(section, findsOneWidget);
      expect(find.descendant(of: section, matching: find.textContaining('ラッコ')), findsWidgets);
    });

    testWidgets('関心の画面でジャンルとキーワードを登録・削除できる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _scrollTo(tester, const Key('interests_register'));
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
      await _scrollTo(tester, const Key('interests_edit'));
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
      await _scrollTo(tester, const Key('interests_section'));
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
      await _open(tester, const Key('open_interests'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('keyword_field')), findsOneWidget);
    });
  });

  group('国タグ（国限定の雑学）', () {
    Future<int> libraryCount(WidgetTester tester) async {
      await _open(tester, const Key('open_library'));
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
      await _scrollTo(tester, const Key('timing_section'));
      expect(find.byKey(const Key('timing_section')), findsOneWidget);
      expect(find.text('いまのおすすめ'), findsOneWidget);
      expect(find.text('夏にぴったり'), findsOneWidget);
    });

    testWidgets('南半球では7月は冬。「冬にぴったり」が出て、夏のおすすめは出ない', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'seasonMode': 'south'}, now: DateTime(2026, 7, 15, 13));
      await _scrollTo(tester, const Key('timing_section'));
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
      await _scrollTo(tester, const Key('timing_section'));
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
      await _open(tester, const Key('open_myths'));
      await tester.pumpAndSettle();
    }

    int total(WidgetTester tester) {
      final t = tester.widget<Text>(find.byKey(const Key('myth_progress'))).data!;
      return int.parse(t.split('/').last.trim());
    }

    testWidgets('全年代にホームから入口がある', (tester) async {
      for (final band in ['kids', 'junior', 'teen', 'adult']) {
        await _pump(tester, prefs: {'ageBand': band});
        await _tab(tester, 'tab_play');
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
      await _open(tester, const Key('open_today'));
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

  group('ながら聞き', () {
    testWidgets('入口は Teen/Adult だけ', (tester) async {
      for (final band in ['kids', 'junior']) {
        await _pump(tester, prefs: {'ageBand': band});
        if (band == 'junior') await _tab(tester, 'tab_explore');
        expect(find.byKey(const Key('open_listen')), findsNothing, reason: band);
        await tester.pumpWidget(const SizedBox());
      }
      for (final band in ['teen', 'adult']) {
        await _pump(tester, prefs: {'ageBand': band});
        await _tab(tester, 'tab_explore');
        expect(find.byKey(const Key('open_listen')), findsOneWidget, reason: band);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('再生すると今日の雑学から読み、終わったら次へ進む', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      tts.autoComplete = false;
      await _open(tester, const Key('open_listen'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('listen_progress')), findsOneWidget);
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      final queue = container.read(listenQueueProvider);
      expect(queue.length, inInclusiveRange(2, 10));
      expect(queue.first.id, container.read(feedProvider).first.id); // 先頭は今日の雑学
      expect(queue.map((t) => t.id).toSet().length, queue.length); // 重複なし

      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      expect(tts.spoken, hasLength(1));
      expect(find.byIcon(Icons.pause), findsOneWidget);

      tts.completeCurrent();
      await tester.pump();
      await tester.pump();
      expect(tts.spoken, hasLength(2));
      expect(find.text('2 / ${queue.length}'), findsOneWidget);

      // 一時停止
      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(tts.spoken, hasLength(2));
    });

    testWidgets('速さを変えられる', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      tts.autoComplete = false;
      await _open(tester, const Key('open_listen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('はやい'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      expect(tts.rates.last, 0.5);
    });

    testWidgets('一覧をタップすると、その雑学へ移動する', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _open(tester, const Key('open_listen'));
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('listen_item_2'));
      await tester.tap(find.byKey(const Key('listen_item_2')));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, 2000));
      await tester.pumpAndSettle();
      expect(find.textContaining('3 / '), findsOneWidget);
    });

    testWidgets('画面を閉じると読み上げが止まる', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      tts.autoComplete = false;
      await _open(tester, const Key('open_listen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      final before = tts.stops;
      await _back(tester);
      expect(tts.stops, greaterThan(before));
    });
  });

  group('自由研究ネタ帳', () {
    Future<void> openProjects(WidgetTester tester) async {
      await _open(tester, const Key('open_projects'));
      await tester.pumpAndSettle();
    }

    testWidgets('入口は Junior/Teen/Adult のクイックリンク。Kids にはない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      expect(find.byKey(const Key('open_projects')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      for (final band in ['junior', 'teen', 'adult']) {
        await _pump(tester, prefs: {'ageBand': band});
        await _tab(tester, 'tab_explore');
        expect(find.byKey(const Key('open_projects')), findsOneWidget, reason: band);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('テーマの一覧に12件が出て、むずかしさ・時間・おとなバッジが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openProjects(tester);
      expect(find.byKey(const Key('project_ice_float')), findsOneWidget);
      await _scrollTo(tester, const Key('project_string_phone'));
      expect(find.textContaining('おとなといっしょに'), findsWidgets);
      await _scrollTo(tester, const Key('project_sun_shadow'));
      expect(find.byKey(const Key('project_sun_shadow')), findsOneWidget);
    });

    testWidgets('Junior は「漢字（よみ）」の形で表示される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openProjects(tester);
      await tester.tap(find.byKey(const Key('project_ice_float')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('project_title'))).data,
          '氷（こおり）は水（みず）にうくのはなぜ？');
    });

    testWidgets('Adult は漢字だけ（読みの記法は出ない）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openProjects(tester);
      await tester.tap(find.byKey(const Key('project_ice_float')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('project_title'))).data, '氷は水にうくのはなぜ？');
      await _scrollTo(tester, const Key('project_step_0'));
      final step = tester.widget<Text>(find.byKey(const Key('project_step_0'))).data!;
      expect(step.contains('{'), isFalse);
      expect(step.contains('（'), isFalse);
    });

    testWidgets('安全上の注意が出る。おとなが必要なテーマにはバッジが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openProjects(tester);
      await _scrollTo(tester, const Key('project_string_phone'));
      await tester.tap(find.byKey(const Key('project_string_phone')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project_safety')), findsOneWidget);
      expect(find.byKey(const Key('project_adult_badge')), findsOneWidget);
    });

    testWidgets('おとな不要のテーマにはバッジが出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      await openProjects(tester);
      await tester.tap(find.byKey(const Key('project_ice_float')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project_adult_badge')), findsNothing);
    });

    testWidgets('雑学の詳細から自由研究に進める（つながる雑学だけ）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'});
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      container.read(routerProvider).push('/detail/ice_floats');
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('open_project_from_fact'));
      await tester.tap(find.byKey(const Key('open_project_from_fact')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project_title')), findsOneWidget);
      await _back(tester);
      // 自由研究がない雑学（はちみつ）には出ない
      container.read(routerProvider).push('/detail/honey_never_spoils');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('open_project_from_fact')), findsNothing);
    });

    testWidgets('英語の端末では英語の文章', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'}, deviceLanguage: 'en', deviceRegion: 'US');
      await openProjects(tester);
      await tester.tap(find.byKey(const Key('project_ice_float')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const Key('project_title'))).data,
          'Why does ice float on water?');
    });
  });

  group('プレミアムの購入', () {
    Future<void> openPremium(WidgetTester tester) async {
      final container = ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));
      container.read(routerProvider).push('/premium');
      await tester.pumpAndSettle();
    }

    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    testWidgets('購入の設定がないときは「準備中」で、無料プランのまま', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openPremium(tester);
      expect(find.byKey(const Key('premium_unavailable')), findsOneWidget);
      expect(containerOf(tester).read(isPremiumNowProvider), isFalse);
    });

    testWidgets('ストアが返す価格をそのまま表示し、トライアルがあれば示す', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: FakePurchases());
      await openPremium(tester);
      expect(tester.widget<Text>(find.byKey(const Key('price_monthly'))).data, '¥300');
      expect(tester.widget<Text>(find.byKey(const Key('price_annual'))).data, '¥1,800');
      expect(find.text('無料トライアルあり'), findsOneWidget); // 年額だけ
      expect(find.byKey(const Key('premium_unavailable')), findsNothing);
    });

    testWidgets('購入に成功すると、プレミアムになる（過去30日・鍵が外れる）', (tester) async {
      final fake = FakePurchases();
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: fake);
      final c = containerOf(tester);
      expect(c.read(feedDaysProvider), 7);
      expect(c.read(unlockedIdsProvider), isNotNull); // 無料は一部だけ
      await openPremium(tester);
      await tester.tap(find.byKey(const Key('buy_annual')));
      await tester.pumpAndSettle();
      expect(fake.purchased, ['annual']);
      expect(find.text('ご購入ありがとうございます！'), findsOneWidget);
      expect(find.byKey(const Key('premium_active')), findsOneWidget);
      expect(c.read(isPremiumNowProvider), isTrue);
      expect(c.read(feedDaysProvider), 30);
      expect(c.read(unlockedIdsProvider), isNull); // すべて開ける
    });

    testWidgets('キャンセルしたら、プレミアムにならない', (tester) async {
      final fake = FakePurchases(outcome: PurchaseOutcome.cancelled);
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: fake);
      await openPremium(tester);
      await tester.tap(find.byKey(const Key('buy_monthly')));
      await tester.pumpAndSettle();
      expect(find.text('購入をやめました'), findsOneWidget);
      expect(containerOf(tester).read(isPremiumNowProvider), isFalse);
    });

    testWidgets('購入に失敗したら案内が出て、プレミアムにならない', (tester) async {
      final fake = FakePurchases(outcome: PurchaseOutcome.failed);
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: fake);
      await openPremium(tester);
      await tester.tap(find.byKey(const Key('buy_monthly')));
      await tester.pumpAndSettle();
      expect(find.textContaining('購入できませんでした'), findsOneWidget);
      expect(containerOf(tester).read(isPremiumNowProvider), isFalse);
    });

    testWidgets('購入の復元: できたらプレミアム、なければ案内', (tester) async {
      final fake = FakePurchases(restoreResult: false);
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: fake);
      await openPremium(tester);
      await _scrollTo(tester, const Key('premium_restore'));
      await tester.tap(find.byKey(const Key('premium_restore')));
      await tester.pumpAndSettle();
      expect(find.text('復元できる購入が見つかりませんでした'), findsOneWidget);
      expect(containerOf(tester).read(isPremiumNowProvider), isFalse);
      fake.restoreResult = true;
      ScaffoldMessenger.of(tester.element(find.byKey(const Key('premium_restore'))))
          .clearSnackBars();
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('premium_restore'));
      await tester.tap(find.byKey(const Key('premium_restore')));
      await tester.pumpAndSettle();
      expect(find.text('購入を復元しました'), findsOneWidget);
      expect(containerOf(tester).read(isPremiumNowProvider), isTrue);
    });

    testWidgets('すでにプレミアムなら、案内が出て購入ボタンは出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: FakePurchases(premium: true));
      await openPremium(tester);
      expect(find.byKey(const Key('premium_active')), findsOneWidget);
      expect(find.byKey(const Key('buy_monthly')), findsNothing);
    });

    testWidgets('Kids/Junior では、購入の SDK を一度も呼ばない（通信を発生させない）', (tester) async {
      for (final band in ['kids', 'junior']) {
        final fake = FakePurchases(premium: true);
        await _pump(tester, prefs: {'ageBand': band}, entitlement: fake);
        expect(containerOf(tester).read(isPremiumNowProvider), isFalse, reason: band);
        expect(fake.isPremiumCalls, 0, reason: band);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('Teen/Adult では、起動時にプレミアムの状態を確認する', (tester) async {
      final fake = FakePurchases(premium: true);
      await _pump(tester, prefs: {'ageBand': 'teen'}, entitlement: fake);
      expect(fake.isPremiumCalls, greaterThan(0));
      expect(containerOf(tester).read(isPremiumNowProvider), isTrue);
    });

    testWidgets('プレミアムなら、ライブラリに鍵が出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, entitlement: FakePurchases(premium: true));
      await _open(tester, const Key('open_library'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('英語の端末では、英語の案内', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult'},
          deviceLanguage: 'en',
          deviceRegion: 'US',
          entitlement: FakePurchases());
      await openPremium(tester);
      expect(find.text('Monthly'), findsOneWidget);
      await _scrollTo(tester, const Key('premium_restore'));
      expect(find.text('Restore purchases'), findsOneWidget);
    });
  });

  group('プライバシーとデータ削除', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    Future<void> openPrivacy(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('privacy_tile'));
      await tester.tap(find.byKey(const Key('privacy_tile')));
      await tester.pumpAndSettle();
    }

    testWidgets('Adult: 説明が出て、削除すると初期状態（オンボーディング）に戻る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'saved': ['x']});
      await openPrivacy(tester);
      expect(find.text('広告も、利用状況の分析（アナリティクス）もありません。'), findsOneWidget);
      await _scrollTo(tester, const Key('privacy_delete'));
      await tester.tap(find.byKey(const Key('privacy_delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('privacy_delete_cancel')));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(settingsProvider).ageBand, AgeBand.adult);

      await tester.tap(find.byKey(const Key('privacy_delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('privacy_delete_confirm')));
      await tester.pumpAndSettle();
      final s = containerOf(tester).read(settingsProvider);
      expect(s.ageBand, isNull);
      expect(s.saved, isEmpty);
      expect(_lastNotifications!.cancels, greaterThan(0));
      expect(find.byKey(const Key('privacy_delete')), findsNothing);
    });

    testWidgets('Kids: 保護者ゲートを通らないと削除できない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await _solveGate(tester);
      await _scrollTo(tester, const Key('privacy_tile'));
      await tester.tap(find.byKey(const Key('privacy_tile')));
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('privacy_delete'));
      await tester.tap(find.byKey(const Key('privacy_delete')));
      await tester.pumpAndSettle();
      await _solveGate(tester, wrong: true);
      expect(find.byKey(const Key('privacy_delete_confirm')), findsNothing);
      expect(containerOf(tester).read(settingsProvider).ageBand, AgeBand.kids);
    });
  });

  group('出典と画像共有', () {
    testWidgets('Adult: 出典があれば詳細に表示される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'}, withSources: true);
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await _reveal(tester, const Key('sources_title'));
      expect(find.text('テスト出典（国立テスト館）'), findsOneWidget);
    });

    testWidgets('出典がなければ、見出しも出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await _reveal(tester, const Key('copy_button'));
      expect(find.byKey(const Key('sources_title')), findsNothing);
    });

    testWidgets('Junior: 出典も画像共有も出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'junior'}, withSources: true);
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await _reveal(tester, const Key('save_button'));
      expect(find.byKey(const Key('sources_title')), findsNothing);
      expect(find.byKey(const Key('share_button')), findsNothing);
    });

    testWidgets('Adult: 画像でシェアすると、PNG が共有サービスに渡る', (tester) async {
      final share = FakeShare();
      await _pump(tester, prefs: {'ageBand': 'adult'}, share: share);
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await _reveal(tester, const Key('share_button'));
      await tester.tap(find.byKey(const Key('share_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('share_card')), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('share_confirm')));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      expect(share.png, isNotNull);
      // PNG のシグネチャ
      expect(share.png!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(find.byKey(const Key('share_card')), findsNothing);
    });
  });

  group('クイズ対戦', () {
    Future<void> tapSetup(WidgetTester tester, Key key) async {
      await tester.scrollUntilVisible(find.byKey(key), 200,
          scrollable: find
              .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
              .first);
      await tester.ensureVisible(find.byKey(key));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
    }

    Future<void> openQuiz(WidgetTester tester) async {
      await _open(tester, const Key('open_quiz'));
      await tester.pumpAndSettle();
    }

    // 画面の問題文から正解を知る必要はない。固定の答え（○）で最後まで進める。
    Future<void> playAll(WidgetTester tester, int players, int rounds) async {
      for (var r = 0; r < rounds; r++) {
        for (var p = 0; p < players; p++) {
          await tapSetup(tester, const Key('battle_true'));
        }
        await tapSetup(tester, const Key('battle_next'));
      }
    }

    testWidgets('1人: 5問やって、結果が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openQuiz(tester);
      await tapSetup(tester, const Key('battle_kind_tf'));
      await tapSetup(tester, const Key('battle_start'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('battle_turn')), findsNothing); // 1人は順番表示なし
      await playAll(tester, 1, 5);
      expect(find.byKey(const Key('battle_final')), findsOneWidget);
      expect(find.textContaining('もん せいかい'), findsOneWidget);
      await tester.tap(find.byKey(const Key('battle_again')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('battle_statement')), findsOneWidget);
    });

    testWidgets('4人: 順番に答え、名前も変えられて、順位が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openQuiz(tester);
      await tester.tap(find.byKey(const Key('battle_players_4')));
      await tapSetup(tester, const Key('battle_kind_tf'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('battle_name_1')), 'ハナ');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tapSetup(tester, const Key('battle_start'));
      await tester.pumpAndSettle();
      expect(find.textContaining('プレイヤー1 の ばん'), findsNothing);
      expect(find.textContaining('プレイヤー1'), findsWidgets);
      await tester.tap(find.byKey(const Key('battle_true')));
      await tester.pumpAndSettle();
      expect(find.textContaining('ハナ'), findsWidgets); // 2人目の番
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('battle_true')));
        await tester.pumpAndSettle();
      }
      // 全員同じ答え → 4人とも同じ結果
      expect(find.byKey(const Key('battle_result_3')), findsOneWidget);
      await tapSetup(tester, const Key('battle_next'));
      await playAll(tester, 4, 4);
      expect(find.byKey(const Key('battle_rank_0')), findsOneWidget);
      expect(find.byKey(const Key('battle_rank_3')), findsOneWidget);
      expect(find.text('ひきわけ！'), findsOneWidget); // 全員同じ答えなので同点
    });

    testWidgets('選択式だけ: 4択の問題が出て、選んで進める', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openQuiz(tester);
      await tapSetup(tester, const Key('battle_kind_choice'));
      await tapSetup(tester, const Key('battle_start'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('battle_true')), findsNothing);
      await tapSetup(tester, const Key('battle_opt_1'));
      expect(find.byKey(const Key('battle_answer')), findsOneWidget);
      expect(find.byKey(const Key('battle_result_0')), findsOneWidget);
    });

    testWidgets('ジャンル: 選んだカテゴリーの問題だけが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openQuiz(tester);
      await tapSetup(tester, const Key('battle_genre_space'));
      await tapSetup(tester, const Key('battle_start'));
      await tester.pumpAndSettle();
      final game = tester.state<State>(find.byType(QuizPlay)).widget as QuizPlay;
      expect(game.game.questions.every((q) => q.category == 'space'), isTrue);
      expect(game.game.questions, isNotEmpty);
    });

    testWidgets('時間制限: 時間切れは不正解になり、次の人へ進む', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openQuiz(tester);
      await tester.tap(find.byKey(const Key('battle_players_2')));
      await tapSetup(tester, const Key('battle_time_10'));
      await tapSetup(tester, const Key('battle_start'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('battle_timer')), findsOneWidget);
      await tester.pump(const Duration(seconds: 10)); // 1人目が時間切れ
      await tester.pump();
      expect(find.textContaining('プレイヤー2 の ばん'), findsNothing);
      expect(find.textContaining('プレイヤー2'), findsWidgets);
      await tester.pump(const Duration(seconds: 10)); // 2人目も時間切れ → 発表
      await tester.pump();
      expect(find.byKey(const Key('battle_answer')), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNWidgets(2));
    });

    testWidgets('Kids でも遊べる（通信なし・ひらがな）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await _open(tester, const Key('open_quiz'));
      await tester.pumpAndSettle();
      expect(find.text('なんにんで あそぶ？'), findsOneWidget);
    });
  });

  group('復習・今日のチャレンジ・バッジ・保護者向け', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    Future<void> tapV(WidgetTester tester, Key key) async {
      if (find.byKey(key).evaluate().isEmpty) {
        await tester.scrollUntilVisible(find.byKey(key), 200,
            scrollable: find
                .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
                .first);
      }
      await tester.ensureVisible(find.byKey(key));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
    }

    /// 出ている問題の形（○× / 選択式）に合わせて、とにかく答えて進める。
    Future<void> answerRound(WidgetTester tester) async {
      if (find.byKey(const Key('battle_true')).evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('battle_true')));
        await tester.pumpAndSettle();
      } else {
        await tapV(tester, const Key('battle_opt_0'));
      }
      await tapV(tester, const Key('battle_next'));
    }

    const learnedPrefs = <String, Object>{
      'ageBand': 'adult',
      'knowledge': ['octopus_blue_blood:learned'],
      'reviews': ['octopus_blue_blood:0:2026-10-22'],
    };

    testWidgets('「知らなかった」を押すと、復習の予定に入る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      await _reveal(tester, const Key('learned_it'));
      await tester.tap(find.byKey(const Key('learned_it')));
      await tester.pumpAndSettle();
      final reviews = containerOf(tester).read(settingsProvider).reviews;
      expect(reviews, hasLength(1));
      expect(reviews.values.first.due, '2026-10-24');
      await tester.tap(find.byKey(const Key('knew_it'))); // 「知ってた」にすると予定は消える
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(settingsProvider).reviews, isEmpty);
    });

    testWidgets('復習: 期限が来た雑学が出て、正解すると予定が先へ進む', (tester) async {
      await _pump(tester, prefs: learnedPrefs);
      expect(find.byKey(const Key('review_banner')), findsOneWidget);
      await tester.tap(find.byKey(const Key('review_banner')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('battle_true')), findsOneWidget); // タコは○×のみ
      await tester.tap(find.byKey(const Key('battle_true'))); // 正解は ○
      await tester.pumpAndSettle();
      final e = containerOf(tester).read(settingsProvider).reviews['octopus_blue_blood']!;
      expect(e.box, 1);
      expect(e.due, '2026-10-26');
      expect(containerOf(tester).read(settingsProvider).quizCorrect, 1);
      await tester.tap(find.byKey(const Key('battle_next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('review_done')), findsOneWidget);
    });

    testWidgets('復習: 間違えると明日に戻る', (tester) async {
      await _pump(tester, prefs: learnedPrefs);
      await _open(tester, const Key('open_review'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('battle_false')));
      await tester.pumpAndSettle();
      final e = containerOf(tester).read(settingsProvider).reviews['octopus_blue_blood']!;
      expect(e.box, 0);
      expect(e.due, '2026-10-24');
    });

    testWidgets('期限が来ていなければ、復習の入口は出ない', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'knowledge': ['octopus_blue_blood:learned'],
        'reviews': ['octopus_blue_blood:0:2026-10-24'],
      });
      expect(find.byKey(const Key('review_banner')), findsNothing);
    });

    testWidgets('今日のチャレンジ: 3問やると記録され、もう一度開くと結果になる。Adult は共有できる', (tester) async {
      final share = FakeShare();
      await _pump(tester, prefs: {'ageBand': 'adult'}, share: share);
      await _open(tester, const Key('open_daily'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await answerRound(tester);
      }
      expect(find.byKey(const Key('daily_marks')), findsOneWidget);
      final results = containerOf(tester).read(settingsProvider).dailyResults;
      expect(results['2026-10-23'], hasLength(3));
      expect(containerOf(tester).read(settingsProvider).quizAnswered, 3);
      await tester.tap(find.byKey(const Key('daily_share')));
      await tester.pumpAndSettle();
      expect(share.sharedText, contains('2026-10-23'));
      // もう一度開いても、続きから遊べず結果だけ
      await tester.tap(find.byKey(const Key('daily_exit')));
      await tester.pumpAndSettle();
      await _open(tester, const Key('open_daily'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('daily_marks')), findsOneWidget);
      expect(find.byKey(const Key('battle_statement')), findsNothing);
    });

    testWidgets('今日のチャレンジ: Junior は共有ボタンが出ない', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'junior',
        'dailyResults': ['2026-10-23:101'],
      });
      await _open(tester, const Key('open_daily'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('daily_marks')), findsOneWidget);
      expect(find.text('✅❌✅'), findsOneWidget);
      expect(find.byKey(const Key('daily_share')), findsNothing);
    });

    testWidgets('バッジ: 条件を満たしたものが手に入る', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'readDays': ['2026-10-21', '2026-10-22', '2026-10-23'],
        'quizCorrect': 10,
        'quizAnswered': 12,
      });
      await _open(tester, const Key('open_badges'));
      expect(find.byKey(const Key('badge_streak_3')), findsOneWidget);
      expect(find.text('3にち れんぞく'), findsOneWidget);
      final count = find.byKey(const Key('badges_count'));
      expect(tester.widget<Text>(count).data, contains('2 /')); // 3日連続 + クイズ10問
    });

    testWidgets('バッジ: Kids には連続日数のバッジがない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await _open(tester, const Key('open_badges'));
      expect(find.byKey(const Key('badge_streak_3')), findsNothing);
      expect(find.byKey(const Key('badge_quizCorrect_10')), findsOneWidget);
    });

    testWidgets('保護者向け: 子どもの設定に「学習のようす」があり、記録から作られる', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'junior',
        'knowledge': ['octopus_blue_blood:learned', 'honey_never_spoils:knew'],
        'quizCorrect': 3,
        'quizAnswered': 4,
      });
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await tapV(tester, const Key('report_tile'));
      await _solveGate(tester);
      expect(find.text('3 / 4 (75%)'), findsOneWidget);
      expect(tester.widget<Text>(find.descendant(
              of: find.byKey(const Key('report_learned')), matching: find.text('1'))).data,
          '1');
      expect(find.byKey(const Key('report_cat_animals')), findsOneWidget);
    });

    testWidgets('Adult の設定には、保護者向けの項目は出ない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      await _scrollTo(tester, const Key('privacy_tile'));
      expect(find.byKey(const Key('report_tile')), findsNothing);
    });

    testWidgets('ひとりクイズの正解数が通算に加わる（対戦の複数人では加わらない）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _open(tester, const Key('open_quiz'));
      await tester.pumpAndSettle();
      await tapV(tester, const Key('battle_kind_tf'));
      await tapV(tester, const Key('battle_start'));
      await tester.tap(find.byKey(const Key('battle_true')));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(settingsProvider).quizAnswered, 1);
    });
  });

  group('ホーム画面ウィジェット', () {
    testWidgets('Adult: 今日から7日ぶんの雑学を書き込む', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      final c = _lastWidget!.last!;
      expect(c.days, hasLength(7));
      expect(c.days.containsKey('2026-10-23'), isTrue);
      expect(c.days['2026-10-23']!.title, isNotEmpty);
      expect(c.appName, 'ノウリー');
      expect(_lastWidget!.clears, 0);
    });

    testWidgets('Kids/Junior: 何も書き込まず、中身を消す', (tester) async {
      for (final band in ['kids', 'junior']) {
        await _pump(tester, prefs: {'ageBand': band});
        expect(_lastWidget!.updates, 0, reason: band);
        expect(_lastWidget!.clears, greaterThan(0), reason: band);
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('ながら聞き: 通知・ロック画面との連携', () {
    testWidgets('再生すると通知に出て、通知の操作で止められる。画面を閉じると片づける', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      tts.autoComplete = false;
      final bg = _lastBackground!;
      await _open(tester, const Key('open_listen'));
      await tester.pumpAndSettle();
      expect(bg.onPause, isNotNull);
      expect(bg.updates, isEmpty); // 再生するまでは通知を出さない
      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      expect(bg.updates.last.playing, isTrue);
      expect(bg.updates.last.title, isNotEmpty);
      bg.onPause!(); // 通知の「一時停止」
      await tester.pump();
      expect(bg.updates.last.playing, isFalse);
      await _back(tester);
      expect(bg.stops, greaterThan(0));
    });
  });

  group('相棒（成長するキャラ）', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    testWidgets('はじめは たまご。雑学を開くと +1、「知らなかった」で +2 になる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(find.byKey(const Key('mascot_card')), findsOneWidget);
      expect(containerOf(tester).read(mascotPointsProvider), 0);
      expect(find.text('🥚'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(mascotPointsProvider), 1);
      await _reveal(tester, const Key('learned_it'));
      await tester.tap(find.byKey(const Key('learned_it')));
      await tester.pumpAndSettle();
      expect(containerOf(tester).read(mascotPointsProvider), 3); // 開いた1 + 知れた2
    });

    testWidgets('同じ雑学を何度開いても、1点だけ', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'seen': ['octopus_blue_blood'],
      });
      expect(containerOf(tester).read(mascotPointsProvider), 1);
      containerOf(tester).read(settingsProvider.notifier).markSeen('octopus_blue_blood');
      expect(containerOf(tester).read(mascotPointsProvider), 1);
    });

    testWidgets('ポイントが増えると見た目が変わり、一覧に「？？？」が残る', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'seen': [for (var i = 0; i < 16; i++) 'fact_$i'],
      });
      expect(find.text('🐥'), findsOneWidget); // 16点 → ちびふくろう
      await tester.tap(find.byKey(const Key('mascot_card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mascot_current')), findsOneWidget);
      expect(find.text('ちびふくろう'), findsWidgets);
      expect(find.text('？？？'), findsWidgets); // まだなっていない姿
    });

    testWidgets('Kids にも出て、見た雑学が記録される', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      expect(find.byKey(const Key('mascot_card')), findsOneWidget);
      expect(containerOf(tester).read(mascotPointsProvider), greaterThan(0));
    });

    testWidgets('データを削除すると たまご に戻る', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'seen': [for (var i = 0; i < 16; i++) 'fact_$i'],
      });
      await containerOf(tester).read(settingsProvider.notifier).resetAll();
      expect(containerOf(tester).read(mascotPointsProvider), 0);
    });
  });

  group('お祝いと相棒の表情', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    testWidgets('初回は基準を決めるだけで、既存の記録はお祝いしない', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'seen': [for (var i = 0; i < 20; i++) 'fact_$i'], // すでに ちびふくろう
        'quizCorrect': 12,
      });
      expect(find.byKey(const Key('celebration')), findsNothing);
      final s = containerOf(tester).read(settingsProvider);
      expect(s.celebratedStage, 2);
      expect(s.celebratedBadges, contains('quizCorrect_10'));
    });

    testWidgets('段階が上がると、お祝いが出て、消えたら記録される', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'seen': [for (var i = 0; i < 4; i++) 'fact_$i'],
        'celebratedStage': 0,
        'celebratedBadges': <String>[],
      });
      expect(find.byKey(const Key('celebration')), findsNothing);
      containerOf(tester).read(settingsProvider.notifier).markSeen('fact_new'); // 5点 → ひよこ
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('celebration')), findsOneWidget);
      expect(find.text('ひよこに なったよ！'), findsOneWidget);
      await tester.pumpAndSettle(); // 3秒で自動で消える
      expect(find.byKey(const Key('celebration')), findsNothing);
      expect(containerOf(tester).read(settingsProvider).celebratedStage, 1);
    });

    testWidgets('バッジを取ると、お祝いが出る（タップで閉じられる）', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'quizCorrect': 9,
        'celebratedStage': 0,
        'celebratedBadges': <String>[],
      });
      containerOf(tester).read(settingsProvider.notifier).recordQuizAnswer(correct: true);
      await tester.pump();
      await tester.pump();
      expect(find.text('バッジを ゲット！'), findsOneWidget);
      await tester.tap(find.byKey(const Key('celebration')));
      await tester.pump();
      expect(find.byKey(const Key('celebration')), findsNothing);
      expect(containerOf(tester).read(settingsProvider).celebratedBadges,
          contains('quizCorrect_10'));
    });

    testWidgets('クイズの発表で、正解なら喜び、不正解ならしょんぼりする', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _open(tester, const Key('open_quiz'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('battle_kind_tf')), 200,
          scrollable: find
              .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
              .first);
      await tester.tap(find.byKey(const Key('battle_kind_tf')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byKey(const Key('battle_start')), 200,
          scrollable: find
              .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
              .first);
      await tester.tap(find.byKey(const Key('battle_start')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('battle_true')));
      await tester.pump();
      final ok = find.byKey(const Key('mascot_face_happy')).evaluate().isNotEmpty;
      final bad = find.byKey(const Key('mascot_face_sad')).evaluate().isNotEmpty;
      expect(ok != bad, isTrue); // どちらか一方
    });

    testWidgets('相棒をさわると、よろこぶ', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byKey(const Key('mascot_card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mascot_face_idle')), findsOneWidget);
      await tester.tap(find.byKey(const Key('mascot_tap')));
      await tester.pump();
      expect(find.byKey(const Key('mascot_face_happy')), findsOneWidget);
    });

    testWidgets('ながら聞き: 読み上げ中は口ぱく、止めると落ち着く', (tester) async {
      final tts = await _pump(tester, prefs: {'ageBand': 'adult'});
      tts.autoComplete = false;
      await _open(tester, const Key('open_listen'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mascot_face_idle')), findsOneWidget);
      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      expect(find.byKey(const Key('mascot_face_speaking')), findsOneWidget);
      await tester.tap(find.byKey(const Key('listen_toggle')));
      await tester.pump();
      expect(find.byKey(const Key('mascot_face_idle')), findsOneWidget);
    });
  });

  group('めくりカード（今日の雑学）', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    testWidgets('おもては「ほんと？うそ？」、タップでめくると答えと本文が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(find.byKey(const Key('flip_front')), findsOneWidget);
      expect(find.byKey(const Key('flip_back')), findsNothing);
      expect(containerOf(tester).read(mascotPointsProvider), 0);
      await tester.tap(find.byKey(const Key('flip_card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('flip_front')), findsNothing);
      expect(find.byKey(const Key('flip_back')), findsOneWidget);
      expect(containerOf(tester).read(mascotPointsProvider), 1); // めくると見たことになる
      await tester.tap(find.byKey(const Key('flip_card'))); // もう一度でおもてに戻る
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('flip_front')), findsOneWidget);
    });

    testWidgets('クイズがある雑学では、裏に ○ か ✕ が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      final today = containerOf(tester).read(feedProvider).first;
      final hasQuiz = containerOf(tester).read(triviaRepositoryProvider).quizFor(today.id) != null;
      await tester.tap(find.byKey(const Key('flip_card')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('flip_answer')).evaluate().isNotEmpty, hasQuiz);
    });

    testWidgets('「くわしく」と右の矢印から、詳細へ進める', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await tester.tap(find.byKey(const Key('flip_open_detail')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
      await _back(tester);
      await tester.tap(find.byKey(const Key('flip_card')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('flip_detail_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
    });
  });

  group('ずかん・カプセル', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    testWidgets('カプセル: あけるとカードが出て、見た雑学になり、今日はもう一度あけられない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _open(tester, const Key('open_capsule'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('capsule_open')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('capsule_opening')), findsOneWidget); // 開く演出
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('capsule_card')), findsOneWidget);
      expect(find.byKey(const Key('capsule_rarity')), findsOneWidget);
      expect(find.byKey(const Key('capsule_new')), findsOneWidget); // はじめて
      final s = containerOf(tester).read(settingsProvider);
      expect(s.capsule, startsWith('2026-10-23:'));
      expect(s.seen, hasLength(1));
      expect(find.byKey(const Key('capsule_open')), findsNothing);
      expect(find.byKey(const Key('capsule_done')), findsOneWidget);
    });

    testWidgets('カプセル: 今日あけ済みなら、同じカードが出る。日付が変われば、またあけられる', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'capsule': '2026-10-23:octopus_blue_blood',
        'seen': ['octopus_blue_blood'],
      });
      await _open(tester, const Key('open_capsule'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('capsule_card')), findsOneWidget);
      expect(find.byKey(const Key('capsule_open')), findsNothing);
    });

    testWidgets('カプセル: 翌日は、またあけられる', (tester) async {
      await _pump(tester,
          prefs: {'ageBand': 'adult', 'capsule': '2026-10-22:octopus_blue_blood'});
      await _open(tester, const Key('open_capsule'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('capsule_open')), findsOneWidget);
    });

    testWidgets('カプセル: Kids でも あけられる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await _open(tester, const Key('open_capsule'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('capsule_open')), findsOneWidget);
    });

    testWidgets('ずかん: 見た雑学のマスが埋まり、まだのマスは押せない', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'seen': ['octopus_blue_blood', 'giraffe_seven_vertebrae'],
      });
      await _open(tester, const Key('open_zukan'));
      await tester.pumpAndSettle();
      final total = containerOf(tester).read(allEligibleProvider).length;
      expect(tester.widget<Text>(find.byKey(const Key('zukan_progress'))).data,
          '2 / $total みつけた');
      // どうぶつだけに絞ると、そのジャンルの数
      await tester.tap(find.byKey(const Key('zukan_cat_animals')));
      await tester.pumpAndSettle();
      final animals = containerOf(tester)
          .read(allEligibleProvider)
          .where((t) => t.category == 'animals')
          .length;
      expect(tester.widget<Text>(find.byKey(const Key('zukan_progress'))).data,
          '2 / $animals みつけた');
      // 見つけたマスを押すと詳細へ
      await tester.tap(find.byKey(const Key('zukan_cell_octopus_blue_blood')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsOneWidget);
    });

    testWidgets('ずかん: まだのマスを押しても何も起きない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'seen': ['octopus_blue_blood']});
      await _open(tester, const Key('open_zukan'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('zukan_cell_honey_never_spoils')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail_title')), findsNothing);
      expect(find.byKey(const Key('zukan_progress')), findsOneWidget);
    });
  });

  group('スワイプ ほんと？うそ？', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    /// いま出ているカードの正解（○ なら true）。
    bool correctNow(WidgetTester tester) {
      final statement = tester.widget<WrapText>(find.byKey(const Key('swipe_statement'))).text;
      return containerOf(tester)
          .read(battlePoolProvider)
          .firstWhere((q) => q.isTrueFalse && q.statement == statement)
          .correct ==
          0;
    }

    Future<void> openSwipe(WidgetTester tester) async {
      await _open(tester, const Key('open_swipe'));
      await tester.pumpAndSettle();
    }

    testWidgets('全部正解すると、れんぞくが伸びて、10問で結果が出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openSwipe(tester);
      for (var i = 0; i < 10; i++) {
        final ok = correctNow(tester);
        await tester.tap(find.byKey(Key(ok ? 'swipe_true' : 'swipe_false')));
        await tester.pumpAndSettle();
        if (i == 1) expect(find.byKey(const Key('swipe_combo')), findsOneWidget);
      }
      expect(find.byKey(const Key('swipe_final')), findsOneWidget);
      expect(find.text('いちばん れんぞく：10'), findsOneWidget);
      expect(containerOf(tester).read(settingsProvider).quizCorrect, 10);
      await tester.tap(find.byKey(const Key('swipe_again')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('swipe_card')), findsOneWidget);
    });

    testWidgets('カードを右にスワイプすると「ほんと」、左だと「うそ」', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openSwipe(tester);
      final first = correctNow(tester);
      await tester.fling(find.byKey(const Key('swipe_card')), const Offset(600, 0), 1500);
      await tester.pumpAndSettle();
      expect(find.byKey(Key(first ? 'swipe_result_ok' : 'swipe_result_ng')), findsOneWidget);
      final second = correctNow(tester);
      await tester.fling(find.byKey(const Key('swipe_card')), const Offset(-600, 0), 1500);
      await tester.pumpAndSettle();
      // 左 = うそ(false)。正解が ✕ なら成功
      expect(find.byKey(Key(!second ? 'swipe_result_ok' : 'swipe_result_ng')), findsOneWidget);
      expect(containerOf(tester).read(settingsProvider).quizAnswered, 2);
    });

    testWidgets('間違えると、れんぞくが0に戻る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await openSwipe(tester);
      for (var i = 0; i < 2; i++) {
        final ok = correctNow(tester);
        await tester.tap(find.byKey(Key(ok ? 'swipe_true' : 'swipe_false')));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('swipe_combo')), findsOneWidget);
      final ok = correctNow(tester);
      await tester.tap(find.byKey(Key(ok ? 'swipe_false' : 'swipe_true'))); // わざと間違える
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('swipe_combo')), findsNothing);
      expect(find.byKey(const Key('swipe_result_ng')), findsOneWidget);
    });

    testWidgets('Kids にも入口があり、あそべる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await _open(tester, const Key('open_swipe'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('swipe_card')), findsOneWidget);
    });
  });

  group('メニュー（下のタブ）', () {
    testWidgets('Adult/Teen/Junior は5つのタブ', (tester) async {
      for (final band in ['junior', 'teen', 'adult']) {
        await _pump(tester, prefs: {'ageBand': band});
        for (final k in ['tab_home', 'tab_play', 'tab_collect', 'tab_explore', 'open_settings']) {
          expect(find.byKey(Key(k)), findsOneWidget, reason: '$band $k');
        }
        expect(find.byType(NavigationDestination), findsNWidgets(5), reason: band);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('Kids は3つのタブで、設定は保護者ゲートの先', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.byKey(const Key('tab_explore')), findsNothing);
      await tester.tap(find.byKey(const Key('open_settings')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('privacy_tile')), findsNothing); // ゲートで止まる
      await _solveGate(tester);
      expect(find.byType(NavigationBar), findsNothing); // 設定は全画面
    });

    testWidgets('タブを切り替えると、それぞれのハブが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _tab(tester, 'tab_play');
      for (final k in ['open_quiz', 'open_swipe', 'open_daily', 'open_myths']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      await _tab(tester, 'tab_collect');
      for (final k in ['open_mascot', 'open_zukan', 'open_capsule', 'open_badges']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      await _tab(tester, 'tab_explore');
      for (final k in ['open_library', 'open_saved', 'open_interests', 'open_today', 'open_listen']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      await _tab(tester, 'open_settings');
      expect(find.byKey(const Key('privacy_tile')), findsNothing); // 先頭付近。下にある
      await _tab(tester, 'tab_home');
      expect(find.byKey(const Key('flip_card')), findsOneWidget);
    });

    testWidgets('ホームにボタンの羅列はなく、おさらいがあるときだけお知らせが出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      for (final k in ['open_quiz', 'open_swipe', 'open_zukan', 'open_badges']) {
        expect(find.byKey(Key(k)), findsNothing, reason: k);
      }
      expect(find.byKey(const Key('review_banner')), findsNothing);
    });

    testWidgets('あそぶ: Kids には「今日は何の日」もあり、さがす系はない', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'kids'});
      await _tab(tester, 'tab_play');
      expect(find.byKey(const Key('open_today')), findsOneWidget);
      expect(find.byKey(const Key('open_quiz')), findsOneWidget);
      expect(find.byKey(const Key('open_library')), findsNothing);
    });

    testWidgets('ハブのカードから遊びの画面へ進み、戻るとタブに戻る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _open(tester, const Key('open_swipe'));
      expect(find.byKey(const Key('swipe_card')), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing); // 遊びの画面は全画面
      await _back(tester);
      expect(find.byKey(const Key('open_swipe')), findsOneWidget); // あそぶタブに戻る
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('おさらいがあるとき、ホームのお知らせとあそぶのカードに件数が出る', (tester) async {
      await _pump(tester, prefs: {
        'ageBand': 'adult',
        'knowledge': ['octopus_blue_blood:learned'],
        'reviews': ['octopus_blue_blood:0:2026-10-22'],
      });
      expect(find.byKey(const Key('review_banner')), findsOneWidget);
      await _tab(tester, 'tab_play');
      expect(find.byKey(const Key('open_review')), findsOneWidget);
    });
  });

  group('多言語（日本語・英語・中国語・韓国語・スペイン語）', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(KnowlyApp)));

    testWidgets('中国語・韓国語・スペイン語の端末では、画面がその言語になり、本文は英語', (tester) async {
      const tabs = {
        'zh': ['首页', '玩', '收集', '探索', '设置'],
        'ko': ['홈', '놀기', '모으기', '찾기', '설정'],
        'es': ['Inicio', 'Jugar', 'Colección', 'Explorar', 'Ajustes'],
      };
      for (final e in tabs.entries) {
        await _pump(tester,
            prefs: {'ageBand': 'adult'}, deviceLanguage: e.key, deviceRegion: null);
        for (final label in e.value) {
          expect(find.text(label), findsWidgets, reason: '${e.key} $label');
        }
        expect(containerOf(tester).read(uiLanguageProvider), e.key);
        expect(containerOf(tester).read(contentLanguageProvider), 'en', reason: e.key);
        // 本文は英語のまま（めくりカードのおもてが英語の文）
        final prompt = tester.widget<WrapText>(find.byKey(const Key('flip_prompt'))).text;
        expect(RegExp(r'[぀-ヿ一-鿿]').hasMatch(prompt), isFalse, reason: '${e.key}: $prompt');
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('日本語の端末は、画面も本文も日本語（ノウリー）', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      expect(find.text('ノウリー'), findsWidgets);
      expect(containerOf(tester).read(contentLanguageProvider), 'ja');
    });

    testWidgets('設定で画面の言語を変えられる。本文のない言語にすると、本文は英語になる', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult'});
      await _tab(tester, 'open_settings');
      await tester.tap(find.byKey(const Key('ui_language_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('한국어').last);
      await tester.pumpAndSettle();
      final s = containerOf(tester).read(settingsProvider);
      expect(s.uiLanguage, 'ko');
      expect(s.contentLanguage, isNull);
      expect(containerOf(tester).read(uiLanguageProvider), 'ko');
      expect(containerOf(tester).read(contentLanguageProvider), 'en');
      expect(find.text('설정'), findsWidgets);
    });

    testWidgets('最初の画面の言語選択には、5つの言語が並ぶ', (tester) async {
      await _pump(tester);
      for (final name in ['日本語', 'English', '简体中文', '한국어', 'Español']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      await tester.tap(find.text('한국어'));
      await tester.pumpAndSettle();
      expect(find.text('다음'), findsOneWidget); // 画面が韓国語に
      final s = containerOf(tester).read(settingsProvider);
      expect(s.uiLanguage, 'ko');
      expect(s.contentLanguage, isNull);
    });

    testWidgets('国の名前も、画面の言語で出る', (tester) async {
      await _pump(tester, prefs: {'ageBand': 'adult', 'uiLanguage': 'es'});
      expect(regionName('JP', 'es'), 'Japón');
      expect(regionName('KR', 'zh'), '韩国');
      expect(regionName('US', 'ko'), '미국');
      expect(regionName('XX', 'es'), 'XX');
    });
  });
}
