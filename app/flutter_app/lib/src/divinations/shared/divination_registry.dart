import 'package:flutter/material.dart';

import '../../features/divination/domain/reading_detail.dart';
import 'divination_definition.dart';
import 'reading_result_section.dart';

class DivinationRegistry {
  DivinationRegistry._();

  static final DivinationRegistry instance = DivinationRegistry._();

  final Map<String, DivinationDefinition> _definitions = {
    'tarot': const _TarotDefinition(),
    'saju': const _SajuDefinition(),
    'zodiac': const _ZodiacDefinition(),
    'rune': const _RuneDefinition(),
    'omikuji': const _OmikujiDefinition(),
  };

  DivinationDefinition forCode(String code) {
    return _definitions[code] ?? const _FallbackDefinition();
  }
}

class _FallbackDefinition extends DivinationDefinition {
  const _FallbackDefinition();

  @override
  String get code => 'fallback';

  @override
  DivinationHeroData? buildHero(ReadingDetail detail) => null;

  @override
  List<ReadingResultSection> buildResultSections(ReadingDetail detail) => const [];
}

class _TarotDefinition extends DivinationDefinition {
  const _TarotDefinition();

  @override
  String get code => 'tarot';

  @override
  DivinationHeroData? buildHero(ReadingDetail detail) => null;

  @override
  List<ReadingResultSection> buildResultSections(ReadingDetail detail) => const [];
}

class _SajuDefinition extends DivinationDefinition {
  const _SajuDefinition();

  @override
  String get code => 'saju';

  @override
  DivinationHeroData? buildHero(ReadingDetail detail) {
    final payload = _findPayload(detail, 'saju_chart');
    if (payload.isEmpty) {
      return null;
    }

    final dominantElement = payload['dominant_element'] as String?;
    final zodiacAnimal = payload['zodiac_animal'] as String?;
    final season = payload['season'] as String?;
    final yinYang = payload['yin_yang'] as String?;

    return DivinationHeroData(
      assetPath: 'assets/divinations/saju.png',
      title: zodiacAnimal ?? detail.divinationDisplayName,
      subtitle: dominantElement?.toUpperCase(),
      tags: [
        if (season != null) season.toUpperCase(),
        if (yinYang != null) yinYang.toUpperCase(),
      ],
      accentColor: _sajuAccentColor(dominantElement),
    );
  }

  @override
  List<ReadingResultSection> buildResultSections(ReadingDetail detail) {
    final payload = _findPayload(detail, 'saju_chart');
    if (payload.isEmpty) {
      return const [];
    }

    final sections = <ReadingResultSection>[];
    final badges = <ReadingResultBadge>[
      if (payload['zodiac_animal'] is String)
        ReadingResultBadge(label: 'Zodiac', value: '${payload['zodiac_animal']}'),
      if (payload['dominant_element'] is String)
        ReadingResultBadge(
          label: 'Dominant Element',
          value: _elementLabel(payload['dominant_element'] as String),
        ),
      if (payload['heavenly_element'] is String)
        ReadingResultBadge(
          label: 'Core Element',
          value: _elementLabel(payload['heavenly_element'] as String),
        ),
      if (payload['season'] is String)
        ReadingResultBadge(
          label: 'Season',
          value: _seasonLabel(payload['season'] as String),
        ),
      if (payload['yin_yang'] is String)
        ReadingResultBadge(
          label: 'Yin Yang',
          value: (payload['yin_yang'] as String).toUpperCase(),
        ),
    ];

    if (badges.isNotEmpty) {
      sections.add(ReadingResultSection.badges(
        title: 'Chart Snapshot',
        badges: badges,
      ));
    }

    final hasBirthTime = payload['has_birth_time'] as bool?;
    sections.add(
      ReadingResultSection.text(
        title: 'Input Basis',
        body: hasBirthTime == true
            ? 'Birth time was included in this Saju draft reading.'
            : 'This Saju draft reading was generated without birth time.',
      ),
    );

    final elementCounts = payload['element_counts'] as Map<String, dynamic>?;
    if (elementCounts != null && elementCounts.isNotEmpty) {
      sections.add(
        ReadingResultSection.metrics(
          title: 'Five Elements',
          metrics: [
            ReadingResultMetric(label: 'Wood', value: _metricValue(elementCounts['wood'])),
            ReadingResultMetric(label: 'Fire', value: _metricValue(elementCounts['fire'])),
            ReadingResultMetric(label: 'Earth', value: _metricValue(elementCounts['earth'])),
            ReadingResultMetric(label: 'Metal', value: _metricValue(elementCounts['metal'])),
            ReadingResultMetric(label: 'Water', value: _metricValue(elementCounts['water'])),
          ],
        ),
      );
    }

    return sections;
  }
}

