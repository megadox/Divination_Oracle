import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class ZodiacInputDefinition extends DivinationInputDefinition {
  const ZodiacInputDefinition();

  @override
  String get code => 'zodiac';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: context.language == AppLanguage.ko ? '별자리 해석' : 'Zodiac Reading',
      contextData: context,
      children: [
        Text(
          context.language == AppLanguage.ko
              ? '생년월일을 바탕으로 별자리와 해석을 계산합니다.'
              : 'Use birth date to resolve the zodiac sign and reading.',
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
        const SizedBox(height: 16),
        TextField(
          controller: context.zodiacNameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.language == AppLanguage.ko
                ? '이름 또는 별칭'
                : 'Name or nickname',
            hintText: context.language == AppLanguage.ko ? '선택 입력' : 'Optional',
          ),
        ),
        const SizedBox(height: 12),
        DatePickerField(
          label: context.language == AppLanguage.ko ? '생년월일' : 'Birth date',
          value: context.zodiacBirthDate == null
              ? null
              : context.formatDate(context.zodiacBirthDate!),
          onTap: context.onPickZodiacBirthDate,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.stars_outlined),
          label: Text(
            context.useAi
                ? (context.language == AppLanguage.ko
                      ? 'AI 별자리 해석 생성'
                      : 'Generate AI zodiac reading')
                : (context.language == AppLanguage.ko
                      ? '무료 별자리 해석 생성'
                      : 'Generate free zodiac reading'),
          ),
        ),
        if (context.zodiacBirthDate == null) ...[
          const SizedBox(height: 12),
          Text(
            context.language == AppLanguage.ko
                ? '생년월일은 필수입니다.'
                : 'Birth date is required.',
          ),
        ],
      ],
    );
  }
}
