import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class TarotInputDefinition extends DivinationInputDefinition {
  const TarotInputDefinition();

  @override
  String get code => 'tarot';

  @override
  Widget build(DivinationInputContext context) {
    final spreads = context.tarotSpreads;
    return DivinationInputScaffold(
      title: 'Tarot Reading',
      contextData: context,
      children: [
        const Text(
          'Enter your question, choose a spread, and draw the cards.',
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
        const SizedBox(height: 20),
        const Text(
          'Spread',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (spreads != null)
          spreads.when(
            data: (items) {
              if (items.isEmpty) {
                return const Text('No active tarot spreads are available.');
              }

              final selectedSpread = items.any((item) => item.code == context.spreadCode)
                  ? context.spreadCode
                  : items.first.code;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpread,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tarot Spread',
                    ),
                    items: [
                      for (final item in items)
                        DropdownMenuItem(
                          value: item.code,
                          child: Text('${item.name} (${item.cardCount} cards)'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        context.onSpreadChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  for (final item in items)
                    if (item.code == context.spreadCode)
                      Text(item.description ?? ''),
                ],
              );
            },
            error: (error, stackTrace) => Text('Failed to load spreads: $error'),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.style),
          label: Text(context.useAi ? 'Generate AI tarot reading' : 'Generate free tarot reading'),
        ),
        if (context.isFreeLimitReached) ...[
          const SizedBox(height: 12),
          Text(
            'Daily free reading limit reached.',
            style: TextStyle(color: ThemeData().colorScheme.error),
          ),
        ],
      ],
    );
  }
}
