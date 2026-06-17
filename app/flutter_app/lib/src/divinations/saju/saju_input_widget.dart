import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../shared/divination_input_definition.dart';
import '../shared/divination_input_widgets.dart';

class SajuInputDefinition extends DivinationInputDefinition {
  const SajuInputDefinition();

  @override
  String get code => 'saju';

  @override
  Widget build(DivinationInputContext context) {
    return DivinationInputScaffold(
      title: context.language == AppLanguage.ko ? '사주 해석' : 'Saju Reading',
      contextData: context,
      children: [
        Text(
          context.language == AppLanguage.ko
              ? '생년월일시를 입력해 사주 기반 해석을 준비합니다.'
              : 'Enter birth data to prepare a Saju chart-based reading.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          context.language == AppLanguage.ko
              ? '출생시간은 선택 입력이지만, 없으면 해석이 덜 구체적일 수 있습니다.'
              : 'Birth time is optional, but the reading will be less specific without it.',
        ),
        const SizedBox(height: 16),
        CommonReadingSummaryCard(contextData: context),
        const SizedBox(height: 16),
        DailyUsageBanner(
          language: context.language,
          usage: context.usage,
          useAi: context.useAi,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: context.sajuNameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.language == AppLanguage.ko
                ? '이름 또는 별칭'
                : 'Name or nickname',
            hintText: context.language == AppLanguage.ko ? '선택 입력' : 'Optional',
          ),
        ),
        const SizedBox(height: 12),
        DatePickerField(
          label: context.language == AppLanguage.ko ? '생년월일' : 'Birth date',
          value: context.sajuBirthDate == null
              ? null
              : context.formatDate(context.sajuBirthDate!),
          onTap: context.onPickSajuBirthDate,
        ),
        const SizedBox(height: 12),
        TimePickerField(
          label: context.language == AppLanguage.ko ? '출생시간' : 'Birth time',
          value: context.sajuBirthTimeUnknown
              ? (context.language == AppLanguage.ko ? '모름' : 'Unknown')
              : (context.sajuBirthTime == null
                  ? null
                  : context.formatTime(context.sajuBirthTime!)),
          onTap: context.sajuBirthTimeUnknown ? null : context.onPickSajuBirthTime,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            context.language == AppLanguage.ko
                ? '출생시간을 모릅니다'
                : 'Birth time unknown',
          ),
          value: context.sajuBirthTimeUnknown,
          onChanged: context.onSajuBirthTimeUnknownChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: context.sajuCalendarType,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.language == AppLanguage.ko ? '달력' : 'Calendar',
          ),
          items: [
            DropdownMenuItem(
              value: 'solar',
              child: Text(context.language == AppLanguage.ko ? '양력' : 'Solar'),
            ),
            DropdownMenuItem(
              value: 'lunar',
              child: Text(context.language == AppLanguage.ko ? '음력' : 'Lunar'),
            ),
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
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: context.language == AppLanguage.ko ? '성별' : 'Gender',
          ),
          items: [
            DropdownMenuItem(
              value: 'female',
              child: Text(context.language == AppLanguage.ko ? '여성' : 'Female'),
            ),
            DropdownMenuItem(
              value: 'male',
              child: Text(context.language == AppLanguage.ko ? '남성' : 'Male'),
            ),
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
          label: Text(
            context.useAi
                ? (context.language == AppLanguage.ko
                      ? 'AI 사주 해석 생성'
                      : 'Generate AI Saju reading')
                : (context.language == AppLanguage.ko
                      ? '무료 사주 해석 생성'
                      : 'Generate free Saju reading'),
          ),
        ),
        if (context.sajuBirthDate == null) ...[
          const SizedBox(height: 12),
          Text(
            context.language == AppLanguage.ko
                ? '생년월일은 필수입니다.'
                : 'Birth date is required.',
          ),
        ],
      ],
    );
  }
}
