import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/usage_limits.dart';
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
            tooltip: 'History',
            onPressed: contextData.onOpenHistory,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: contextData.onOpenPlus,
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: children,
        ),
      ),
    );
  }
}

class CommonReadingSummaryCard extends StatelessWidget {
  const CommonReadingSummaryCard({
    required this.question,
    required this.category,
    required this.useAi,
    required this.onEdit,
    super.key,
  });

  final String question;
  final String category;
  final bool useAi;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
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
                    'Reading Setup',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Mode: ${useAi ? 'Plus AI' : 'Free'}'),
            Text('Category: $category'),
            const SizedBox(height: 8),
            Text(
              question.trim().isEmpty ? 'Question: none' : 'Question: $question',
            ),
          ],
        ),
      ),
    );
  }
}

class DailyUsageBanner extends StatelessWidget {
  const DailyUsageBanner({
    required this.usage,
    required this.useAi,
    super.key,
  });

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
          return const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.developer_mode, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free reading daily limit is disabled in development mode.',
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
                        ? 'Today\'s free reading limit (${UsageLimits.freeDailyReadingLimit}) has been reached.'
                        : 'Remaining free readings today: $remaining/${UsageLimits.freeDailyReadingLimit}',
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
              child: Text(value ?? 'Tap to select'),
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
              child: Text(value ?? 'Tap to select'),
            ),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }
}
