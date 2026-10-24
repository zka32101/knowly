import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/interests_screen.dart';
import 'screens/library_screen.dart';
import 'screens/listen_screen.dart';
import 'screens/myth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/badges_screen.dart';
import 'screens/league_screen.dart';
import 'screens/map_screen.dart';
import 'screens/mascot_screen.dart';
import 'screens/capsule_screen.dart';
import 'screens/hubs.dart';
import 'screens/main_shell.dart';
import 'screens/premium_screen.dart';
import 'screens/recap_screen.dart';
import 'screens/voice_quiz_screen.dart';
import 'screens/word_screen.dart';
import 'screens/words_screen.dart';
import 'screens/stamps_screen.dart';
import 'screens/swipe_quiz_screen.dart';
import 'screens/zukan_screen.dart';
import 'widgets/celebration_layer.dart';
import 'screens/report_screen.dart';
import 'screens/solo_quiz_screens.dart';
import 'screens/quiz_battle_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';
import 'state/clock_sync.dart';
import 'state/notification_sync.dart';
import 'state/settings.dart';
import 'l10n/knowly_localizations.dart';
import 'models/age_band.dart';
import 'theme.dart';
import 'state/widget_sync.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ValueNotifier<bool>(ref.read(settingsProvider).onboarded);
  ref.listen(settingsProvider, (_, s) => onboarded.value = s.onboarded);
  ref.onDispose(onboarded.dispose);

  return GoRouter(
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded.value && !atOnboarding) return '/onboarding';
      if (onboarded.value && atOnboarding) return '/';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/play', builder: (_, _) => const PlayHub()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/collect', builder: (_, _) => const CollectHub()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/explore', builder: (_, _) => const ExploreHub()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/me', builder: (_, _) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/detail/:id',
        builder: (_, state) => DetailScreen(
          triviaId: state.pathParameters['id']!,
          chain: int.tryParse(state.uri.queryParameters['chain'] ?? '') ?? 0,
        ),
      ),
      GoRoute(path: '/projects', builder: (_, _) => const ProjectsScreen()),
      GoRoute(
        path: '/project/:id',
        builder: (_, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/listen', builder: (_, _) => const ListenScreen()),
      GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
      GoRoute(path: '/myths', builder: (_, _) => const MythScreen()),
      GoRoute(
          path: '/library',
          builder: (_, state) =>
              LibraryScreen(autofocus: state.uri.queryParameters['focus'] == '1')),
      GoRoute(path: '/interests', builder: (_, _) => const InterestsScreen()),
      GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/quiz', builder: (_, _) => const QuizBattleScreen()),
      GoRoute(path: '/review', builder: (_, _) => const ReviewScreen()),
      GoRoute(path: '/daily', builder: (_, _) => const DailyChallengeScreen()),
      GoRoute(path: '/badges', builder: (_, _) => const BadgesScreen()),
      GoRoute(path: '/report', builder: (_, _) => const ReportScreen()),
      GoRoute(path: '/mascot', builder: (_, _) => const MascotScreen()),
      GoRoute(path: '/zukan', builder: (_, _) => const ZukanScreen()),
      GoRoute(path: '/capsule', builder: (_, _) => const CapsuleScreen()),
      GoRoute(path: '/swipe', builder: (_, _) => const SwipeQuizScreen()),
      GoRoute(
        path: '/word/:id',
        builder: (_, state) => WordScreen(entryId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/words', builder: (_, _) => const WordsScreen()),
      GoRoute(path: '/wordquiz', builder: (_, _) => const WordQuizScreen()),
      GoRoute(
        path: '/map',
        builder: (_, state) => MapScreen(startId: state.uri.queryParameters['id']),
      ),
      GoRoute(path: '/voicequiz', builder: (_, _) => const VoiceQuizScreen()),
      GoRoute(path: '/league', builder: (_, _) => const LeagueScreen()),
      GoRoute(path: '/recap', builder: (_, _) => const RecapScreen()),
      GoRoute(path: '/stamps', builder: (_, _) => const StampsScreen()),
      GoRoute(path: '/premium', builder: (_, _) => const PremiumScreen()),
    ],
  );
});

class KnowlyApp extends ConsumerWidget {
  const KnowlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(uiLanguageProvider);
    ref.watch(clockSyncProvider);
    ref.watch(notificationSyncProvider);
    ref.watch(widgetSyncProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand));
    final uiStyle = uiStyleFor(band);
    return MaterialApp.router(
      // 子どもモードは文字を大きくする（端末の文字サイズ設定に上乗せ）。
      builder: (context, child) {
        final factor = (band?.textScaleFactor ?? 1.0) *
            textSizeFactors[ref.watch(settingsProvider.select((s) => s.textSize))];
        var app = child!;
        if (factor != 1.0) {
          final media = MediaQuery.of(context);
          final system = media.textScaler.scale(14) / 14;
          app = MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(system * factor)),
            child: app,
          );
        }
        // 相棒の成長・バッジのお祝いを、アプリ全体の上に重ねる。
        return Stack(fit: StackFit.expand, children: [app, const CelebrationLayer()]);
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      routerConfig: ref.watch(routerProvider),
      locale: Locale(lang),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        KnowlyLocalizationsDelegate(uiStyle),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
    );
  }
}

/// モード（年代）→ 日本語の表記。まだ年代を選んでいない（最初の画面）ときは、ふつうの表記。
UiStyle uiStyleFor(AgeBand? band) => switch (band) {
      AgeBand.kids => UiStyle.kids,
      AgeBand.junior => UiStyle.junior,
      AgeBand.teen => UiStyle.teen,
      _ => UiStyle.adult,
    };
