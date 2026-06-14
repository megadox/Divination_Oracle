import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../divinations/shared/divination_definition.dart';
import '../../../divinations/shared/reading_result_mapper.dart';
import '../../../divinations/shared/reading_result_section.dart';
import '../domain/reading.dart';
import '../domain/reading_detail.dart';

final readingDetailProvider =
    FutureProvider.family<ReadingDetail, String>((ref, id) async {
  final client = ref.watch(supabaseProvider);
  final row = await client
      .from('readings')
      .select('*, divination_types(code,display_name,name)')
      .eq('id', id)
      .single();
  final itemRows = await client
      .from('reading_items')
      .select(
        'position_name,position_order,orientation,'
        'divination_items(code,name,display_name,image_url)',
      )
      .eq('reading_id', id)
      .order('position_order');
  final payloadRows = await client
      .from('reading_payloads')
      .select('payload_type,payload_json')
      .eq('reading_id', id);
  return ReadingDetail(
    reading: Reading.fromJson(row),
    items: itemRows.map(ReadingCard.fromJson).toList(),
    divinationCode: _divinationCodeFromRow(row),
    divinationDisplayName: _divinationNameFromRow(row),
    payloads: payloadRows.map(ReadingPayload.fromJson).toList(),
  );
});

class ReadingResultScreen extends ConsumerWidget {
  const ReadingResultScreen({required this.readingId, super.key});

  final String readingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(readingDetailProvider(readingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Result')),
      body: SafeArea(
        child: detail.when(
          data: (value) {
            final model = mapReadingResult(value);
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  model.displayModeLabel,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Divination: ${value.divinationDisplayName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (value.reading.question?.isNotEmpty == true) ...[
                  Text('Question: ${value.reading.question}'),
                  const SizedBox(height: 8),
                ],
                Text('Spread: ${value.reading.spreadCode}'),
                Text('Category: ${value.reading.category}'),
                if (model.hero != null) ...[
                  const SizedBox(height: 20),
                  _DivinationHero(hero: model.hero!),
                ],
                if (model.sections.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  for (final section in model.sections) ...[
                    _ResultSectionCard(section: section),
                    const SizedBox(height: 16),
                  ],
                ],
                if (value.items.isNotEmpty) ...[
                  Text(
                    'Source Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _ReadingCardGrid(items: value.items),
                  const SizedBox(height: 20),
                ],
                if (model.summary != null)
                  _ResultTextCard(title: 'Summary', body: model.summary!),
                if (model.summary != null) const SizedBox(height: 16),
                if (model.detailedReading != null)
                  _ResultTextCard(
                    title: 'Interpretation',
                    body: model.detailedReading!,
                  ),
                if (model.detailedReading != null) const SizedBox(height: 16),
                if (model.advice != null)
                  _ResultTextCard(title: 'Advice', body: model.advice!),
                if (model.advice != null) const SizedBox(height: 16),
                if (model.caution != null)
                  _ResultTextCard(title: 'Caution', body: model.caution!),
                if (model.caution != null) const SizedBox(height: 16),
                if (model.fallbackText != null)
                  _ResultTextCard(title: 'Full Reading', body: model.fallbackText!),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Go Home'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => context.pop(),
                  child: const Text('Back'),
                ),
              ],
            );
          },
          error: (error, stackTrace) => Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _DivinationHero extends StatelessWidget {
  const _DivinationHero({required this.hero});

  final DivinationHeroData hero;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              hero.assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.76),
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroPill(label: 'Featured', color: hero.accentColor),
                  const Spacer(),
                  Text(
                    hero.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (hero.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      hero.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ],
                  if (hero.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in hero.tags)
                          _HeroPill(
                            label: tag,
                            color: hero.accentColor.withValues(alpha: 0.92),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _ResultSectionCard extends StatelessWidget {
  const _ResultSectionCard({required this.section});

  final ReadingResultSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            switch (section.type) {
              ReadingResultSectionType.text => Text(section.body ?? ''),
              ReadingResultSectionType.badges => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final badge in section.badges)
                      _ResultBadge(label: badge.label, value: badge.value),
                  ],
                ),
              ReadingResultSectionType.metrics => Column(
                  children: [
                    for (final metric in section.metrics) ...[
                      _MetricRow(metric: metric),
                      if (metric != section.metrics.last) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ReadingResultSectionType.list => Column(
                  children: [
                    for (final item in section.items) ...[
                      _ResultListItemCard(item: item),
                      if (item != section.items.last) const SizedBox(height: 12),
                    ],
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _ResultTextCard extends StatelessWidget {
  const _ResultTextCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final ReadingResultMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = metric.maxValue <= 0 ? 1 : metric.maxValue;
    final normalized = (metric.value.clamp(0, maxValue)) / maxValue;

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(metric.label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: normalized == 0 ? 0.06 : normalized,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 24,
          child: Text(
            '${metric.value}',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

class _ResultListItemCard extends StatelessWidget {
  const _ResultListItemCard({required this.item});

  final ReadingResultListItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: item.color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleSmall),
            if (item.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(item.subtitle!, style: Theme.of(context).textTheme.labelLarge),
            ],
            if (item.body != null) ...[
              const SizedBox(height: 6),
              Text(item.body!),
            ],
          ],
        ),
      ),
    );
  }
}

String _divinationCodeFromRow(Map<String, dynamic> row) {
  final type = row['divination_types'] as Map<String, dynamic>?;
  return (type?['code'] ?? 'tarot') as String;
}

String _divinationNameFromRow(Map<String, dynamic> row) {
  final type = row['divination_types'] as Map<String, dynamic>?;
  return (type?['display_name'] ?? type?['name'] ?? 'Divination') as String;
}

class _ReadingCardGrid extends StatelessWidget {
  const _ReadingCardGrid({required this.items});

  final List<ReadingCard> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            return _TarotCardTile(card: items[index]);
          },
        );
      },
    );
  }
}

class _TarotCardTile extends StatelessWidget {
  const _TarotCardTile({required this.card});

  final ReadingCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _TarotCardImage(card: card),
        ),
        const SizedBox(height: 6),
        Text(
          card.positionName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge,
        ),
        Text(
          '${card.cardName} / ${_orientationLabel(card.orientation)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TarotCardImage extends StatelessWidget {
  const _TarotCardImage({required this.card});

  final ReadingCard card;

  @override
  Widget build(BuildContext context) {
    final imageRef = card.imageUrl;
    if (imageRef != null && imageRef.isNotEmpty) {
      final assetPath = _localAssetPath(imageRef);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: assetPath == null
            ? Image.network(
                imageRef,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackTarotCard(card: card);
                },
              )
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackTarotCard(card: card);
                },
              ),
      );
    }

    return _FallbackTarotCard(card: card);
  }
}

