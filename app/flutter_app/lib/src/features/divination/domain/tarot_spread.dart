class TarotSpread {
  const TarotSpread({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.allowReversed,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final int cardCount;
  final bool allowReversed;

  factory TarotSpread.fromJson(Map<String, dynamic> json) {
    return TarotSpread(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      cardCount: json['card_count'] as int,
      allowReversed: json['allow_reversed'] as bool? ?? true,
    );
  }
}
