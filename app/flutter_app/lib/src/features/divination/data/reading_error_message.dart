import '../../../core/constants/usage_limits.dart';

String dailyLimitReachedMessage() => _dailyLimitMessage();

String readingErrorMessage(Object error) {
  final serverError = _extractServerError(error);
  if (serverError == 'Daily usage limit reached.') {
    return _dailyLimitMessage();
  }
  if (serverError == 'Plus subscription is required.') {
    return 'Plus 구독이 필요한 기능입니다.';
  }
  if (serverError != null && serverError.isNotEmpty) {
    return serverError;
  }

  final text = error.toString();
  if (text.contains('Daily usage limit reached')) {
    return _dailyLimitMessage();
  }

  return '해석을 생성하지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

String? _extractServerError(Object error) {
  try {
    final dynamic exception = error;
    final details = exception.details;
    if (details is Map) {
      final serverError = details['error'];
      if (serverError is String) {
        return serverError;
      }
    }
  } on Object {
    return null;
  }
  return null;
}

String _dailyLimitMessage() {
  return '오늘 무료 해석 ${UsageLimits.freeDailyReadingLimit}회를 모두 사용했습니다. '
      '내일 다시 이용해 주세요.';
}
