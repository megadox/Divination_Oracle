import 'package:flutter/material.dart';

import '../omikuji/omikuji_input_widget.dart';
import '../rune/rune_input_widget.dart';
import '../saju/saju_input_widget.dart';
import '../tarot/tarot_input_widget.dart';
import '../zodiac/zodiac_input_widget.dart';
import 'divination_input_definition.dart';

class DivinationInputRegistry {
  DivinationInputRegistry._();

  static final DivinationInputRegistry instance = DivinationInputRegistry._();

  final Map<String, DivinationInputDefinition> _definitions = {
    'tarot': const TarotInputDefinition(),
    'saju': const SajuInputDefinition(),
    'zodiac': const ZodiacInputDefinition(),
    'rune': const RuneInputDefinition(),
    'omikuji': const OmikujiInputDefinition(),
  };

  DivinationInputDefinition? find(String code) => _definitions[code];
}

class UnsupportedDivinationInput extends StatelessWidget {
  const UnsupportedDivinationInput({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(code)),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This divination input screen is not available yet.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
