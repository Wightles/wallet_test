import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_test/features/address/address_display.dart';

void main() {
  const longAddress = '0x1234567890abcdef1234567890abcdef12345678';

  test('keeps a short address unchanged', () {
    expect(formatAddressForCell('0x1234', 2), '0x1234');
  });

  test('formats a long 0x address as six plus four at normal scale', () {
    expect(
      formatAddressForCell(longAddress, 1),
      '0x123456…5678',
    );
  });

  test('formats a long address as four plus four at large scale', () {
    expect(
      formatAddressForCell(longAddress, 2),
      '0x1234…5678',
    );
  });

  test('formats a long address without a 0x prefix', () {
    expect(
      formatAddressForCell('1234567890abcdef12345678', 1),
      '123456…5678',
    );
  });

  test('preserves the 0x prefix when shortening', () {
    final formatted = formatAddressForCell(longAddress, 1.6);

    expect(formatted, startsWith('0x'));
    expect(formatted, '0x1234…5678');
  });
}
