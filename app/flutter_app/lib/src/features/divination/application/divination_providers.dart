import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/divination_repository.dart';
import '../domain/divination_type.dart';

final divinationRepositoryProvider = Provider<DivinationRepository>((ref) {
  return DivinationRepository(ref.watch(supabaseProvider));
});

final divinationTypesProvider = FutureProvider<List<DivinationType>>((ref) {
  return ref.watch(divinationRepositoryProvider).fetchTypes();
});
