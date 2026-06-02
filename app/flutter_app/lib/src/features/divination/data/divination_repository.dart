import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/divination_type.dart';
import '../domain/reading.dart';

class DivinationRepository {
  DivinationRepository(this._client);

  final SupabaseClient _client;

  Future<List<DivinationType>> fetchTypes() async {
    final rows = await _client
        .from('divination_types')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return rows.map(DivinationType.fromJson).toList();
  }

  Future<Reading> createFreeReading({
    required String divinationTypeCode,
    required String category,
    required String question,
    String spreadCode = 'single',
  }) async {
    final response = await _client.functions.invoke(
      'create-free-reading',
      body: {
        'divination_type_code': divinationTypeCode,
        'category': category,
        'question': question,
        'spread_code': spreadCode,
        'language_code': 'ko',
      },
    );
    return Reading.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Reading> createAiReading({
    required String divinationTypeCode,
    required String category,
    required String question,
    String spreadCode = 'single',
  }) async {
    final response = await _client.functions.invoke(
      'create-ai-reading',
      body: {
        'divination_type_code': divinationTypeCode,
        'category': category,
        'question': question,
        'spread_code': spreadCode,
        'language_code': 'ko',
      },
    );
    return Reading.fromJson(response.data as Map<String, dynamic>);
  }
}
