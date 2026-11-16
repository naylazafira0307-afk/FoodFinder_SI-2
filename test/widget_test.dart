import 'package:flutter_test/flutter_test.dart';
import 'package:foodfinder/jam.dart';

void main() {
  test('Jam buka 24 jam terbaca buka', () {
    final j = parseJam('Buka 24 jam');
    expect(statusBuka(j, 0, 600).buka, true);
  });

  test('Jam tidak tersedia', () {
    expect(statusBuka(parseJam('-'), 0, 600).kode, 'tidak-ada');
  });
}