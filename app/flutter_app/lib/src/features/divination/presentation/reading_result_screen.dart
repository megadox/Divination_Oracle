import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/reading.dart';

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

class ReadingDetail {
  const ReadingDetail({
    required this.reading,
    required this.items,
    required this.divinationCode,
    required this.divinationDisplayName,
    required this.payloads,
  });

  final Reading reading;
  final List<ReadingCard> items;
  final String divinationCode;
  final String divinationDisplayName;
  final List<ReadingPayload> payloads;
}

class ReadingPayload {
  const ReadingPayload({
    required this.payloadType,
    required this.payloadJson,
  });

  final String payloadType;
  final Map<String, dynamic> payloadJson;

  factory ReadingPayload.fromJson(Map<String, dynamic> json) {
    return ReadingPayload(
      payloadType: (json['payload_type'] ?? 'unknown') as String,
      payloadJson: json['payload_json'] is Map<String, dynamic>
          ? json['payload_json'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }
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
              Text(
                '점술: ${value.divinationDisplayName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (value.reading.question?.isNotEmpty == true) ...[
                Text('질문: ${value.reading.question}'),
                const SizedBox(height: 8),
              ],
              Text('스프레드: ${value.reading.spreadCode}'),
              Text('분야: ${value.reading.category}'),
              const SizedBox(height: 16),
              if (value.divinationCode == 'saju') ...[
                _SajuResultSections(detail: value),
                const SizedBox(height: 20),
              ] else if (value.divinationCode == 'zodiac') ...[
                _ZodiacResultSections(detail: value),
                const SizedBox(height: 20),
              ] else if (value.divinationCode == 'rune') ...[
                _RuneResultSections(detail: value),
                const SizedBox(height: 20),
              ] else if (value.divinationCode == 'omikuji') ...[
                _OmikujiResultSections(detail: value),
                const SizedBox(height: 20),
              ],
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

class _SajuResultSections extends StatelessWidget {
  const _SajuResultSections({required this.detail});

  final ReadingDetail detail;

  @override
  Widget build(BuildContext context) {
    final sajuPayload = _findSajuPayload(detail.payloads);
    final sourcePayload = detail.reading.resultJson?['source_payload'];
    final payload = sajuPayload ??
        (sourcePayload is Map<String, dynamic>
            ? sourcePayload
            : <String, dynamic>{});

    if (payload.isEmpty) {
      return const SizedBox.shrink();
    }

    final zodiacAnimal = payload['zodiac_animal'] as String?;
    final dominantElement = payload['dominant_element'] as String?;
    final heavenlyElement = payload['heavenly_element'] as String?;
    final season = payload['season'] as String?;
    final yinYang = payload['yin_yang'] as String?;
    final hasBirthTime = payload['has_birth_time'] as bool?;
    final elementCounts = payload['element_counts'] is Map<String, dynamic>
        ? payload['element_counts'] as Map<String, dynamic>
        : <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사주 핵심 보기',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (zodiacAnimal != null)
              _SajuBadge(label: '띠', value: '$zodiacAnimal띠'),
            if (dominantElement != null)
              _SajuBadge(label: '우세 오행', value: _elementLabel(dominantElement)),
            if (heavenlyElement != null)
              _SajuBadge(label: '기본 기운', value: _elementLabel(heavenlyElement)),
            if (season != null)
              _SajuBadge(label: '계절 흐름', value: _seasonLabel(season)),
            if (yinYang != null)
              _SajuBadge(label: '음양', value: yinYang == 'yang' ? '양' : '음'),
          ],
        ),
        const SizedBox(height: 16),
        _ResultInfoCard(
          title: '사주 입력 기준',
          body: hasBirthTime == true
              ? '출생시간까지 포함해 현재 초안 해석을 생성했습니다.'
              : '출생시간 없이 단순화된 기준으로 현재 초안 해석을 생성했습니다.',
        ),
        if (elementCounts.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '오행 분포',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _FiveElementsSection(elementCounts: elementCounts),
        ],
      ],
    );
  }
}

class _ZodiacResultSections extends StatelessWidget {
  const _ZodiacResultSections({required this.detail});

  final ReadingDetail detail;

  @override
  Widget build(BuildContext context) {
    final payload = _findPayload(detail, 'zodiac_profile');
    if (payload.isEmpty) {
      return const SizedBox.shrink();
    }

    final sign = payload['display_name'] as String?;
    final element = payload['element'] as String?;
    final modality = payload['modality'] as String?;
    final trait = payload['trait'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '별자리 핵심 보기',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (sign != null) _SajuBadge(label: '별자리', value: sign),
            if (element != null) _SajuBadge(label: '원소', value: _zodiacElementLabel(element)),
            if (modality != null) _SajuBadge(label: '성향', value: _modalityLabel(modality)),
          ],
        ),
        if (trait != null) ...[
          const SizedBox(height: 16),
          _ResultInfoCard(title: '성향 포인트', body: trait),
        ],
      ],
    );
  }
}

class _RuneResultSections extends StatelessWidget {
  const _RuneResultSections({required this.detail});

