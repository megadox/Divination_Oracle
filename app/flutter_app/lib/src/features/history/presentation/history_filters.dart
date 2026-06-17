class ReadingHistoryFilters {
  const ReadingHistoryFilters({
    this.divinationCode,
    this.resultType,
  });

  final String? divinationCode;
  final String? resultType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ReadingHistoryFilters &&
        other.divinationCode == divinationCode &&
        other.resultType == resultType;
  }

  @override
  int get hashCode => Object.hash(divinationCode, resultType);
}
