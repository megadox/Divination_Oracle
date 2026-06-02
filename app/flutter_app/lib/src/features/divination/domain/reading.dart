class Reading {
  const Reading({
    required this.id,
    required this.resultType,
    required this.resultText,
    required this.createdAt,
    this.question,
  });

  final String id;
  final String resultType;
  final String? resultText;
  final DateTime createdAt;
  final String? question;

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] as String,
      resultType: json['result_type'] as String,
      resultText: json['result_text'] as String?,
      question: json['question'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
