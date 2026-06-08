import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/reading.dart';

final readingDetailProvider =
    FutureProvider.family<ReadingDetail, String>((ref, id) async {
  final client = ref.watch(supabaseProvider);
  final row = await client.from('readings').select().eq('id', id).single();
  final itemRows = await client
      .from('reading_items')
      .select(
        'position_name,position_order,orientation,'
        'divination_items(code,name,display_name,image_url)',
      )
      .eq('reading_id', id)
      .order('position_order');
  return ReadingDetail(
    reading: Reading.fromJson(row),
    items: itemRows.map(ReadingCard.fromJson).toList(),
  );
});

class ReadingDetail {
  const ReadingDetail({
    required this.reading,
    required this.items,
  });

  final Reading reading;
  final List<ReadingCard> items;
}

class ReadingCard {
  const ReadingCard({
    required this.positionName,
    required this.orientation,
    required this.cardName,
    required this.cardCode,
    this.imageUrl,
  });

  final String positionName;
  final String orientation;
  final String cardName;
  final String cardCode;
  final String? imageUrl;

  factory ReadingCard.fromJson(Map<String, dynamic> json) {
    final item = json['divination_items'] as Map<String, dynamic>?;
    return ReadingCard(
      positionName: (json['position_name'] ?? '카드') as String,
      orientation: (json['orientation'] ?? 'none') as String,
      cardName: (item?['display_name'] ?? item?['name'] ?? 'Unknown') as String,
      cardCode: (item?['code'] ?? 'unknown') as String,
      imageUrl: item?['image_url'] as String?,
    );
  }
}

class ReadingResultScreen extends ConsumerWidget {
  const ReadingResultScreen({required this.readingId, super.key});

  final String readingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(readingDetailProvider(readingId));

    return Scaffold(
      appBar: AppBar(title: const Text('해석 결과')),
      body: SafeArea(
        child: detail.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                value.reading.resultType == 'plus_ai' ? 'Plus AI 해석' : '무료 해석',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (value.reading.question?.isNotEmpty == true) ...[
                Text('질문: ${value.reading.question}'),
                const SizedBox(height: 8),
              ],
              Text('스프레드: ${value.reading.spreadCode}'),
              Text('분야: ${value.reading.category}'),
              const SizedBox(height: 16),
              if (value.items.isNotEmpty) ...[
                Text(
                  '뽑은 카드',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _ReadingCardGrid(items: value.items),
                const SizedBox(height: 16),
              ],
              Text(value.reading.resultText ?? '저장된 해석이 없습니다.'),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.pop(),
                child: const Text('새 해석하기'),
              ),
            ],
          ),
          error: (error, stackTrace) => Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
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
    'upright' => '정방향',
    'reversed' => '역방향',
    _ => '기본',
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
  final index = code.codeUnits.fold<int>(0, (value, unit) => value + unit) %
      palettes.length;
  return palettes[index];
}
