import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/divination_providers.dart';
import '../domain/divination_type.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('점술'),
        actions: [
          IconButton(
            tooltip: '기록',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: '플러스',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroPanel(
              onBrowseCatalog: () => context.push('/catalog'),
              onStartTarot: () => context.push('/reading/tarot/question'),
            ),
            const SizedBox(height: 24),
            Text(
              'Featured Divinations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            types.when(
              data: (items) => _FeaturedDivinations(types: items.take(3).toList()),
              error: (error, stackTrace) => _InfoCard(
                title: 'Failed to load divinations',
                body: '$error',
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 24),
            const _InfoCard(
              title: 'Reading Flow',
              body:
                  'Choose a divination, enter your question, review the free reading first, and expand to Plus AI when you want a deeper personalized interpretation.',
            ),
            const SizedBox(height: 16),
            const _InfoCard(
              title: 'Settings',
              body:
                  'Open Settings to review version, build mode, and runtime configuration before testing.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.onBrowseCatalog,
    required this.onStartTarot,
  });

  final VoidCallback onBrowseCatalog;
  final VoidCallback onStartTarot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What kind of reading do you want today?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Tarot, Saju, Rune, Omikuji, and Zodiac now follow the same reading flow so each type can expand cleanly from the same app structure.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onBrowseCatalog,
                  icon: const Icon(Icons.explore),
                  label: const Text('Browse Divinations'),
                ),
                OutlinedButton.icon(
                  onPressed: onStartTarot,
                  icon: const Icon(Icons.style),
                  label: const Text('Start Tarot'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedDivinations extends StatelessWidget {
  const _FeaturedDivinations({required this.types});

  final List<DivinationType> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const _InfoCard(
        title: 'No divinations available',
        body: 'Active divinations will appear here once they are configured.',
      );
    }

    return Column(
      children: [
        for (final type in types) ...[
          _DivinationPreviewCard(type: type),
          if (type != types.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DivinationPreviewCard extends StatelessWidget {
  const _DivinationPreviewCard({required this.type});

  final DivinationType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/catalog/${type.code}'),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                _typeIcon(type),
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.displayName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    type.shortDescription ??
                        type.description ??
                        'Description is being prepared.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(label: _inputModeLabel(type.inputMode)),
                      if (type.isPlusOnly) const _Pill(label: 'Plus only'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(DivinationType type) {
  return switch (type.code) {
    'tarot' => Icons.style,
    'saju' => Icons.calendar_month,
    'rune' => Icons.circle_outlined,
    'omikuji' => Icons.receipt_long,
    'zodiac' => Icons.stars,
    _ => Icons.auto_awesome,
  };
}

String _inputModeLabel(String inputMode) {
  return switch (inputMode) {
    'draw_based' => 'draw-based',
    'birth_data_based' => 'birth-data',
    'hybrid' => 'hybrid',
    _ => 'other',
  };
}
