import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_language.dart';
import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';
import '../../features/divination/presentation/divination_localizations.dart';

class TarotInputDefinition extends DivinationInputDefinition {
  const TarotInputDefinition();

  @override
  String get code => 'tarot';

  @override
  Widget build(DivinationInputContext context) {
    final spreads = context.tarotSpreads;
    return DivinationInputScaffold(
      title: context.language == AppLanguage.ko ? '타로 해석' : 'Tarot Reading',
      contextData: context,
      children: [
        Text(
          context.language == AppLanguage.ko
              ? '질문을 확인하고 스프레드를 선택한 뒤 카드를 뽑아 보세요.'
              : 'Review your question, choose a spread, and draw the cards.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        CommonReadingSummaryCard(contextData: context),
        const SizedBox(height: 12),
        DailyUsageBanner(
          language: context.language,
          usage: context.usage,
          useAi: context.useAi,
        ),
        const SizedBox(height: 20),
        Text(
          context.language == AppLanguage.ko ? '스프레드' : 'Spread',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (spreads != null)
          spreads.when(
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  context.language == AppLanguage.ko
                      ? '사용 가능한 타로 스프레드가 없습니다.'
                      : 'No active tarot spreads are available.',
                );
              }

              final selectedSpread = items.any((item) => item.code == context.spreadCode)
                  ? context.spreadCode
                  : items.first.code;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpread,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: context.language == AppLanguage.ko
                          ? '타로 스프레드'
                          : 'Tarot Spread',
                    ),
                    items: [
                      for (final item in items)
                        DropdownMenuItem(
                          value: item.code,
                          child: Text(
                            context.language == AppLanguage.ko
                                ? '${localizedSpreadName(item, context.language)} (${item.cardCount}장)'
                                : '${localizedSpreadName(item, context.language)} (${item.cardCount} cards)',
                          ),
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
                      Text(localizedSpreadDescription(item, context.language)),
                ],
              );
            },
            error: (error, stackTrace) => Text(
              context.language == AppLanguage.ko
                  ? '스프레드를 불러오지 못했습니다: $error'
                  : 'Failed to load spreads: $error',
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.style),
          label: Text(
            context.useAi
                ? (context.language == AppLanguage.ko
                      ? 'AI 타로 해석 생성'
                      : 'Generate AI tarot reading')
                : (context.language == AppLanguage.ko
                      ? '무료 타로 해석 생성'
                      : 'Generate free tarot reading'),
          ),
        ),
        if (context.isFreeLimitReached) ...[
          const SizedBox(height: 12),
          Text(
            context.language == AppLanguage.ko
                ? '오늘 무료 해석 한도에 도달했습니다.'
                : 'Daily free reading limit reached.',
            style: TextStyle(color: ThemeData().colorScheme.error),
          ),
        ],
      ],
    );
  }
}
