import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final filters = ReadingHistoryFilters(
      divinationCode: _divinationCode,
      resultType: _resultType,
    );
    final readings = ref.watch(readingHistoryProvider(filters));
    final types = ref.watch(divinationTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                types.when(
                  data: (items) => DropdownButtonFormField<String?>(
                    initialValue: _divinationCode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Divination',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All divinations'),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mode',
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All modes'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'free',
                      child: Text('Free'),
                    ),
                    DropdownMenuItem<String?>(
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
                  return const Center(child: Text('No reading history yet.'));
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final title = item.question?.isNotEmpty == true
                        ? item.question!
                        : 'No question';
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
