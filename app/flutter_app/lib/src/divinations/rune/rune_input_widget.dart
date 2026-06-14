import 'package:flutter/material.dart';

import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class RuneInputDefinition extends DivinationInputDefinition {
  const RuneInputDefinition();

  @override
  String get code => 'rune';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: 'Rune Reading',
      contextData: context,
      children: [
        const Text(
          'Draw runes and review the current guidance.',
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
        DropdownButtonFormField<int>(
          initialValue: context.runeDrawCount,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Rune count',
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 rune')),
            DropdownMenuItem(value: 3, child: Text('3 runes')),
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
          label: Text(context.useAi ? 'Generate AI rune reading' : 'Generate free rune reading'),
        ),
      ],
    );
  }
}
