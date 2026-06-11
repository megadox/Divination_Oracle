import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/divination_providers.dart';
import '../domain/divination_type.dart';

class DivinationCatalogScreen extends ConsumerWidget {
  const DivinationCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('점술 선택')),
      body: SafeArea(
        child: types.when(
          data: (items) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '원하는 점술을 선택해 보세요.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '카드형 점술과 생년월일 기반 점술을 한 흐름 안에서 선택할 수 있도록 구성합니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              for (final type in items) ...[
                _CatalogTile(type: type),
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
  const _CatalogTile({required this.type});

  final DivinationType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(_iconFor(type.code)),
        ),
        title: Text(type.displayName),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            type.shortDescription ?? type.description ?? '설명이 준비 중입니다.',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/catalog/${type.code}'),
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
