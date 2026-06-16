import '../../features/divination/domain/reading_detail.dart';
import 'divination_definition.dart';
import 'divination_registry.dart';
import 'reading_result_section.dart';

class ReadingResultModel {
  const ReadingResultModel({
    required this.detail,
    required this.definition,
    required this.displayModeLabel,
    required this.sections,
    this.hero,
    this.summary,
    this.detailedReading,
    this.advice,
    this.caution,
    this.fallbackText,
  });

  final ReadingDetail detail;
  final DivinationDefinition definition;
  final String displayModeLabel;
  final DivinationHeroData? hero;
  final List<ReadingResultSection> sections;
  final String? summary;
  final String? detailedReading;
  final String? advice;
  final String? caution;
  final String? fallbackText;
}

ReadingResultModel mapReadingResult(ReadingDetail detail) {
  final definition = DivinationRegistry.instance.forCode(detail.divinationCode);
  final resultJson = detail.reading.resultJson ?? const <String, dynamic>{};
  final summary = _asString(resultJson['summary']);
  final detailedReading = _asString(resultJson['detailed_reading']);
  final advice = _asString(resultJson['advice']);
  final caution = _asString(resultJson['caution']);
  final fallbackText = (summary == null && detailedReading == null)
      ? detail.reading.resultText
      : null;

  return ReadingResultModel(
    detail: detail,
    definition: definition,
    displayModeLabel:
        detail.reading.resultType == 'plus_ai' ? 'Plus AI Reading' : 'Free Reading',
    hero: definition.buildHero(detail),
    sections: definition.buildResultSections(detail),
    summary: summary,
    detailedReading: detailedReading,
    advice: advice,
    caution: caution,
    fallbackText: fallbackText,
  );
}

String? _asString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}
