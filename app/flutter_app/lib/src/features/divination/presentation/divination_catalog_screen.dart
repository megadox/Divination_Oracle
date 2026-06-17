import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/widgets/page_index_card.dart';
import '../application/divination_providers.dart';
import '../domain/divination_type.dart';
import 'divination_localizations.dart';

class DivinationCatalogScreen extends ConsumerWidget {
  const DivinationCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(language == AppLanguage.ko ? '점술 선택' : 'Choose a Divination'),
      ),
      body: SafeArea(
        child: types.when(
          data: (items) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PageIndexCard(
                index: 'p_1',
                label: language == AppLanguage.ko ? '점술 카탈로그' : 'Divination catalog',
              ),
              const SizedBox(height: 16),
              Text(
                language == AppLanguage.ko
                    ? '원하는 점술을 선택해 보세요.'
                    : 'Choose the reading you want.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                language == AppLanguage.ko
                    ? '카드형 점술과 생년월일 기반 점술을 한 흐름 안에서 선택할 수 있도록 구성합니다.'
                    : 'Browse draw-based and birth-data readings in one consistent flow.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              for (final type in items) ...[
                _CatalogTile(type: type, language: language),
                if (type != items.last) const SizedBox(height: 12),
              ],
            ],
          ),
          error: (error, stackTrace) => Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.type,
    required this.language,
  });

  final DivinationType type;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(_iconFor(type.code)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizedDivinationDisplayName(type, language),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(localizedDivinationSummary(type, language)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/reading/${type.code}'),
                    child: Text(
                      language == AppLanguage.ko ? '바로 시작' : 'Start',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.push('/catalog/${type.code}'),
                  child: Text(
                    language == AppLanguage.ko ? '소개 보기' : 'View intro',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(String code) {
  return switch (code) {
    'tarot' => Icons.style,
    'saju' => Icons.calendar_month,
    'rune' => Icons.circle_outlined,
    'omikuji' => Icons.receipt_long,
    'zodiac' => Icons.stars,
    _ => Icons.auto_awesome,
  };
}
