import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/divination_type.dart';
import '../domain/reading.dart';
import '../domain/tarot_spread.dart';

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

  Future<List<TarotSpread>> fetchTarotSpreads() async {
    final tarotType = await _client
        .from('divination_types')
        .select('id')
        .eq('code', 'tarot')
        .eq('is_active', true)
        .single();
    final rows = await _client
        .from('spreads')
        .select()
        .eq('divination_type_id', tarotType['id'] as String)
        .eq('is_active', true)
        .order('sort_order');
    return rows.map(TarotSpread.fromJson).toList();
  }

  Future<Reading> createFreeReading({
    required String divinationTypeCode,
    required String category,
    required String question,
    String spreadCode = 'single_question',
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
    String spreadCode = 'single_question',
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
