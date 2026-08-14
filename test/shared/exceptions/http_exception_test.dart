import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppException stores message, statusCode and identifier', () {
    final exception = AppException(
      message: 'boom',
      statusCode: 404,
      identifier: 'user_repo',
    );

    expect(exception.message, 'boom');
    expect(exception.statusCode, 404);
    expect(exception.identifier, 'user_repo');
  });

  test('CacheFailureException exposes fixed failure fields', () {
    final exception = CacheFailureException();

    expect(exception.statusCode, 100);
    expect(exception.message, 'Unable to save user');
    expect(exception.identifier, 'Cache failure exception');
  });

  test('toLeft wraps the exception for Either-based error handling', () {
    final exception = AppException(
      message: 'x',
      statusCode: 1,
      identifier: 'y',
    );

    final left = exception.toLeft;
    expect(left.isLeft(), isTrue);
  });
}
