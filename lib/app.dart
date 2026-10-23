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
import 'screens/premium_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/today_screen.dart';
import 'state/notification_sync.dart';
import 'state/settings.dart';

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
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
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
      GoRoute(path: '/library', builder: (_, _) => const LibraryScreen()),
      GoRoute(path: '/interests', builder: (_, _) => const InterestsScreen()),
      GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/premium', builder: (_, _) => const PremiumScreen()),
    ],
  );
});

class KnowlyApp extends ConsumerWidget {
  const KnowlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(uiLanguageProvider);
    ref.watch(notificationSyncProvider);
    final band = ref.watch(settingsProvider.select((s) => s.ageBand));
    return MaterialApp.router(
      // 子どもモードは文字を大きくする（端末の文字サイズ設定に上乗せ）。
      builder: (context, child) {
        final factor = band?.textScaleFactor ?? 1.0;
        if (factor == 1.0) return child!;
        final media = MediaQuery.of(context);
        final system = media.textScaler.scale(14) / 14;
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(system * factor)),
          child: child!,
        );
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      routerConfig: ref.watch(routerProvider),
      locale: Locale(lang),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D6B),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D6B),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}
