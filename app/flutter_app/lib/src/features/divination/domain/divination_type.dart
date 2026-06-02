class DivinationType {
  const DivinationType({
    required this.id,
    required this.code,
    required this.name,
    required this.displayName,
    required this.isPlusOnly,
  });

  final String id;
  final String code;
  final String name;
  final String displayName;
  final bool isPlusOnly;

  factory DivinationType.fromJson(Map<String, dynamic> json) {
    return DivinationType(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      displayName: (json['display_name'] ?? json['name']) as String,
      isPlusOnly: (json['is_plus_only'] ?? false) as bool,
    );
  }
}
