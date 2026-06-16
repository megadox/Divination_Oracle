import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/divination_providers.dart';
import '../domain/divination_input_definition.dart';

class DivinationIntroScreen extends ConsumerWidget {
  const DivinationIntroScreen({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(divinationTypeProvider(code));

    return Scaffold(
      appBar: AppBar(title: const Text('Divination Guide')),
      body: SafeArea(
        child: detail.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                value.type.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                value.type.description ??
                    value.type.shortDescription ??
                    'Description is being prepared.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _IntroInfoRow(
                label: 'Input Mode',
                value: _inputModeLabel(value.type.inputMode),
              ),
              if (value.type.originRegion?.isNotEmpty == true)
                _IntroInfoRow(label: 'Origin', value: value.type.originRegion!),
              _IntroInfoRow(
                label: 'Reading Mode',
                value: _interpretationLabel(value.type.interpretationMode),
              ),
              const SizedBox(height: 20),
              _GuidanceCard(
                title: 'How it works',
                body: _flowDescription(code),
              ),
              if (value.inputDefinitions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Input Fields',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final input in value.inputDefinitions) ...[
                  _InputDefinitionTile(input: input),
                  if (input != value.inputDefinitions.last) const Divider(),
                ],
              ],
              if (value.spreads.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Available Spreads',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final spread in value.spreads) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${spread.name} (${spread.cardCount} cards)'),
                    subtitle: Text(spread.description ?? ''),
                  ),
                  if (spread != value.spreads.last) const Divider(),
                ],
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push('/reading/${value.type.code}/question'),
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  value.type.code == 'tarot' ? 'Start Tarot' : 'Start Reading',
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _InputDefinitionTile extends StatelessWidget {
  const _InputDefinitionTile({required this.input});

  final DivinationInputDefinition input;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      input.fieldType,
      if (input.isRequired) 'required',
      if ((input.helpText ?? '').isNotEmpty) input.helpText!,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(input.fieldLabel),
      subtitle: Text(metadata.join(' | ')),
    );
  }
}

class _IntroInfoRow extends StatelessWidget {
  const _IntroInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}

String _inputModeLabel(String inputMode) {
  return switch (inputMode) {
    'draw_based' => 'Draw items first, then interpret the result.',
    'birth_data_based' => 'Calculate from birth date and time input.',
    'hybrid' => 'Combine user input with built-in rules.',
    _ => 'Configuration is being prepared.',
  };
}

String _interpretationLabel(String interpretationMode) {
  return switch (interpretationMode) {
    'lookup_plus_ai' => 'Static reading with optional Plus AI expansion',
    'rule_plus_ai' => 'Rule-based reading with optional Plus AI expansion',
    'rule_based' => 'Rule-based free reading',
    'prewritten_lookup' => 'Prewritten reading lookup',
    _ => 'Configuration is being prepared.',
  };
}

String _flowDescription(String code) {
  return switch (code) {
    'tarot' => 'Enter a question, choose a spread, draw cards, and review the reading.',
    'saju' => 'Enter birth data, calculate the chart, and review the free or AI reading.',
    'zodiac' => 'Enter birth date, resolve the sign, and review the personality summary.',
    'rune' => 'Draw one or more runes and review the guidance for the current situation.',
    'omikuji' => 'Draw a fortune slip and review the grade and focus areas.',
    _ => 'Each divination follows the same overall input and result flow.',
  };
}
