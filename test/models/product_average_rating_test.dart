import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/product_model.dart';

/// A FRACTIONAL AVERAGE RATING MUST NOT TAKE THE CATALOGUE DOWN.
/// =================================================================================================
///
/// `products.average_rating` is a **double(8,2)** in the host schema
/// (`2023_12_26_092822_create_products_table.php:48`), so the API sends values like `4.5`.
/// `ProductData.fromJson` cast it with `as int?`, and in Dart `4.5 as int?` THROWS.
///
/// That constructor parses the product **list** as well as the detail screen, so a single
/// fractionally-rated product could fail the whole catalogue response. It survived because a
/// WHOLE rating decodes as `int` and casts fine — a store with no reviews, or only whole averages,
/// never sees it, which is exactly why a fixture with `4.5` in it was what found the defect.
///
/// The payload is round-tripped through `jsonDecode` rather than written as a Dart map, because
/// that is what decides whether `4.5` arrives as `double` and `4` as `int` — writing the map by
/// hand would let the test pass against types the network never produces.
void main() {
  Map<String, dynamic> decoded(Object rating) =>
      jsonDecode(jsonEncode({'id': 41, 'name': 'Aleppo Laurel Soap', 'average_rating': rating}))
          as Map<String, dynamic>;

  test('a fractional average rating parses', () {
    final product = ProductData.fromJson(decoded(4.5));

    expect(product.averageRating, 4.5,
        reason: 'a 4.5-star product did not parse, so the catalogue response that contains it '
            'cannot be read.');
    expect(product.averageRating?.toDouble(), 4.5,
        reason: 'products_screen.dart:722 calls .toDouble() on this; it must still work');
  });

  test('a whole average rating still parses, and is still a number', () {
    final product = ProductData.fromJson(decoded(4));

    expect(product.averageRating, 4);
    expect(product.averageRating?.toDouble(), 4.0);
  });

  test('an unrated product parses as zero rather than throwing', () {
    expect(ProductData.fromJson(decoded(0)).averageRating, 0);
  });

  test('a missing rating is null, not an error', () {
    final product = ProductData.fromJson(
        jsonDecode(jsonEncode({'id': 41, 'name': 'x'})) as Map<String, dynamic>);

    expect(product.averageRating, isNull);
    // And the consumer's fallback still produces a number.
    expect(product.averageRating?.toDouble() ?? 0.0, 0.0);
  });

  /// ANTI-VACUITY. If the field ever goes back to `int?` the first case fails — but only if the
  /// value is really fractional, so this asserts the fixture itself is the shape that matters.
  test('premise: 4.5 really decodes as a double, not an int', () {
    expect(decoded(4.5)['average_rating'], isA<double>());
    expect(decoded(4)['average_rating'], isA<int>());
  });
}
