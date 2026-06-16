class ReadingDraft {
  const ReadingDraft({
    this.question = '',
    this.category = 'general',
    this.useAi = false,
  });

  final String question;
  final String category;
  final bool useAi;

  ReadingDraft copyWith({
    String? question,
    String? category,
    bool? useAi,
  }) {
    return ReadingDraft(
      question: question ?? this.question,
      category: category ?? this.category,
      useAi: useAi ?? this.useAi,
    );
  }
}
