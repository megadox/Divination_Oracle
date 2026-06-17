import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/widgets/page_index_card.dart';
import '../../auth/application/auth_controller.dart';
import '../../divination/application/divination_providers.dart';
import '../../divination/domain/reading.dart';
import 'history_filters.dart';

final readingHistoryProvider =
    FutureProvider.family<List<Reading>, ReadingHistoryFilters>((ref, filters) async {
  await ref.watch(authRepositoryProvider).ensureAnonymousSession();
  return ref.watch(divinationRepositoryProvider).fetchReadingHistory(
        divinationCode: filters.divinationCode,
        resultType: filters.resultType,
      );
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _divinationCode;
  String? _resultType;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final filters = ReadingHistoryFilters(
      divinationCode: _divinationCode,
      resultType: _resultType,
    );
    final readings = ref.watch(readingHistoryProvider(filters));
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(language == AppLanguage.ko ? '기록' : 'History'),
        actions: [
          IconButton(
            tooltip: language == AppLanguage.ko ? '홈' : 'Home',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                PageIndexCard(
                  index: 'p_5',
                  label: language == AppLanguage.ko ? '리딩 기록' : 'Reading history',
                ),
                const SizedBox(height: 12),
                types.when(
                  data: (items) => DropdownButtonFormField<String?>(
                    initialValue: _divinationCode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: language == AppLanguage.ko ? '점술' : 'Divination',
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          language == AppLanguage.ko ? '전체 점술' : 'All divinations',
                        ),
                      ),
                      for (final item in items)
                        DropdownMenuItem<String?>(
                          value: item.code,
                          child: Text(item.displayName),
                        ),
                    ],
                    onChanged: (value) => setState(() => _divinationCode = value),
                  ),
                  error: (error, stackTrace) => Text('$error'),
                  loading: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _resultType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: language == AppLanguage.ko ? '모드' : 'Mode',
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(language == AppLanguage.ko ? '전체 모드' : 'All modes'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'free',
                      child: Text(language == AppLanguage.ko ? '무료' : 'Free'),
                    ),
                    const DropdownMenuItem<String?>(
                      value: 'plus_ai',
                      child: Text('Plus AI'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _resultType = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: readings.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      language == AppLanguage.ko
                          ? '아직 리딩 기록이 없습니다.'
                          : 'No reading history yet.',
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final title = item.question?.isNotEmpty == true
                        ? item.question!
                        : (language == AppLanguage.ko ? '질문 없음' : 'No question');
                    final subtitleParts = <String>[
                      if ((item.divinationDisplayName ?? '').isNotEmpty)
                        item.divinationDisplayName!,
                      item.spreadCode,
                      item.resultType,
                    ];

                    return ListTile(
                      title: Text(title),
                      subtitle: Text(subtitleParts.join(' | ')),
                      trailing: Text(
                        _formatDate(item.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => context.push('/result/${item.id}'),
                    );
                  },
                );
              },
              error: (error, stackTrace) => Center(child: Text('$error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month/$day $hour:$minute';
}
