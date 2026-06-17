import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class OmikujiInputDefinition extends DivinationInputDefinition {
  const OmikujiInputDefinition();

  @override
  String get code => 'omikuji';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: context.language == AppLanguage.ko ? '오미쿠지 해석' : 'Omikuji Reading',
      contextData: context,
      children: [
        Text(
          context.language == AppLanguage.ko
              ? '제비를 뽑아 오늘의 메시지와 집중 포인트를 확인하세요.'
              : 'Draw a fortune slip and check the focus of the day.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        CommonReadingSummaryCard(contextData: context),
        const SizedBox(height: 12),
        DailyUsageBanner(
          language: context.language,
          usage: context.usage,
          useAi: context.useAi,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.casino_outlined),
          label: Text(
            context.useAi
                ? (context.language == AppLanguage.ko
                      ? 'AI 오미쿠지 해석 생성'
                      : 'Generate AI omikuji reading')
                : (context.language == AppLanguage.ko
                      ? '무료 오미쿠지 해석 생성'
                      : 'Generate free omikuji reading'),
          ),
        ),
      ],
    );
  }
}
