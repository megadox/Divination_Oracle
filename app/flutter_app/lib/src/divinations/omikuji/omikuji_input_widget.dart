import 'package:flutter/material.dart';

import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class OmikujiInputDefinition extends DivinationInputDefinition {
  const OmikujiInputDefinition();

  @override
  String get code => 'omikuji';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: 'Omikuji Reading',
      contextData: context,
      children: [
        const Text(
          'Draw a fortune slip and check the focus of the day.',
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
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.casino_outlined),
          label: Text(context.useAi ? 'Generate AI omikuji reading' : 'Generate free omikuji reading'),
        ),
      ],
    );
  }
}
