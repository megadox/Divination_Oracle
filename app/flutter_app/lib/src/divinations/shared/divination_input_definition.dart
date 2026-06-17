import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_language.dart';
import '../../features/divination/domain/daily_usage.dart';
import '../../features/divination/domain/tarot_spread.dart';

class DivinationInputContext {
  const DivinationInputContext({
    required this.divinationCode,
    required this.language,
    required this.usage,
    required this.useAi,
    required this.question,
    required this.questionController,
    required this.isSubmitting,
    required this.canSubmit,
    required this.isFreeLimitReached,
    required this.sajuNameController,
    required this.zodiacNameController,
    required this.category,
    required this.spreadCode,
    required this.sajuBirthDate,
    required this.sajuBirthTime,
    required this.sajuCalendarType,
    required this.sajuGender,
    required this.sajuBirthTimeUnknown,
    required this.zodiacBirthDate,
    required this.runeDrawCount,
    required this.tarotSpreads,
    required this.onOpenHistory,
    required this.onOpenHome,
    required this.onOpenPlus,
    required this.onEditSetup,
    required this.onQuestionChanged,
    required this.onCategoryChanged,
    required this.onSpreadChanged,
    required this.onUseAiChanged,
    required this.onSajuCalendarTypeChanged,
    required this.onSajuGenderChanged,
    required this.onSajuBirthTimeUnknownChanged,
    required this.onRuneDrawCountChanged,
    required this.onPickSajuBirthDate,
    required this.onPickSajuBirthTime,
    required this.onPickZodiacBirthDate,
    required this.onSubmit,
    required this.formatDate,
    required this.formatTime,
  });

  final String divinationCode;
  final AppLanguage language;
  final AsyncValue<DailyUsage> usage;
  final bool useAi;
  final String question;
  final TextEditingController questionController;
  final bool isSubmitting;
  final bool canSubmit;
  final bool isFreeLimitReached;
  final TextEditingController sajuNameController;
  final TextEditingController zodiacNameController;
  final String category;
  final String spreadCode;
  final DateTime? sajuBirthDate;
  final TimeOfDay? sajuBirthTime;
  final String sajuCalendarType;
  final String sajuGender;
  final bool sajuBirthTimeUnknown;
  final DateTime? zodiacBirthDate;
  final int runeDrawCount;
  final AsyncValue<List<TarotSpread>>? tarotSpreads;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenHome;
  final VoidCallback onOpenPlus;
  final VoidCallback onEditSetup;
  final ValueChanged<String> onQuestionChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSpreadChanged;
  final ValueChanged<bool> onUseAiChanged;
  final ValueChanged<String> onSajuCalendarTypeChanged;
  final ValueChanged<String> onSajuGenderChanged;
  final ValueChanged<bool> onSajuBirthTimeUnknownChanged;
  final ValueChanged<int> onRuneDrawCountChanged;
  final VoidCallback onPickSajuBirthDate;
  final VoidCallback onPickSajuBirthTime;
  final VoidCallback onPickZodiacBirthDate;
  final VoidCallback onSubmit;
  final String Function(DateTime) formatDate;
  final String Function(TimeOfDay) formatTime;
}

abstract class DivinationInputDefinition {
  const DivinationInputDefinition();

  String get code;

  Widget build(DivinationInputContext context);
}
