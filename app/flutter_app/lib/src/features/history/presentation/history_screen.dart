import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../divination/domain/reading.dart';

final readingHistoryProvider = FutureProvider<List<Reading>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final rows = await client
      .from('readings')
      .select()
      .order('created_at', ascending: false)
      .limit(30);
  return rows.map(Reading.fromJson).toList();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(readingHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('기록')),
      body: readings.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.question?.isNotEmpty == true ? item.question! : '질문 없음'),
              subtitle: Text(item.resultType),
            );
          },
        ),
        error: (error, stackTrace) => Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
