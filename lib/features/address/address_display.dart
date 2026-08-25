String formatAddressForCell(String address, double textScaleFactor) {
  const addressPrefix = '0x';
  final hasPrefix = address.startsWith(addressPrefix);
  final prefix = hasPrefix ? addressPrefix : '';
  final body = hasPrefix ? address.substring(addressPrefix.length) : address;

  if (body.length <= 12) {
    return address;
  }

  final leadingLength = textScaleFactor < 1.6 ? 6 : 4;
  final leading = body.substring(0, leadingLength);
  final trailing = body.substring(body.length - 4);

  return '$prefix$leading…$trailing';
}
