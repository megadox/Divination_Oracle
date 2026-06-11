import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/divination_providers.dart';

class DivinationIntroScreen extends ConsumerWidget {
  const DivinationIntroScreen({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(divinationTypeProvider(code));
    final spreads = code == 'tarot' ? ref.watch(tarotSpreadsProvider) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('점술 소개')),
      body: SafeArea(
        child: type.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                value.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                value.description ?? value.shortDescription ?? '설명이 준비 중입니다.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _IntroInfoRow(label: '입력 방식', value: _inputModeLabel(value.inputMode)),
              if (value.originRegion?.isNotEmpty == true)
                _IntroInfoRow(label: '기원', value: value.originRegion!),
              _IntroInfoRow(
                label: '해석 방식',
                value: _interpretationLabel(value.interpretationMode),
              ),
              const SizedBox(height: 20),
              _GuidanceCard(
                title: '이 점술은 이렇게 진행됩니다',
                body: _flowDescription(code),
              ),
              if (spreads != null) ...[
                const SizedBox(height: 20),
                Text(
                  '사용 가능한 타로 스프레드',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                spreads.when(
                  data: (items) => Column(
                    children: [
                      for (final spread in items) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${spread.name} (${spread.cardCount}장)'),
                          subtitle: Text(spread.description ?? ''),
                        ),
                        if (spread != items.last) const Divider(),
                      ],
                    ],
                  ),
                  error: (error, stackTrace) => Text('$error'),
                  loading: () => const CircularProgressIndicator(),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push('/reading/${value.code}'),
                icon: const Icon(Icons.arrow_forward),
                label: Text(value.code == 'tarot' ? '타로 시작하기' : '이 점술 보기'),
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
            width: 88,
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
    'draw_based' => '카드나 상징을 뽑아 해석합니다.',
    'birth_data_based' => '생년월일 등 입력값을 바탕으로 계산합니다.',
    'hybrid' => '입력과 규칙 조합으로 결과를 만듭니다.',
    _ => '준비 중입니다.',
  };
}

String _interpretationLabel(String interpretationMode) {
  return switch (interpretationMode) {
    'lookup_plus_ai' => '무료 해석 + Plus AI 확장',
    'rule_plus_ai' => '규칙 해석 + Plus AI 확장',
    'rule_based' => '규칙 기반 무료 해석',
    'prewritten_lookup' => '고정 해석 조회',
    _ => '준비 중입니다.',
  };
}

String _flowDescription(String code) {
  return switch (code) {
    'tarot' => '질문을 입력하고 스프레드를 선택한 뒤 카드를 뽑아 무료 해석을 먼저 확인합니다.',
    'saju' => '생년월일과 출생시간을 입력해 원국을 계산하고, 무료 해석 후 AI 확장을 제공합니다.',
    'zodiac' => '생년월일을 입력해 별자리를 계산하고 성향과 흐름을 안내합니다.',
    'rune' => '룬 1개 또는 3개를 뽑아 현재 에너지와 조언의 방향을 읽습니다.',
    'omikuji' => '제비를 뽑아 오늘의 길흉 분위기와 가벼운 조언을 확인합니다.',
    _ => '점술별 입력과 결과 흐름을 이 공통 구조 안에서 확장합니다.',
  };
}
