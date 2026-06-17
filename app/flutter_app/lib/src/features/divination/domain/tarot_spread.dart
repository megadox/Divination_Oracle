class TarotSpread {
  const TarotSpread({
    required this.code,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.allowReversed,
    this.id,
    this.isPlusOnly = false,
  });

  final String? id;
  final String code;
  final String name;
  final String? description;
  final int cardCount;
  final bool allowReversed;
  final bool isPlusOnly;

  factory TarotSpread.fromJson(Map<String, dynamic> json) {
    return TarotSpread(
      id: json['id'] as String?,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      cardCount: json['card_count'] as int,
      allowReversed: json['allow_reversed'] as bool? ?? true,
      isPlusOnly: json['is_plus_only'] as bool? ?? false,
    );
  }
}
