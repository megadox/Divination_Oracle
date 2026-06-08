import '../../../core/constants/usage_limits.dart';

class DailyUsage {
  const DailyUsage({
    required this.freeReadingCount,
    required this.aiReadingCount,
  });

  final int freeReadingCount;
  final int aiReadingCount;

  int get remainingFreeReadings =>
      (UsageLimits.freeDailyReadingLimit - freeReadingCount)
          .clamp(0, UsageLimits.freeDailyReadingLimit);

  bool get isFreeLimitReached =>
      freeReadingCount >= UsageLimits.freeDailyReadingLimit;

  factory DailyUsage.fromJson(Map<String, dynamic> json) {
    return DailyUsage(
      freeReadingCount: (json['free_reading_count'] as num?)?.toInt() ?? 0,
      aiReadingCount: (json['ai_reading_count'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = DailyUsage(freeReadingCount: 0, aiReadingCount: 0);
}
