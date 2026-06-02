import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/reading.dart';

final readingProvider = FutureProvider.family<Reading, String>((ref, id) async {
  final client = ref.watch(supabaseProvider);
  final row = await client.from('readings').select().eq('id', id).single();
  return Reading.fromJson(row);
});

class ReadingResultScreen extends ConsumerWidget {
  const ReadingResultScreen({required this.readingId, super.key});

  final String readingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(readingProvider(readingId));

    return Scaffold(
      appBar: AppBar(title: const Text('해석 결과')),
      body: SafeArea(
        child: reading.when(
          data: (value) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                value.resultType == 'plus_ai' ? 'Plus AI 해석' : '무료 해석',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(value.resultText ?? '저장된 해석이 없습니다.'),
            ],
          ),
          error: (error, stackTrace) => Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
