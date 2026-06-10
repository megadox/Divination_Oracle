import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/usage_limits.dart';
import '../../auth/application/auth_controller.dart';
import '../application/divination_providers.dart';
import '../data/reading_error_message.dart';
import '../domain/daily_usage.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _questionController = TextEditingController();
  var _category = 'general';
  var _spreadCode = 'single_question';
  var _useAi = false;
  var _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Divination'),
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
              '오늘의 질문',
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
