import 'package:flutter/material.dart';

import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class ZodiacInputDefinition extends DivinationInputDefinition {
  const ZodiacInputDefinition();

  @override
  String get code => 'zodiac';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: 'Zodiac Reading',
      contextData: context,
      children: [
        const Text(
          'Use birth date to resolve the zodiac sign and reading.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        CommonReadingSummaryCard(
          question: context.question,
          category: context.category,
          useAi: context.useAi,
          onEdit: context.onEditSetup,
        ),
        const SizedBox(height: 12),
        DailyUsageBanner(usage: context.usage, useAi: context.useAi),
        const SizedBox(height: 16),
        TextField(
          controller: context.zodiacNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name or nickname',
            hintText: 'Optional',
          ),
        ),
        const SizedBox(height: 12),
        DatePickerField(
          label: 'Birth date',
          value: context.zodiacBirthDate == null
              ? null
              : context.formatDate(context.zodiacBirthDate!),
          onTap: context.onPickZodiacBirthDate,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.stars_outlined),
          label: Text(context.useAi ? 'Generate AI zodiac reading' : 'Generate free zodiac reading'),
        ),
        if (context.zodiacBirthDate == null) ...[
          const SizedBox(height: 12),
          const Text('Birth date is required.'),
        ],
      ],
    );
  }
}
