import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../domain/reading.dart';
import '../domain/reading_draft.dart';
import 'divination_providers.dart';

class ReadingFlowController extends FamilyNotifier<ReadingDraft, String> {
  @override
  ReadingDraft build(String arg) => const ReadingDraft();

  void setQuestion(String question) {
    state = state.copyWith(question: question);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setUseAi(bool useAi) {
    state = state.copyWith(useAi: useAi);
  }

  void replace(ReadingDraft draft) {
    state = draft;
  }

  void reset() {
    state = const ReadingDraft();
  }

  Future<Reading> submitReading({
    String? spreadCode,
    Map<String, dynamic>? inputs,
  }) async {
    await ref.read(authControllerProvider.notifier).ensureAnonymousSession();
    final repository = ref.read(divinationRepositoryProvider);
    final reading = state.useAi
        ? await repository.createAiReading(
            divinationTypeCode: arg,
            category: state.category,
            question: state.question,
            spreadCode: spreadCode ?? '${arg}_basic',
            inputs: inputs,
          )
        : await repository.createFreeReading(
            divinationTypeCode: arg,
            category: state.category,
            question: state.question,
            spreadCode: spreadCode ?? '${arg}_basic',
            inputs: inputs,
          );

    ref.invalidate(dailyUsageProvider);
    reset();
    return reading;
  }
}

final readingFlowControllerProvider =
    NotifierProviderFamily<ReadingFlowController, ReadingDraft, String>(
  ReadingFlowController.new,
);
