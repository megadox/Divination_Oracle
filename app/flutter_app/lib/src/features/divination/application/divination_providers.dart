import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/divination_repository.dart';
import '../domain/daily_usage.dart';
import '../domain/divination_type.dart';
import '../domain/tarot_spread.dart';

final divinationRepositoryProvider = Provider<DivinationRepository>((ref) {
  return DivinationRepository(ref.watch(supabaseProvider));
});

final divinationTypesProvider = FutureProvider<List<DivinationType>>((ref) async {
  await ref.watch(authRepositoryProvider).ensureAnonymousSession();
  return ref.watch(divinationRepositoryProvider).fetchTypes();
});

final divinationTypeProvider =
    FutureProvider.family<DivinationType, String>((ref, code) async {
  await ref.watch(authRepositoryProvider).ensureAnonymousSession();
  return ref.watch(divinationRepositoryProvider).fetchTypeByCode(code);
});

final tarotSpreadsProvider = FutureProvider<List<TarotSpread>>((ref) async {
  await ref.watch(authRepositoryProvider).ensureAnonymousSession();
  return ref.watch(divinationRepositoryProvider).fetchTarotSpreads();
});

final dailyUsageProvider = FutureProvider<DailyUsage>((ref) async {
  await ref.watch(authRepositoryProvider).ensureAnonymousSession();
  return ref.watch(divinationRepositoryProvider).fetchTodayUsage();
});
