import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/divination_providers.dart';
import '../domain/divination_type.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('점술'),
        actions: [
          IconButton(
            tooltip: '기록',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: '플러스',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _HeroPanel(
              onBrowseCatalog: () => context.push('/catalog'),
              onStartTarot: () => context.push('/reading/tarot'),
            ),
            const SizedBox(height: 24),
            Text(
              '추천 점술',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            types.when(
              data: (items) => _FeaturedDivinations(types: items.take(3).toList()),
              error: (error, stackTrace) => _InfoCard(
                title: '점술 목록을 불러오지 못했습니다.',
                body: '$error',
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 24),
            const _InfoCard(
              title: '이용 흐름',
              body: '점술을 선택하고 질문을 입력한 뒤, 무료 해석을 먼저 보고 Plus에서 AI 개인화 해석을 확장할 수 있습니다.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.onBrowseCatalog,
    required this.onStartTarot,
  });

  final VoidCallback onBrowseCatalog;
  final VoidCallback onStartTarot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘은 어떤 점술로 흐름을 볼까요?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '타로에서 시작하고, 앞으로 사주·룬·오미쿠지·별자리까지 같은 흐름으로 선택해 진행할 수 있도록 구조를 넓히고 있습니다.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onBrowseCatalog,
                  icon: const Icon(Icons.explore),
                  label: const Text('점술 선택하기'),
                ),
                OutlinedButton.icon(
                  onPressed: onStartTarot,
                  icon: const Icon(Icons.style),
                  label: const Text('바로 타로 보기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedDivinations extends StatelessWidget {
  const _FeaturedDivinations({required this.types});

  final List<DivinationType> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const _InfoCard(
        title: '준비된 점술이 없습니다.',
        body: '활성화된 점술이 등록되면 여기서 바로 선택할 수 있습니다.',
      );
    }

    return Column(
      children: [
        for (final type in types) ...[
          _DivinationPreviewCard(type: type),
          if (type != types.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DivinationPreviewCard extends StatelessWidget {
  const _DivinationPreviewCard({required this.type});

  final DivinationType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/catalog/${type.code}'),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(_typeIcon(type), color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.displayName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    type.shortDescription ?? type.description ?? '설명이 준비 중입니다.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(label: _inputModeLabel(type.inputMode)),
                      if (type.isPlusOnly) const _Pill(label: 'Plus 전용'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(DivinationType type) {
  return switch (type.code) {
    'tarot' => Icons.style,
    'saju' => Icons.calendar_month,
    'rune' => Icons.circle_outlined,
    'omikuji' => Icons.receipt_long,
    'zodiac' => Icons.stars,
    _ => Icons.auto_awesome,
  };
}

String _inputModeLabel(String inputMode) {
  return switch (inputMode) {
    'draw_based' => '추첨형',
    'birth_data_based' => '생년월일형',
    'hybrid' => '복합형',
    _ => '기타',
  };
}
