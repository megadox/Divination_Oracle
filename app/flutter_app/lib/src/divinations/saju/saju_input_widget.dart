import 'package:flutter/material.dart';

import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class SajuInputDefinition extends DivinationInputDefinition {
  const SajuInputDefinition();

  @override
  String get code => 'saju';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: 'Saju Reading',
      contextData: context,
      children: [
        const Text(
          'Enter birth data to prepare a Saju chart-based reading.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Birth time is optional, but the reading will be less specific without it.',
        ),
        const SizedBox(height: 16),
        CommonReadingSummaryCard(
          question: context.question,
          category: context.category,
          useAi: context.useAi,
          onEdit: context.onEditSetup,
        ),
        const SizedBox(height: 16),
        DailyUsageBanner(usage: context.usage, useAi: context.useAi),
        const SizedBox(height: 16),
        TextField(
          controller: context.sajuNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name or nickname',
            hintText: 'Optional',
          ),
        ),
        const SizedBox(height: 12),
        DatePickerField(
          label: 'Birth date',
          value: context.sajuBirthDate == null
              ? null
              : context.formatDate(context.sajuBirthDate!),
          onTap: context.onPickSajuBirthDate,
        ),
        const SizedBox(height: 12),
        TimePickerField(
          label: 'Birth time',
          value: context.sajuBirthTimeUnknown
              ? 'Unknown'
              : (context.sajuBirthTime == null
                  ? null
                  : context.formatTime(context.sajuBirthTime!)),
          onTap: context.sajuBirthTimeUnknown ? null : context.onPickSajuBirthTime,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Birth time unknown'),
          value: context.sajuBirthTimeUnknown,
          onChanged: context.onSajuBirthTimeUnknownChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: context.sajuCalendarType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Calendar',
          ),
          items: const [
            DropdownMenuItem(value: 'solar', child: Text('Solar')),
            DropdownMenuItem(value: 'lunar', child: Text('Lunar')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.onSajuCalendarTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: context.sajuGender,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Gender',
          ),
          items: const [
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'male', child: Text('Male')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.onSajuGenderChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: context.canSubmit ? context.onSubmit : null,
          icon: Icon(context.useAi ? Icons.auto_awesome : Icons.menu_book_outlined),
          label: Text(context.useAi ? 'Generate AI Saju reading' : 'Generate free Saju reading'),
        ),
        if (context.sajuBirthDate == null) ...[
          const SizedBox(height: 12),
          const Text('Birth date is required.'),
        ],
      ],
    );
  }
}
