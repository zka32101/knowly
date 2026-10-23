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
                notifier.setContentLanguage(v);
              },
              child: Column(
                children: [
                  RadioListTile<String?>(value: null, title: Text(l.languageSystem)),
                  RadioListTile<String?>(value: 'ja', title: Text(l.languageJa)),
                  RadioListTile<String?>(value: 'en', title: Text(l.languageEn)),
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
            if (_band != null) ...[
              const SizedBox(height: 16),
              Text(modeLabel(l, _band!), style: theme.textTheme.titleMedium),
              if (_band!.isChild) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.parentNoteTitle, style: theme.textTheme.titleSmall),
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
                for (final c in allCategories)
                  FilterChip(
                    label: Text(categoryLabel(l, c)),
                    selected: settings.categories.contains(c),
                    onSelected: (_) => notifier.toggleCategory(c),
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
                      selected: settings.scenes.contains(s),
                      onSelected: (_) => notifier.toggleScene(s),
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
              FilledButton(
                key: const Key('onboarding_next'),
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
