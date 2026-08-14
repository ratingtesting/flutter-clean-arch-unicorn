import 'package:flutter_clean_arch_unicorn/shared/domain/models/paginated_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/dashboard/dummy_productlist.dart';

void main() {
  test('PaginatedResponse.fromJson reads total and skip from map', () {
    final json = {'total': 100, 'skip': 40};

    final result = PaginatedResponse.fromJson(json, ktestProductList);

    expect(result.total, 100);
    expect(result.skip, 40);
    expect(result.data, ktestProductList);
  });

  test('PaginatedResponse.fromJson falls back to 0 on missing keys', () {
    final json = <String, dynamic>{};

    final result = PaginatedResponse.fromJson(json, ktestProductList);

    expect(result.total, 0);
    expect(result.skip, 0);
  });

  test('PaginatedResponse exposes PER_PAGE_LIMIT', () {
    expect(PaginatedResponse.limit, 20);
  });
}
