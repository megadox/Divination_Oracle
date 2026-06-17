import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/widgets/page_index_card.dart';
import '../application/divination_providers.dart';
import '../domain/divination_input_definition.dart';
import 'divination_localizations.dart';

class DivinationIntroScreen extends ConsumerWidget {
  const DivinationIntroScreen({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final detail = ref.watch(divinationTypeProvider(code));

    return Scaffold(
      appBar: AppBar(
        title: Text(language == AppLanguage.ko ? '점술 소개' : 'Divination Guide'),
      ),
      body: SafeArea(
        child: detail.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PageIndexCard(
                index: 'p_2',
                label: language == AppLanguage.ko ? '점술 소개' : 'Divination intro',
              ),
              const SizedBox(height: 16),
              Text(
                localizedDivinationDisplayName(value.type, language),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                localizedDivinationDescription(value.type, language),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _IntroInfoRow(
                label: language == AppLanguage.ko ? '입력 방식' : 'Input Mode',
                value: localizedInputModeDescription(
                  value.type.inputMode,
                  language,
                ),
              ),
              if (localizedDivinationOrigin(value.type, language).isNotEmpty)
                _IntroInfoRow(
                  label: language == AppLanguage.ko ? '기원' : 'Origin',
                  value: localizedDivinationOrigin(value.type, language),
                ),
              _IntroInfoRow(
                label: language == AppLanguage.ko ? '해석 방식' : 'Reading Mode',
                value: localizedInterpretationLabel(
                  value.type.interpretationMode,
                  language,
                ),
              ),
              const SizedBox(height: 20),
              _GuidanceCard(
                title: language == AppLanguage.ko ? '진행 방식' : 'How it works',
                body: localizedFlowDescription(code, language),
              ),
              if (value.inputDefinitions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  language == AppLanguage.ko ? '입력 항목' : 'Input Fields',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final input in value.inputDefinitions) ...[
                  _InputDefinitionTile(input: input, language: language),
                  if (input != value.inputDefinitions.last) const Divider(),
                ],
              ],
              if (value.spreads.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  language == AppLanguage.ko
                      ? '사용 가능한 스프레드'
                      : 'Available Spreads',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final spread in value.spreads) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      language == AppLanguage.ko
                          ? '${localizedSpreadName(spread, language)} (${spread.cardCount}장)'
                          : '${localizedSpreadName(spread, language)} (${spread.cardCount} cards)',
                    ),
                    subtitle: Text(localizedSpreadDescription(spread, language)),
                  ),
                  if (spread != value.spreads.last) const Divider(),
                ],
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push('/reading/${value.type.code}'),
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  value.type.code == 'tarot'
                      ? (language == AppLanguage.ko ? '타로 시작하기' : 'Start Tarot')
                      : (language == AppLanguage.ko
                            ? '점술 시작하기'
                            : 'Start Reading'),
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
  const _InputDefinitionTile({
    required this.input,
    required this.language,
  });

  final DivinationInputDefinition input;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      localizedInputFieldType(input, language),
      if (input.isRequired) language == AppLanguage.ko ? '필수' : 'Required',
      if (localizedInputHelpText(input, language).isNotEmpty)
        localizedInputHelpText(input, language),
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(localizedInputFieldLabel(input, language)),
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

