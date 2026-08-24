String redactIdentifier(String value) {
  if (value.length <= 8) {
    return '****';
  }

  return '${value.substring(0, 4)}…${value.substring(value.length - 4)}';
}
