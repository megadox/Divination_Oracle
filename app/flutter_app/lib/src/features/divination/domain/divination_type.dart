class DivinationType {
  const DivinationType({
    required this.id,
    required this.code,
    required this.name,
    required this.displayName,
    required this.inputMode,
    required this.interpretationMode,
    required this.isPlusOnly,
    this.shortDescription,
    this.description,
    this.originRegion,
    this.iconKey,
  });

  final String id;
  final String code;
  final String name;
  final String displayName;
  final String inputMode;
  final String interpretationMode;
  final bool isPlusOnly;
  final String? shortDescription;
  final String? description;
  final String? originRegion;
  final String? iconKey;

  bool get isDrawBased => inputMode == 'draw_based';
  bool get isBirthDataBased => inputMode == 'birth_data_based';

  factory DivinationType.fromJson(Map<String, dynamic> json) {
    return DivinationType(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      displayName: (json['display_name'] ?? json['name']) as String,
      inputMode: (json['input_mode'] ?? 'draw_based') as String,
      interpretationMode:
          (json['interpretation_mode'] ?? 'prewritten_lookup') as String,
      isPlusOnly: (json['is_plus_only'] ?? false) as bool,
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      originRegion: json['origin_region'] as String?,
      iconKey: json['icon_key'] as String?,
    );
  }
}
