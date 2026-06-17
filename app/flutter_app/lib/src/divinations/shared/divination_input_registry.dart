import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_language.dart';
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
    final language = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(appLanguageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(code),
        actions: [
          IconButton(
            tooltip: language == AppLanguage.ko ? '홈' : 'Home',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              language == AppLanguage.ko
                  ? '이 점술의 입력 화면은 아직 준비되지 않았습니다.'
                  : 'This divination input screen is not available yet.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
