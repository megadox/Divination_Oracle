import 'package:divination_app/src/features/divination/data/reading_error_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps daily usage limit error to Korean message', () {
    final message = readingErrorMessage(
      _FakeFunctionException(
        details: {'error': 'Daily usage limit reached.'},
      ),
    );

    expect(message, contains('5회'));
    expect(message, contains('내일'));
  });
}

class _FakeFunctionException implements Exception {
  _FakeFunctionException({required this.details});

  final Map<String, String> details;
  final int status = 400;

  @override
  String toString() => 'FunctionException(status: $status, details: $details)';
}