String? _localAssetPath(String imageRef) {
  if (imageRef.startsWith('asset://')) {
    return 'assets/${imageRef.substring('asset://'.length)}';
  }
  if (imageRef.startsWith('assets/')) {
    return imageRef;
  }
  return null;
}

class _FallbackTarotCard extends StatelessWidget {
  const _FallbackTarotCard({required this.card});

  final ReadingCard card;

  @override
  Widget build(BuildContext context) {
    final colors = _cardColors(card.cardCode);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.$2, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              _orientationSymbol(card.orientation),
              style: TextStyle(
                color: colors.$2,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.auto_awesome,
              color: colors.$2,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              card.cardName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.$2,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              card.cardCode.replaceAll('_', ' ').toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.$2.withValues(alpha: 0.78),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _orientationLabel(String orientation) {
  return switch (orientation) {
    'upright' => 'Upright',
    'reversed' => 'Reversed',
    _ => 'Default',
  };
}

String _orientationSymbol(String orientation) {
  return switch (orientation) {
    'upright' => 'UP',
    'reversed' => 'REV',
    _ => 'CARD',
  };
}

(Color, Color) _cardColors(String code) {
  final palettes = <(Color, Color)>[
    (const Color(0xFFF7EFE1), const Color(0xFF24473B)),
    (const Color(0xFFE8F1EC), const Color(0xFF6B3F2A)),
    (const Color(0xFFF3E8EA), const Color(0xFF3C4D77)),
    (const Color(0xFFECE8D8), const Color(0xFF5A4222)),
    (const Color(0xFFE7EEF2), const Color(0xFF8A3B3B)),
  ];
  final index =
      code.codeUnits.fold<int>(0, (value, unit) => value + unit) % palettes.length;
  return palettes[index];
}
