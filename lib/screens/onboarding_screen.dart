import '../state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/age_band.dart';
import '../state/settings.dart';

/// 初回起動: 言語 → 生まれた年（年代モード決定）→ 興味。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  int? _birthYear;
  AgeBand? _band;

  void _finish() {
    // 生まれた年は保存しない。年代だけを保存する。ルーターが自動でホームへ移動する。
    ref.read(settingsProvider.notifier).setAgeBand(_band!);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    Widget body;
    VoidCallback? onNext;
    switch (_step) {
      case 0:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.languageTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            RadioGroup<String?>(
              groupValue: settings.uiLanguage,
              onChanged: (v) {
                notifier.setUiLanguage(v);
                // 雑学の本文は日本語・英語だけ。ほかの言語の画面では、本文は英語（自動）にする。
                notifier.setContentLanguage(
                  contentLanguageCodes.contains(v) ? v : null,
                );
              },
              child: Column(
                children: [
                  RadioListTile<String?>(
                    value: null,
                    title: Text(l.languageSystem),
                  ),
                  RadioListTile<String?>(
                    value: 'ja',
                    title: Text(l.languageJa),
                  ),
                  RadioListTile<String?>(
                    value: 'en',
                    title: Text(l.languageEn),
                  ),
                  RadioListTile<String?>(
                    value: 'zh',
                    title: Text(l.languageZh),
                  ),
                  RadioListTile<String?>(
                    value: 'ko',
                    title: Text(l.languageKo),
                  ),
                  RadioListTile<String?>(
                    value: 'es',
                    title: Text(l.languageEs),
                  ),
                ],
              ),
            ),
          ],
        );
        onNext = () => setState(() => _step = 1);
      case 1:
        final now = DateTime.now().year;
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.birthYearTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(l.birthYearNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            DropdownButton<int>(
              key: const Key('birth_year_dropdown'),
              isExpanded: true,
              hint: Text(l.birthYearHint),
              value: _birthYear,
              items: [
                for (var y = now; y >= now - 100; y--)
                  DropdownMenuItem(value: y, child: Text('$y')),
              ],
              onChanged: (y) => setState(() {
                _birthYear = y;
                _band = y == null ? null : AgeBand.fromBirthYear(y);
              }),
            ),
            const SizedBox(height: 16),
            Text(l.onboardingPickBand, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in AgeBand.values)
                  ChoiceChip(
                    key: Key('band_${b.name}'),
                    label: Text(modeLabel(l, b)),
                    selected: _band == b,
                    onSelected: (_) => setState(() {
                      _birthYear = null;
                      _band = b;
                    }),
                  ),
              ],
            ),
            if (_band != null) ...[
              if (_band!.isChild) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.parentNoteTitle,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(l.parentNoteBody),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        );
        onNext = _band == null ? null : () => setState(() => _step = 2);
      default:
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.interestsTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in ref.watch(categoryIdsProvider))
                  FilterChip(
                    label: Text(categoryLabel(l, c)),
                    selected: settings.interestCategories.contains(c),
                    onSelected: (_) => notifier.toggleInterestCategory(c),
                  ),
              ],
            ),
            if (_band!.isTeenOrAdult) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in allScenes)
                    FilterChip(
                      label: Text(sceneLabel(l, s)),
                      selected: settings.interestScenes.contains(s),
                      onSelected: (_) => notifier.toggleInterestScene(s),
                    ),
                ],
              ),
            ],
          ],
        );
        onNext = _finish;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(child: SingleChildScrollView(child: body)),
              if (_step == 2)
                TextButton(
                  key: const Key('onboarding_skip'),
                  onPressed: _finish,
                  child: Text(l.onboardingSkip),
                ),
              FilledButton(
                key: const Key('onboarding_next'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: onNext,
                child: Text(l.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