class _ZodiacDefinition extends DivinationDefinition {
  const _ZodiacDefinition();

  @override
  String get code => 'zodiac';

  @override
  DivinationHeroData? buildHero(ReadingDetail detail) {
    final payload = _findPayload(detail, 'zodiac_profile');
    if (payload.isEmpty) {
      return null;
    }

    final element = payload['element'] as String?;
    return DivinationHeroData(
      assetPath: 'assets/divinations/zodiac.png',
      title: (payload['display_name'] as String?) ?? detail.divinationDisplayName,
      subtitle: payload['trait'] as String?,
      tags: [
        if (element != null) element.toUpperCase(),
        if (payload['modality'] is String)
          (payload['modality'] as String).toUpperCase(),
      ],
      accentColor: _zodiacAccentColor(element),
    );
  }

  @override
  List<ReadingResultSection> buildResultSections(ReadingDetail detail) {
    final payload = _findPayload(detail, 'zodiac_profile');
    if (payload.isEmpty) {
      return const [];
    }

    final sections = <ReadingResultSection>[];
    final badges = <ReadingResultBadge>[
      if (payload['display_name'] is String)
        ReadingResultBadge(label: 'Sign', value: payload['display_name'] as String),
      if (payload['element'] is String)
        ReadingResultBadge(
          label: 'Element',
          value: _zodiacElementLabel(payload['element'] as String),
        ),
      if (payload['modality'] is String)
        ReadingResultBadge(
          label: 'Modality',
          value: _modalityLabel(payload['modality'] as String),
        ),
    ];

    if (badges.isNotEmpty) {
      sections.add(ReadingResultSection.badges(
        title: 'Profile',
        badges: badges,
      ));
    }

    final trait = payload['trait'] as String?;
    if (trait != null && trait.isNotEmpty) {
      sections.add(
        ReadingResultSection.text(
          title: 'Core Trait',
          body: trait,
        ),
      );
    }

    return sections;
  }
}

class _RuneDefinition extends DivinationDefinition {
  const _RuneDefinition();

  @override
  String get code => 'rune';

  @override
  DivinationHeroData? buildHero(ReadingDetail detail) {
    final payload = _findPayload(detail, 'rune_cast');
    final selectedRunes = payload['selected_runes'] as List<dynamic>?;
    final firstRune = selectedRunes != null &&
            selectedRunes.isNotEmpty &&
            selectedRunes.first is Map<String, dynamic>
        ? selectedRunes.first as Map<String, dynamic>
        : null;
    if (firstRune == null) {
      return null;
    }

    return DivinationHeroData(
      assetPath: 'assets/divinations/rune.png',
      title: (firstRune['name'] as String?) ?? detail.divinationDisplayName,
      subtitle: firstRune['meaning'] as String?,
      tags: [
        for (final rune in selectedRunes!)
          if (rune is Map<String, dynamic>)
            (rune['keyword'] as String?) ?? (rune['name'] as String?) ?? 'Rune',
      ],
      accentColor: const Color(0xFF5077B4),
    );
  }

  @override
  List<ReadingResultSection> buildResultSections(ReadingDetail detail) {
    final payload = _findPayload(detail, 'rune_cast');
    final selectedRunes = payload['selected_runes'] as List<dynamic>?;
    if (selectedRunes == null || selectedRunes.isEmpty) {
      return const [];
    }

    return [
      ReadingResultSection.list(
        title: 'Rune Cast',
        items: [
          for (final rune in selectedRunes)
            if (rune is Map<String, dynamic>)
              ReadingResultListItem(
                title: '${rune['role'] ?? 'Message'} | ${rune['name'] ?? 'Rune'}',
                subtitle: rune['keyword'] as String?,
                body: rune['meaning'] as String?,
              ),
        ],
      ),
    ];
  }
}

