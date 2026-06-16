class DivinationInputDefinition {
  const DivinationInputDefinition({
    required this.fieldKey,
    required this.fieldLabel,
    required this.fieldType,
    required this.isRequired,
    this.optionsJson,
    this.placeholder,
    this.helpText,
    this.validationJson,
  });

  final String fieldKey;
  final String fieldLabel;
  final String fieldType;
  final bool isRequired;
  final Map<String, dynamic>? optionsJson;
  final String? placeholder;
  final String? helpText;
  final Map<String, dynamic>? validationJson;

  factory DivinationInputDefinition.fromJson(Map<String, dynamic> json) {
    return DivinationInputDefinition(
      fieldKey: (json['field_key'] ?? 'unknown') as String,
      fieldLabel: (json['field_label'] ?? json['field_key'] ?? 'Field') as String,
      fieldType: (json['field_type'] ?? 'text') as String,
      isRequired: (json['is_required'] ?? true) as bool,
      optionsJson: json['options_json'] is Map<String, dynamic>
          ? json['options_json'] as Map<String, dynamic>
          : null,
      placeholder: json['placeholder'] as String?,
      helpText: json['help_text'] as String?,
      validationJson: json['validation_json'] is Map<String, dynamic>
          ? json['validation_json'] as Map<String, dynamic>
          : null,
    );
  }
}
