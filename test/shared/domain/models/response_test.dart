import 'package:flutter_clean_arch_unicorn/shared/domain/models/response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Response constructor keeps statusCode, statusMessage and data', () {
    final response = Response(
      statusCode: 200,
      statusMessage: 'OK',
      data: {'id': 1},
    );

    expect(response.statusCode, 200);
    expect(response.statusMessage, 'OK');
    expect(response.data, {'id': 1});
  });

  test('Response defaults data to empty map when omitted', () {
    final response = Response(statusCode: 204);

    expect(response.data, const {});
    expect(response.statusMessage, isNull);
  });

  test('toRight wraps the response for Either-based success handling', () {
    final response = Response(statusCode: 200, data: 'body');

    final right = response.toRight;
    expect(right.isRight(), isTrue);
  });
}