class _OmikujiDefinition extends DivinationDefinition {
  const _OmikujiDefinition();

  @override
  String get code => 'omikuji';

  @override
  DivinationHeroData? buildHero(ReadingDetail detail) {
    final payload = _findPayload(detail, 'omikuji_draw');
    if (payload.isEmpty) {
      return null;
    }

    final fortuneCode = payload['fortune_code'] as String?;
    return DivinationHeroData(
      assetPath: 'assets/divinations/omikuji.png',
      title: (payload['fortune_label'] as String?) ?? detail.divinationDisplayName,
      subtitle: payload['focus'] as String?,
      tags: [
        if (fortuneCode != null) fortuneCode.toUpperCase(),
      ],
      accentColor: _omikujiAccentColor((payload['fortune_label'] as String?) ?? ''),
    );
  }

  @override
  List<ReadingResultSection> buildResultSections(ReadingDetail detail) {
    final payload = _findPayload(detail, 'omikuji_draw');
    if (payload.isEmpty) {
      return const [];
    }

    final badges = <ReadingResultBadge>[
      if (payload['fortune_label'] is String)
        ReadingResultBadge(label: 'Fortune', value: payload['fortune_label'] as String),
      if (payload['focus'] is String)
        ReadingResultBadge(label: 'Focus', value: payload['focus'] as String),
    ];

    return [
      if (badges.isNotEmpty)
        ReadingResultSection.badges(
          title: 'Draw Result',
          badges: badges,
        ),
      const ReadingResultSection.text(
        title: 'Note',
        body:
            'Omikuji is best used as a light directional cue for the day rather than a fixed verdict.',
      ),
    ];
  }
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

int _metricValue(dynamic value) => (value as num?)?.toInt() ?? 0;

String _elementLabel(String value) {
  return switch (value) {
    'wood' => 'Wood',
    'fire' => 'Fire',
    'earth' => 'Earth',
    'metal' => 'Metal',
    'water' => 'Water',
    _ => value,
  };
}

String _seasonLabel(String value) {
  return switch (value) {
    'spring' => 'Spring',
    'summer' => 'Summer',
    'autumn' => 'Autumn',
    'winter' => 'Winter',
    _ => value,
  };
}

String _zodiacElementLabel(String value) {
  return switch (value) {
    'fire' => 'Fire',
    'earth' => 'Earth',
    'air' => 'Air',
    'water' => 'Water',
    _ => value,
  };
}

String _modalityLabel(String value) {
  return switch (value) {
    'cardinal' => 'Cardinal',
    'fixed' => 'Fixed',
    'mutable' => 'Mutable',
    _ => value,
  };
}

Color _sajuAccentColor(String? key) {
  final upper = key?.toUpperCase() ?? '';
  if (upper.contains('WOOD')) return const Color(0xFF2F7D4A);
  if (upper.contains('FIRE')) return const Color(0xFFB7482E);
  if (upper.contains('EARTH')) return const Color(0xFFA06A2A);
  if (upper.contains('METAL')) return const Color(0xFF5B6470);
  if (upper.contains('WATER')) return const Color(0xFF2E5B9A);
  return const Color(0xFF5A6B87);
}

Color _zodiacAccentColor(String? element) {
  switch ((element ?? '').toUpperCase()) {
    case 'FIRE':
      return const Color(0xFFBC5A3C);
    case 'EARTH':
      return const Color(0xFFA07A3B);
    case 'AIR':
      return const Color(0xFF547AA5);
    case 'WATER':
      return const Color(0xFF2B5C88);
    default:
      return const Color(0xFF7A5FB2);
  }
}

Color _omikujiAccentColor(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('daikichi')) return const Color(0xFFB8892F);
  if (lower.contains('kichi')) return const Color(0xFF4F8A4C);
  if (lower.contains('kyo')) return const Color(0xFF8A3F3F);
  return const Color(0xFF8D6A39);
}
