import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/daily_usage.dart';
import '../domain/divination_detail.dart';
import '../domain/divination_type.dart';
import '../domain/reading.dart';
import '../domain/tarot_spread.dart';

class DivinationRepository {
  DivinationRepository(this._client);

  final SupabaseClient _client;

  Future<List<DivinationType>> fetchTypes() async {
    final response = await _client.functions.invoke('get-divination-catalog');
    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(DivinationType.fromJson).toList();
  }

  Future<DivinationDetail> fetchTypeDetail(String code) async {
    final response = await _client.functions.invoke(
      'get-divination-detail',
      body: {'code': code},
    );
    return DivinationDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TarotSpread>> fetchTarotSpreads() async {
    final detail = await fetchTypeDetail('tarot');
    return detail.spreads;
  }

  Future<DailyUsage> fetchTodayUsage() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final row = await _client
        .from('daily_usage')
        .select('free_reading_count,ai_reading_count')
        .eq('usage_date', today)
        .maybeSingle();

    if (row == null) {
      return DailyUsage.empty;
    }
    return DailyUsage.fromJson(row);
  }

  Future<Reading> createFreeReading({
    required String divinationTypeCode,
    required String category,
    required String question,
    String spreadCode = 'single_question',
    Map<String, dynamic>? inputs,
  }) async {
    final response = await _client.functions.invoke(
      'create-free-reading',
      body: {
        'divination_type_code': divinationTypeCode,
        'category': category,
        'question': question,
        'spread_code': spreadCode,
        'language_code': 'ko',
        if (inputs != null) 'inputs': inputs,
      },
    );
    return Reading.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Reading> createAiReading({
    required String divinationTypeCode,
    required String category,
    required String question,
    String spreadCode = 'single_question',
    Map<String, dynamic>? inputs,
  }) async {
    final response = await _client.functions.invoke(
      'create-ai-reading',
      body: {
        'divination_type_code': divinationTypeCode,
        'category': category,
        'question': question,
        'spread_code': spreadCode,
        'language_code': 'ko',
        if (inputs != null) 'inputs': inputs,
      },
    );
    return Reading.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Reading>> fetchReadingHistory({
    String? divinationCode,
    String? resultType,
    int limit = 30,
  }) async {
    final response = await _client.functions.invoke(
      'get-reading-history',
      body: {
        if (divinationCode != null && divinationCode.isNotEmpty)
          'divination_code': divinationCode,
        if (resultType != null && resultType.isNotEmpty) 'result_type': resultType,
        'limit': limit,
      },
    );

    final rows = (response.data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    return rows.map(Reading.fromJson).toList();
  }
}
