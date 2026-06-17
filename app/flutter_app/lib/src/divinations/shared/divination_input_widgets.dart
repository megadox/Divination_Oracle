import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/usage_limits.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/page_index_card.dart';
import '../../features/divination/domain/daily_usage.dart';
import 'divination_input_definition.dart';

class DivinationInputScaffold extends StatelessWidget {
  const DivinationInputScaffold({
    required this.title,
    required this.contextData,
    required this.children,
    super.key,
  });

  final String title;
  final DivinationInputContext contextData;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: contextData.language == AppLanguage.ko ? '홈' : 'Home',
            onPressed: contextData.onOpenHome,
            icon: const Icon(Icons.home_outlined),
          ),
          IconButton(
            tooltip: contextData.language == AppLanguage.ko ? '기록' : 'History',
            onPressed: contextData.onOpenHistory,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: contextData.language == AppLanguage.ko ? '플러스' : 'Plus',
            onPressed: contextData.onOpenPlus,
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PageIndexCard(
              index: 'p_3',
              label: contextData.language == AppLanguage.ko
                  ? '질문 + 점술 입력'
                  : 'Question + divination input',
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class CommonReadingSummaryCard extends StatelessWidget {
  const CommonReadingSummaryCard({
    required this.contextData,
    super.key,
  });

  final DivinationInputContext contextData;

  @override
  Widget build(BuildContext context) {
    final language = contextData.language;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    language == AppLanguage.ko
                        ? '질문과 해석 설정'
                        : 'Question and reading setup',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contextData.questionController,
              minLines: 2,
              maxLines: 4,
              onChanged: contextData.onQuestionChanged,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: language == AppLanguage.ko ? '질문' : 'Question',
                hintText: language == AppLanguage.ko
                    ? '일반 흐름만 보고 싶다면 비워둘 수 있습니다.'
                    : 'You can leave this blank if you want a general reading.',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: contextData.category,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: language == AppLanguage.ko ? '카테고리' : 'Category',
              ),
              items: [
                DropdownMenuItem(
                  value: 'general',
                  child: Text(language == AppLanguage.ko ? '일반' : 'General'),
                ),
                DropdownMenuItem(
                  value: 'love',
                  child: Text(language == AppLanguage.ko ? '연애' : 'Love'),
                ),
                DropdownMenuItem(
                  value: 'career',
                  child: Text(language == AppLanguage.ko ? '직업' : 'Career'),
                ),
                DropdownMenuItem(
                  value: 'money',
                  child: Text(language == AppLanguage.ko ? '금전' : 'Money'),
                ),
                DropdownMenuItem(
                  value: 'health',
                  child: Text(language == AppLanguage.ko ? '건강' : 'Health'),
                ),
                DropdownMenuItem(
                  value: 'relationship',
                  child: Text(language == AppLanguage.ko ? '관계' : 'Relationship'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  contextData.onCategoryChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            ReadingModeSelector(
              useAi: contextData.useAi,
              onChanged: contextData.onUseAiChanged,
              freeLabel: language == AppLanguage.ko ? '무료' : 'Free',
              aiLabel: 'AI',
            ),
          ],
        ),
      ),
    );
  }
}

class DailyUsageBanner extends StatelessWidget {
  const DailyUsageBanner({
    required this.language,
    required this.usage,
    required this.useAi,
    super.key,
  });

  final AppLanguage language;
  final AsyncValue<DailyUsage> usage;
  final bool useAi;

  @override
  Widget build(BuildContext context) {
    if (useAi) {
      return const SizedBox.shrink();
    }

    return usage.when(
      data: (value) {
        if (!UsageLimits.isFreeReadingLimitEnabled) {
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.developer_mode, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      language == AppLanguage.ko
                          ? '개발 모드에서는 무료 해석 일일 제한이 비활성화되어 있습니다.'
                          : 'Free reading daily limit is disabled in development mode.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final remaining = value.remainingFreeReadings;
        final isLimitReached = value.isFreeLimitReached;
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isLimitReached ? Icons.hourglass_empty : Icons.style,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isLimitReached
                        ? (language == AppLanguage.ko
                              ? '오늘 무료 해석 ${UsageLimits.freeDailyReadingLimit}회를 모두 사용했습니다.'
                              : 'Today\'s free reading limit (${UsageLimits.freeDailyReadingLimit}) has been reached.')
                        : (language == AppLanguage.ko
                              ? '오늘 남은 무료 해석: $remaining/${UsageLimits.freeDailyReadingLimit}'
                              : 'Remaining free readings today: $remaining/${UsageLimits.freeDailyReadingLimit}'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class ReadingModeSelector extends StatelessWidget {
  const ReadingModeSelector({
    required this.useAi,
    required this.onChanged,
    required this.freeLabel,
    required this.aiLabel,
    super.key,
  });

  final bool useAi;
  final ValueChanged<bool> onChanged;
  final String freeLabel;
  final String aiLabel;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          icon: const Icon(Icons.style),
          label: Text(freeLabel),
        ),
        ButtonSegment(
          value: true,
          icon: const Icon(Icons.auto_awesome),
          label: Text(aiLabel),
        ),
      ],
      selected: {useAi},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    required this.label,
    required this.onTap,
    this.value,
    super.key,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value ?? (_isKorean(context) ? '선택해 주세요' : 'Tap to select')),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    required this.label,
    this.value,
    this.onTap,
    super.key,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value ?? (_isKorean(context) ? '선택해 주세요' : 'Tap to select')),
            ),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }
}

bool _isKorean(BuildContext context) {
  final scope = ProviderScope.containerOf(context, listen: false);
  return scope.read(appLanguageProvider) == AppLanguage.ko;
}
