import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/trivia_repository.dart';
import '../l10n/app_localizations.dart';
import '../models/age_band.dart';
import '../models/project.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../widgets/illustration.dart';

ProjectText? _textOf(WidgetRef ref, Project p) {
  final band = ref.watch(settingsProvider.select((s) => s.ageBand)) ?? AgeBand.adult;
  return p.textFor(band, ref.watch(contentLanguageProvider), allowDraft: kAllowDraftContent);
}

String _stars(int n) => '★' * n + '☆' * (3 - n);

/// 自由研究ネタ帳: 雑学から、家でできる実験・観察へ。
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final projects = ref.watch(projectsProvider);
    final repo = ref.watch(triviaRepositoryProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.projectsTitle)),
      body: projects.isEmpty
          ? Center(child: Text(l.projectsEmpty))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.projectsIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                for (final p in projects)
                  if (_textOf(ref, p) case final text?)
                    Card(
                      key: Key('project_${p.id}'),
                      child: ListTile(
                        leading: TriviaIllustration(
                            id: repo.byId(p.factId)?.illustration ?? '', size: 32),
                        title: Text(text.title),
                        subtitle: Text(
                          '${_stars(p.difficulty)}  ${l.projectMinutes(p.minutes)}'
                          '${p.needsAdult ? '  ・${l.projectNeedsAdult}' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/project/${p.id}'),
                      ),
                    ),
              ],
            ),
    );
  }
}

/// 自由研究の1テーマ: 材料・やりかた・観察のポイント・安全上の注意。
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final project = ref.watch(projectsProvider).where((p) => p.id == projectId).firstOrNull;
    final text = project == null ? null : _textOf(ref, project);
    if (project == null || text == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.projectsEmpty)));
    }
    final repo = ref.watch(triviaRepositoryProvider);
    final fact = repo.byId(project.factId);

    Widget header(String t) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(t, style: theme.textTheme.titleMedium),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.projectsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (fact != null)
              Center(child: TriviaIllustration(id: fact.illustration, size: 72)),
            const SizedBox(height: 8),
            Text(text.title,
                key: const Key('project_title'), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              Chip(label: Text('${l.projectDifficulty} ${_stars(project.difficulty)}')),
              Chip(label: Text(l.projectMinutes(project.minutes))),
              if (project.needsAdult)
                Chip(
                  key: const Key('project_adult_badge'),
                  avatar: const Icon(Icons.family_restroom, size: 18),
                  label: Text(l.projectNeedsAdult),
                ),
            ]),
            const SizedBox(height: 8),
            Text(text.summary, style: theme.textTheme.bodyLarge),
            // 安全上の注意は最初に見せる。
            Card(
              key: const Key('project_safety'),
              color: theme.colorScheme.errorContainer,
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.health_and_safety_outlined,
                          color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Text(l.projectSafety,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: theme.colorScheme.onErrorContainer)),
                    ]),
                    const SizedBox(height: 6),
                    Text(text.safety,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                  ],
                ),
              ),
            ),
            header(l.projectMaterials),
            for (final m in text.materials)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('・$m'),
              ),
            header(l.projectSteps),
            for (var i = 0; i < text.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, child: Text('${i + 1}', style: const TextStyle(fontSize: 12))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(text.steps[i], key: Key('project_step_$i'))),
                  ],
                ),
              ),
            header(l.projectObserve),
            Text(text.observe, key: const Key('project_observe')),
            if (fact != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                key: const Key('project_read_fact'),
                onPressed: () => context.push('/detail/${fact.id}'),
                child: Text(l.mythRead),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
