import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/usage_limits.dart';
import '../../auth/application/auth_controller.dart';
import '../application/divination_providers.dart';
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
  var _category = 'general';
  var _spreadCode = 'single_question';
  var _useAi = false;
  var _isSubmitting = false;
  DateTime? _sajuBirthDate;
  TimeOfDay? _sajuBirthTime;
  var _sajuCalendarType = 'solar';
  var _sajuGender = 'female';
  var _sajuBirthTimeUnknown = false;
  DateTime? _zodiacBirthDate;
  var _runeDrawCount = 1;

  bool get _isTarot => widget.divinationCode == 'tarot';
  bool get _isSaju => widget.divinationCode == 'saju';
  bool get _isZodiac => widget.divinationCode == 'zodiac';
  bool get _isRune => widget.divinationCode == 'rune';
  bool get _isOmikuji => widget.divinationCode == 'omikuji';

  @override
  void dispose() {
    _questionController.dispose();
    _sajuNameController.dispose();
    _zodiacNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaju) {
      return _buildSajuScreen(context);
    }
    if (_isZodiac) {
      return _buildZodiacScreen(context);
    }
    if (_isRune) {
      return _buildRuneScreen(context);
    }
    if (_isOmikuji) {
      return _buildOmikujiScreen(context);
    }
    if (!_isTarot) {
      return _buildPlaceholderScreen();
    }

    final spreads = ref.watch(tarotSpreadsProvider);
    final usage = ref.watch(dailyUsageProvider);
    final dailyUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => DailyUsage.empty,
    );
    final isFreeLimitReached = !_useAi && dailyUsage.isFreeLimitReached;
    final canSubmit = !_isSubmitting && !isFreeLimitReached;

    return Scaffold(
      appBar: AppBar(
        title: const Text('타로 해석'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '질문을 남기고 타로 흐름을 확인해 보세요.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '궁금한 일을 짧게 적어주세요.',
              ),
            ),
            const SizedBox(height: 12),
            _DailyUsageBanner(usage: usage, useAi: _useAi),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '분야',
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('일반')),
                DropdownMenuItem(value: 'love', child: Text('연애')),
                DropdownMenuItem(value: 'career', child: Text('직업')),
                DropdownMenuItem(value: 'money', child: Text('금전')),
                DropdownMenuItem(value: 'health', child: Text('건강')),
                DropdownMenuItem(value: 'relationship', child: Text('관계')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              '스프레드',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            spreads.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('사용 가능한 타로 스프레드가 없습니다.');
                }
                final selectedSpread = items.any((item) => item.code == _spreadCode)
                    ? _spreadCode
                    : items.first.code;
                return DropdownButtonFormField<String>(
                  initialValue: selectedSpread,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '타로 방식',
                  ),
                  items: [
                    for (final item in items)
                      DropdownMenuItem(
                        value: item.code,
                        child: Text('${item.name} (${item.cardCount}장)'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _spreadCode = value);
                    }
                  },
                );
              },
              error: (error, stackTrace) => Text('스프레드를 불러오지 못했습니다: $error'),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.style),
                  label: Text('무료'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.auto_awesome),
                  label: Text('AI'),
                ),
              ],
              selected: {_useAi},
              onSelectionChanged: (value) {
                setState(() => _useAi = value.first);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canSubmit ? _createReading : null,
              icon: Icon(_useAi ? Icons.auto_awesome : Icons.style),
              label: Text(_useAi ? 'AI 타로 해석' : '무료 타로 해석'),
            ),
            if (isFreeLimitReached) ...[
              const SizedBox(height: 12),
              Text(
                dailyLimitReachedMessage(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            spreads.when(
              data: (items) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    if (item.code == _spreadCode)
                      Text(
                        item.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                ],
              ),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.divinationCode)),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '이 점술의 입력 화면은 다음 단계에서 연결할 예정입니다.\n현재는 타로와 사주 흐름이 새 카탈로그 구조에 먼저 연결되어 있습니다.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacScreen(BuildContext context) {
    final usage = ref.watch(dailyUsageProvider);
    final dailyUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => DailyUsage.empty,
    );
    final isFreeLimitReached = !_useAi && dailyUsage.isFreeLimitReached;
    final canSubmit =
        !_isSubmitting && !isFreeLimitReached && _zodiacBirthDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('별자리 해석'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '생년월일을 바탕으로 별자리 흐름을 읽습니다.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _DailyUsageBanner(usage: usage, useAi: _useAi),
            const SizedBox(height: 16),
            TextField(
              controller: _zodiacNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '이름 또는 별칭',
                hintText: '선택 입력',
              ),
            ),
            const SizedBox(height: 12),
            _DatePickerField(
              label: '생년월일',
              value: _zodiacBirthDate == null ? null : _formatDate(_zodiacBirthDate!),
              onTap: _pickZodiacBirthDate,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '상담 분야',
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('전체 흐름')),
                DropdownMenuItem(value: 'love', child: Text('연애')),
                DropdownMenuItem(value: 'career', child: Text('직업')),
                DropdownMenuItem(value: 'money', child: Text('금전')),
                DropdownMenuItem(value: 'relationship', child: Text('관계')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '질문',
                hintText: '예: 이번 달 인간관계 흐름이 궁금해요.',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.stars_outlined),
                  label: Text('무료'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.auto_awesome),
                  label: Text('AI'),
                ),
              ],
              selected: {_useAi},
              onSelectionChanged: (value) {
                setState(() => _useAi = value.first);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canSubmit ? _createZodiacReading : null,
              icon: Icon(_useAi ? Icons.auto_awesome : Icons.stars_outlined),
              label: Text(_useAi ? 'AI 별자리 해석' : '무료 별자리 해석'),
            ),
            if (_zodiacBirthDate == null) ...[
              const SizedBox(height: 12),
              Text(
                '생년월일은 필수 입력입니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRuneScreen(BuildContext context) {
    final usage = ref.watch(dailyUsageProvider);
    final dailyUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => DailyUsage.empty,
    );
    final isFreeLimitReached = !_useAi && dailyUsage.isFreeLimitReached;
    final canSubmit = !_isSubmitting && !isFreeLimitReached;

    return Scaffold(
      appBar: AppBar(
        title: const Text('룬 해석'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '룬 상징을 뽑아 현재 에너지와 조언을 읽습니다.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _DailyUsageBanner(usage: usage, useAi: _useAi),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _runeDrawCount,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '룬 개수',
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1개')),
                DropdownMenuItem(value: 3, child: Text('3개')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _runeDrawCount = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '상담 분야',
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('전체 흐름')),
                DropdownMenuItem(value: 'love', child: Text('연애')),
                DropdownMenuItem(value: 'career', child: Text('직업')),
                DropdownMenuItem(value: 'money', child: Text('금전')),
                DropdownMenuItem(value: 'relationship', child: Text('관계')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '질문',
                hintText: '예: 지금 방향을 바꿔도 될까요?',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.circle_outlined),
                  label: Text('무료'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.auto_awesome),
                  label: Text('AI'),
                ),
              ],
              selected: {_useAi},
              onSelectionChanged: (value) {
                setState(() => _useAi = value.first);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canSubmit ? _createRuneReading : null,
              icon: Icon(_useAi ? Icons.auto_awesome : Icons.circle_outlined),
              label: Text(_useAi ? 'AI 룬 해석' : '무료 룬 해석'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOmikujiScreen(BuildContext context) {
    final usage = ref.watch(dailyUsageProvider);
    final dailyUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => DailyUsage.empty,
    );
    final isFreeLimitReached = !_useAi && dailyUsage.isFreeLimitReached;
    final canSubmit = !_isSubmitting && !isFreeLimitReached;

    return Scaffold(
      appBar: AppBar(
        title: const Text('오미쿠지 해석'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '제비를 뽑아 오늘의 분위기와 조언을 확인합니다.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _DailyUsageBanner(usage: usage, useAi: _useAi),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '집중하고 싶은 분야',
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('전체 운세')),
                DropdownMenuItem(value: 'love', child: Text('연애')),
                DropdownMenuItem(value: 'career', child: Text('직업')),
                DropdownMenuItem(value: 'money', child: Text('금전')),
                DropdownMenuItem(value: 'relationship', child: Text('관계')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '질문',
                hintText: '예: 오늘 중요한 결정을 해도 괜찮을까요?',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.receipt_long),
                  label: Text('무료'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.auto_awesome),
                  label: Text('AI'),
                ),
              ],
              selected: {_useAi},
              onSelectionChanged: (value) {
                setState(() => _useAi = value.first);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canSubmit ? _createOmikujiReading : null,
              icon: Icon(_useAi ? Icons.auto_awesome : Icons.receipt_long),
              label: Text(_useAi ? 'AI 오미쿠지 해석' : '무료 오미쿠지 해석'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSajuScreen(BuildContext context) {
    final usage = ref.watch(dailyUsageProvider);
    final dailyUsage = usage.maybeWhen(
      data: (value) => value,
      orElse: () => DailyUsage.empty,
    );
    final isFreeLimitReached = !_useAi && dailyUsage.isFreeLimitReached;
    final canSubmit =
        !_isSubmitting && !isFreeLimitReached && _sajuBirthDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('사주 해석'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: () => context.push('/plus'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '생년월일과 출생시간을 바탕으로 사주 흐름을 준비합니다.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '출생시간을 모르면 비워둘 수 있지만, 일부 해석의 정확도가 낮아질 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _DailyUsageBanner(usage: usage, useAi: _useAi),
            const SizedBox(height: 16),
            TextField(
              controller: _sajuNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '이름 또는 별칭',
                hintText: '선택 입력',
              ),
            ),
            const SizedBox(height: 12),
            _DatePickerField(
              label: '생년월일',
              value: _sajuBirthDate == null
                  ? null
                  : _formatDate(_sajuBirthDate!),
              onTap: _pickSajuBirthDate,
            ),
            const SizedBox(height: 12),
            _TimePickerField(
              label: '출생시간',
              value: _sajuBirthTimeUnknown
                  ? '시간 모름'
                  : (_sajuBirthTime == null ? null : _formatTime(_sajuBirthTime!)),
              onTap: _sajuBirthTimeUnknown ? null : _pickSajuBirthTime,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('출생시간을 모릅니다'),
              value: _sajuBirthTimeUnknown,
              onChanged: (value) {
                setState(() {
                  _sajuBirthTimeUnknown = value;
                  if (value) {
                    _sajuBirthTime = null;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _sajuCalendarType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '달력 종류',
              ),
              items: const [
                DropdownMenuItem(value: 'solar', child: Text('양력')),
                DropdownMenuItem(value: 'lunar', child: Text('음력')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sajuCalendarType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _sajuGender,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '성별',
              ),
              items: const [
                DropdownMenuItem(value: 'female', child: Text('여성')),
                DropdownMenuItem(value: 'male', child: Text('남성')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sajuGender = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '상담 분야',
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('전체 흐름')),
                DropdownMenuItem(value: 'love', child: Text('연애')),
                DropdownMenuItem(value: 'career', child: Text('직업')),
                DropdownMenuItem(value: 'money', child: Text('금전')),
                DropdownMenuItem(value: 'health', child: Text('건강')),
                DropdownMenuItem(value: 'relationship', child: Text('관계')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '질문',
                hintText: '예: 올해 이직운이 궁금해요.',
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.menu_book_outlined),
                  label: Text('무료'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.auto_awesome),
                  label: Text('AI'),
                ),
              ],
              selected: {_useAi},
              onSelectionChanged: (value) {
                setState(() => _useAi = value.first);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: canSubmit ? _createSajuReading : null,
              icon: Icon(_useAi ? Icons.auto_awesome : Icons.menu_book_outlined),
              label: Text(_useAi ? 'AI 사주 해석' : '무료 사주 해석'),
            ),
            if (_sajuBirthDate == null) ...[
              const SizedBox(height: 12),
              Text(
                '생년월일은 필수 입력입니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            if (isFreeLimitReached) ...[
              const SizedBox(height: 12),
              Text(
                dailyLimitReachedMessage(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '입력 요약',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('생년월일: ${_sajuBirthDate == null ? '선택 필요' : _formatDate(_sajuBirthDate!)}'),
                    Text(
                      '출생시간: ${_sajuBirthTimeUnknown ? '시간 모름' : (_sajuBirthTime == null ? '선택 안 함' : _formatTime(_sajuBirthTime!))}',
                    ),
                    Text('달력 종류: ${_sajuCalendarType == 'solar' ? '양력' : '음력'}'),
                    Text('성별: ${_sajuGender == 'female' ? '여성' : '남성'}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createReading() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final repository = ref.read(divinationRepositoryProvider);
      final reading = _useAi
          ? await repository.createAiReading(
              divinationTypeCode: 'tarot',
              category: _category,
              question: _questionController.text,
              spreadCode: _spreadCode,
            )
          : await repository.createFreeReading(
              divinationTypeCode: 'tarot',
              category: _category,
              question: _questionController.text,
              spreadCode: _spreadCode,
            );
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        context.push('/result/${reading.id}');
      }
    } catch (error) {
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(readingErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createSajuReading() async {
    if (_sajuBirthDate == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final repository = ref.read(divinationRepositoryProvider);
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

      final reading = _useAi
          ? await repository.createAiReading(
              divinationTypeCode: 'saju',
              category: _category,
              question: _questionController.text,
              inputs: inputs,
            )
          : await repository.createFreeReading(
              divinationTypeCode: 'saju',
              category: _category,
              question: _questionController.text,
              inputs: inputs,
            );

      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        context.push('/result/${reading.id}');
      }
    } catch (error) {
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '사주 입력 폼은 연결되었지만, 서버 해석 로직은 아직 준비 중일 수 있습니다.\n${readingErrorMessage(error)}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createZodiacReading() async {
    if (_zodiacBirthDate == null) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final repository = ref.read(divinationRepositoryProvider);
      final inputs = <String, dynamic>{
        if (_zodiacNameController.text.trim().isNotEmpty)
          'name': _zodiacNameController.text.trim(),
        'birth_date': _formatDate(_zodiacBirthDate!),
      };
      final reading = _useAi
          ? await repository.createAiReading(
              divinationTypeCode: 'zodiac',
              category: _category,
              question: _questionController.text,
              inputs: inputs,
            )
          : await repository.createFreeReading(
              divinationTypeCode: 'zodiac',
              category: _category,
              question: _questionController.text,
              inputs: inputs,
            );
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        context.push('/result/${reading.id}');
      }
    } catch (error) {
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(readingErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createRuneReading() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final repository = ref.read(divinationRepositoryProvider);
      final inputs = <String, dynamic>{
        'draw_count': _runeDrawCount,
      };
      final reading = _useAi
          ? await repository.createAiReading(
              divinationTypeCode: 'rune',
              category: _category,
              question: _questionController.text,
              inputs: inputs,
            )
          : await repository.createFreeReading(
              divinationTypeCode: 'rune',
              category: _category,
              question: _questionController.text,
              inputs: inputs,
            );
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        context.push('/result/${reading.id}');
      }
    } catch (error) {
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(readingErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createOmikujiReading() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
      final repository = ref.read(divinationRepositoryProvider);
      final reading = _useAi
          ? await repository.createAiReading(
              divinationTypeCode: 'omikuji',
              category: _category,
              question: _questionController.text,
            )
          : await repository.createFreeReading(
              divinationTypeCode: 'omikuji',
              category: _category,
              question: _questionController.text,
            );
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        context.push('/result/${reading.id}');
      }
    } catch (error) {
      ref.invalidate(dailyUsageProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(readingErrorMessage(error))),
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
      initialDate: _zodiacBirthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() => _zodiacBirthDate = picked);
    }
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.onTap,
    this.value,
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
              child: Text(value ?? '선택해 주세요'),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    this.value,
    this.onTap,
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
              child: Text(value ?? '선택해 주세요'),
            ),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
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

class _DailyUsageBanner extends StatelessWidget {
  const _DailyUsageBanner({
    required this.usage,
    required this.useAi,
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
                    child: Text('개발 모드에서는 무료 해석 횟수 제한을 적용하지 않습니다.'),
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
                        ? '오늘 무료 해석 ${UsageLimits.freeDailyReadingLimit}회를 모두 사용했습니다.'
                        : '오늘 남은 무료 해석: $remaining/${UsageLimits.freeDailyReadingLimit}회',
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
