import 'reading.dart';

class ReadingDetail {
  const ReadingDetail({
    required this.reading,
    required this.items,
    required this.divinationCode,
    required this.divinationDisplayName,
    required this.payloads,
  });

  final Reading reading;
  final List<ReadingCard> items;
  final String divinationCode;
  final String divinationDisplayName;
  final List<ReadingPayload> payloads;
}

class ReadingPayload {
  const ReadingPayload({
    required this.payloadType,
    required this.payloadJson,
  });

  final String payloadType;
  final Map<String, dynamic> payloadJson;

  factory ReadingPayload.fromJson(Map<String, dynamic> json) {
    return ReadingPayload(
      payloadType: (json['payload_type'] ?? 'unknown') as String,
      payloadJson: json['payload_json'] is Map<String, dynamic>
          ? json['payload_json'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }
}

class ReadingCard {
  const ReadingCard({
    required this.positionName,
    required this.orientation,
    required this.cardName,
    required this.cardCode,
    this.imageUrl,
  });

  final String positionName;
  final String orientation;
  final String cardName;
  final String cardCode;
  final String? imageUrl;

  factory ReadingCard.fromJson(Map<String, dynamic> json) {
    final item = json['divination_items'] as Map<String, dynamic>?;
    return ReadingCard(
      positionName: (json['position_name'] ?? 'Card') as String,
      orientation: (json['orientation'] ?? 'none') as String,
      cardName: (item?['display_name'] ?? item?['name'] ?? 'Unknown') as String,
      cardCode: (item?['code'] ?? 'unknown') as String,
      imageUrl: item?['image_url'] as String?,
    );
  }
}
