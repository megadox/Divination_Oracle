import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../divinations/shared/divination_input_definition.dart';
import '../../../divinations/shared/divination_input_registry.dart';
import '../application/divination_providers.dart';
import '../application/reading_flow_controller.dart';
import '../data/reading_error_message.dart';
import '../domain/daily_usage.dart';

class DivinationReadingScreen extends ConsumerStatefulWidget {
  const DivinationReadingScreen({
    required this.divinationCode,
    super.key,
  });

  final String divinationCode;

  @override
  ConsumerState<DivinationReadingScreen> createState() =>
      _DivinationReadingScreenState();
}

class _DivinationReadingScreenState
    extends ConsumerState<DivinationReadingScreen> {
  final _questionController = TextEditingController();
  final _sajuNameController = TextEditingController();
  final _zodiacNameController = TextEditingController();

  var _spreadCode = 'single_question';
  var _isSubmitting = false;
  DateTime? _sajuBirthDate;
  TimeOfDay? _sajuBirthTime;
  var _sajuCalendarType = 'solar';
  var _sajuGender = 'female';
  var _sajuBirthTimeUnknown = false;
  DateTime? _zodiacBirthDate;
  var _runeDrawCount = 1;

  @override
  void dispose() {
    _questionController.dispose();
    _sajuNameController.dispose();
    _zodiacNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final definition = DivinationInputRegistry.instance.find(widget.divinationCode);
    if (definition == null) {
      return UnsupportedDivinationInput(code: widget.divinationCode);
    }

    final usage = ref.watch(dailyUsageProvider);
    final draft = ref.watch(readingFlowControllerProvider(widget.divinationCode));
    final language = ref.watch(appLanguageProvider);
    final dailyUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => DailyUsage.empty,
    );
    final isFreeLimitReached = !draft.useAi && dailyUsage.isFreeLimitReached;
    final canSubmit = _canSubmit(isFreeLimitReached);
    final tarotSpreads =
        widget.divinationCode == 'tarot' ? ref.watch(tarotSpreadsProvider) : null;

    final inputContext = DivinationInputContext(
      divinationCode: widget.divinationCode,
      language: language,
      usage: usage,
      useAi: draft.useAi,
      question: draft.question,
      questionController: _questionController..text = draft.question,
      isSubmitting: _isSubmitting,
      canSubmit: canSubmit,
      isFreeLimitReached: isFreeLimitReached,
      sajuNameController: _sajuNameController,
      zodiacNameController: _zodiacNameController,
      category: draft.category,
      spreadCode: _spreadCode,
      sajuBirthDate: _sajuBirthDate,
      sajuBirthTime: _sajuBirthTime,
      sajuCalendarType: _sajuCalendarType,
      sajuGender: _sajuGender,
      sajuBirthTimeUnknown: _sajuBirthTimeUnknown,
      zodiacBirthDate: _zodiacBirthDate,
      runeDrawCount: _runeDrawCount,
      tarotSpreads: tarotSpreads,
      onOpenHome: () => context.go('/'),
      onOpenHistory: () => context.push('/history'),
      onOpenPlus: () => context.push('/plus'),
      onEditSetup: () {},
      onQuestionChanged: (value) => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .setQuestion(value),
      onCategoryChanged: (value) => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .setCategory(value),
      onSpreadChanged: (value) => setState(() => _spreadCode = value),
      onUseAiChanged: (value) => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .setUseAi(value),
      onSajuCalendarTypeChanged: (value) => setState(() => _sajuCalendarType = value),
      onSajuGenderChanged: (value) => setState(() => _sajuGender = value),
      onSajuBirthTimeUnknownChanged: (value) {
        setState(() {
          _sajuBirthTimeUnknown = value;
          if (value) {
            _sajuBirthTime = null;
          }
        });
      },
      onRuneDrawCountChanged: (value) => setState(() => _runeDrawCount = value),
      onPickSajuBirthDate: _pickSajuBirthDate,
      onPickSajuBirthTime: _pickSajuBirthTime,
      onPickZodiacBirthDate: _pickZodiacBirthDate,
      onSubmit: _submitReading,
      formatDate: _formatDate,
      formatTime: _formatTime,
    );

    return definition.build(inputContext);
  }

  bool _canSubmit(bool isFreeLimitReached) {
    if (_isSubmitting || isFreeLimitReached) {
      return false;
    }

    switch (widget.divinationCode) {
      case 'saju':
        return _sajuBirthDate != null;
      case 'zodiac':
        return _zodiacBirthDate != null;
      default:
        return true;
    }
  }

  Future<void> _submitReading() async {
    ref
        .read(readingFlowControllerProvider(widget.divinationCode).notifier)
        .setQuestion(_questionController.text);
    switch (widget.divinationCode) {
      case 'tarot':
        return _createTarotReading();
      case 'saju':
        return _createSajuReading();
      case 'zodiac':
        return _createZodiacReading();
      case 'rune':
        return _createRuneReading();
      case 'omikuji':
        return _createOmikujiReading();
    }
  }

  Future<void> _createTarotReading() async {
    await _runReadingRequest(
      request: () => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .submitReading(spreadCode: _spreadCode),
    );
  }

  Future<void> _createSajuReading() async {
    if (_sajuBirthDate == null) {
      return;
    }
    final inputs = <String, dynamic>{
      if (_sajuNameController.text.trim().isNotEmpty)
        'name': _sajuNameController.text.trim(),
      'birth_date': _formatDate(_sajuBirthDate!),
      'birth_time': _sajuBirthTimeUnknown
          ? null
          : (_sajuBirthTime == null ? null : _formatTime(_sajuBirthTime!)),
      'calendar_type': _sajuCalendarType,
      'gender': _sajuGender,
      'birth_time_unknown': _sajuBirthTimeUnknown,
    };

    await _runReadingRequest(
      request: () => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .submitReading(inputs: inputs),
      errorPrefix:
          'Saju inputs were connected, but the reading may still depend on in-progress server logic.',
    );
  }

  Future<void> _createZodiacReading() async {
    if (_zodiacBirthDate == null) {
      return;
    }
    final inputs = <String, dynamic>{
      if (_zodiacNameController.text.trim().isNotEmpty)
        'name': _zodiacNameController.text.trim(),
      'birth_date': _formatDate(_zodiacBirthDate!),
    };

    await _runReadingRequest(
      request: () => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .submitReading(inputs: inputs),
    );
  }

  Future<void> _createRuneReading() async {
    final inputs = <String, dynamic>{
      'draw_count': _runeDrawCount,
    };

    await _runReadingRequest(
      request: () => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .submitReading(inputs: inputs),
    );
  }

  Future<void> _createOmikujiReading() async {
    await _runReadingRequest(
      request: () => ref
          .read(readingFlowControllerProvider(widget.divinationCode).notifier)
          .submitReading(),
    );
  }

  Future<void> _runReadingRequest({
    required Future<dynamic> Function() request,
    String? errorPrefix,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      final reading = await request();
      if (mounted) {
        context.push('/result/${reading.id}');
      }
    } catch (error) {
      if (mounted) {
        final message = errorPrefix == null
            ? readingErrorMessage(error)
            : '$errorPrefix\n${readingErrorMessage(error)}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickSajuBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sajuBirthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() => _sajuBirthDate = picked);
    }
  }

  Future<void> _pickSajuBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _sajuBirthTime ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (picked != null && mounted) {
      setState(() => _sajuBirthTime = picked);
    }
  }

  Future<void> _pickZodiacBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _zodiacBirthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() => _zodiacBirthDate = picked);
    }
  }
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatTime(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
