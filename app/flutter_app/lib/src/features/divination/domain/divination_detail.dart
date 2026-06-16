import 'divination_input_definition.dart';
import 'divination_type.dart';
import 'tarot_spread.dart';

class DivinationDetail {
  const DivinationDetail({
    required this.type,
    required this.inputDefinitions,
    required this.spreads,
  });

  final DivinationType type;
  final List<DivinationInputDefinition> inputDefinitions;
  final List<TarotSpread> spreads;

  factory DivinationDetail.fromJson(Map<String, dynamic> json) {
    final inputRows = json['input_definitions'] as List<dynamic>? ?? const [];
    final spreadRows = json['spreads'] as List<dynamic>? ?? const [];

    return DivinationDetail(
      type: DivinationType.fromJson(json),
      inputDefinitions: inputRows
          .whereType<Map<String, dynamic>>()
          .map(DivinationInputDefinition.fromJson)
          .toList(),
      spreads: spreadRows
          .whereType<Map<String, dynamic>>()
          .map(TarotSpread.fromJson)
          .toList(),
    );
  }
}
