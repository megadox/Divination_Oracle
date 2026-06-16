import '../config/app_config.dart';

/// Server-side limits in `create-free-reading` / `create-ai-reading`.
abstract final class UsageLimits {
  static const int freeDailyReadingLimit = 5;
  static const int aiDailyReadingLimit = 30;

  static bool get isFreeReadingLimitEnabled => !AppConfig.disableFreeReadingLimit;
}
