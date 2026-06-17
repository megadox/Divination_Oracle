import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class RuneInputDefinition extends DivinationInputDefinition {
  const RuneInputDefinition();

  @override
  String get code => 'rune';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: context.language == AppLanguage.ko ? '룬 해석' : 'Rune Reading',
      contextData: context,
      children: [
        Text(
          context.language == AppLanguage.ko
              ? '룬을 뽑고 현재 흐름에 대한 조언을 확인하세요.'
              : 'Draw runes and review the current guidance.',
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
        DropdownButtonFormField<int>(
          initialValue: context.runeDrawCount,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.language == AppLanguage.ko ? '룬 개수' : 'Rune count',
          ),
          items: [
            DropdownMenuItem(
              value: 1,
              child: Text(context.language == AppLanguage.ko ? '1개' : '1 rune'),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(context.language == AppLanguage.ko ? '3개' : '3 runes'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              context.onRuneDrawCountChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.circle_outlined),
          label: Text(
            context.useAi
                ? (context.language == AppLanguage.ko
                      ? 'AI 룬 해석 생성'
                      : 'Generate AI rune reading')
                : (context.language == AppLanguage.ko
                      ? '무료 룬 해석 생성'
                      : 'Generate free rune reading'),
          ),
        ),
      ],
    );
  }
}