  final ReadingDetail detail;

  @override
  Widget build(BuildContext context) {
    final payload = _findPayload(detail, 'rune_cast');
    if (payload.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedRunes = payload['selected_runes'] is List
        ? payload['selected_runes'] as List<dynamic>
        : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '룬 핵심 보기',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final rune in selectedRunes) ...[
          if (rune is Map<String, dynamic>)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rune['role'] ?? '메시지'} · ${rune['name'] ?? 'Rune'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('${rune['keyword'] ?? ''}'),
                    const SizedBox(height: 6),
                    Text('${rune['meaning'] ?? ''}'),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _OmikujiResultSections extends StatelessWidget {
  const _OmikujiResultSections({required this.detail});

  final ReadingDetail detail;

  @override
  Widget build(BuildContext context) {
    final payload = _findPayload(detail, 'omikuji_draw');
    if (payload.isEmpty) {
      return const SizedBox.shrink();
    }

    final fortune = payload['fortune_label'] as String?;
    final focus = payload['focus'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오미쿠지 핵심 보기',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (fortune != null) _SajuBadge(label: '운세', value: fortune),
            if (focus != null) _SajuBadge(label: '집중 영역', value: focus),
          ],
        ),
        const SizedBox(height: 16),
        const _ResultInfoCard(
          title: '읽는 법',
          body: '오미쿠지는 지금의 길흉 분위기를 가볍게 읽는 참고 도구입니다. 좋은 결과든 조심 신호든 오늘의 태도를 다듬는 힌트로 활용해 보세요.',
        ),
      ],
    );
  }
}

Map<String, dynamic>? _findSajuPayload(List<ReadingPayload> payloads) {
  for (final payload in payloads) {
    if (payload.payloadType == 'saju_chart') {
      return payload.payloadJson;
    }
  }
  return null;
}

Map<String, dynamic> _findPayload(ReadingDetail detail, String payloadType) {
  for (final payload in detail.payloads) {
    if (payload.payloadType == payloadType) {
      return payload.payloadJson;
    }
  }
  final sourcePayload = detail.reading.resultJson?['source_payload'];
  if (sourcePayload is Map<String, dynamic>) {
    return sourcePayload;
  }
  return <String, dynamic>{};
}

class _SajuBadge extends StatelessWidget {
  const _SajuBadge({
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

class _FiveElementsSection extends StatelessWidget {
  const _FiveElementsSection({required this.elementCounts});

  final Map<String, dynamic> elementCounts;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('wood', '목(木)'),
      ('fire', '화(火)'),
      ('earth', '토(土)'),
      ('metal', '금(金)'),
      ('water', '수(水)'),
    ];

    return Column(
      children: [
        for (final entry in entries) ...[
          _ElementMeterRow(
            label: entry.$2,
            value: (elementCounts[entry.$1] as num?)?.toInt() ?? 0,
          ),
          if (entry != entries.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ElementMeterRow extends StatelessWidget {
  const _ElementMeterRow({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = (value.clamp(0, 4)) / 4;

    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: theme.textTheme.bodyMedium),
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
            '$value',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}

class _ResultInfoCard extends StatelessWidget {
  const _ResultInfoCard({
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

String _divinationCodeFromRow(Map<String, dynamic> row) {
  final type = row['divination_types'] as Map<String, dynamic>?;
  return (type?['code'] ?? 'tarot') as String;
}

String _divinationNameFromRow(Map<String, dynamic> row) {
  final type = row['divination_types'] as Map<String, dynamic>?;
  return (type?['display_name'] ?? type?['name'] ?? '점술') as String;
}

String _elementLabel(String value) {
  return switch (value) {
    'wood' => '목(木)',
    'fire' => '화(火)',
    'earth' => '토(土)',
    'metal' => '금(金)',
    'water' => '수(水)',
    _ => value,
  };
}

String _seasonLabel(String value) {
  return switch (value) {
    'spring' => '봄',
    'summer' => '여름',
    'autumn' => '가을',
    'winter' => '겨울',
    _ => value,
  };
}

String _zodiacElementLabel(String value) {
  return switch (value) {
    'fire' => '불',
    'earth' => '흙',
    'air' => '바람',
    'water' => '물',
    _ => value,
  };
}

String _modalityLabel(String value) {
  return switch (value) {
    'cardinal' => '시작형',
    'fixed' => '고정형',
    'mutable' => '변화형',
    _ => value,
  };
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
      debugPrint(
        '[TarotImage] code=${card.cardCode} imageRef=$imageRef assetPath=$assetPath',
      );
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: assetPath == null
            ? Image.network(
                imageRef,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    '[TarotImage] network load failed code=${card.cardCode} imageRef=$imageRef error=$error',
                  );
                  return _FallbackTarotCard(card: card);
                },
              )
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    '[TarotImage] asset load failed code=${card.cardCode} assetPath=$assetPath error=$error',
                  );
                  return _FallbackTarotCard(card: card);
                },
              ),
      );
    }
    debugPrint('[TarotImage] missing imageRef code=${card.cardCode}');
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
