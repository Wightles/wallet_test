String? cardsAuthRedirect(Uri uri, bool isAuthed) {
  if (!isAuthed) {
    if (_isCardsPath(uri.path)) {
      final next = Uri.encodeComponent(uri.toString());
      return '/onboarding?next=$next';
    }

    return null;
  }

  if (uri.path != '/onboarding') {
    return null;
  }

  try {
    final next = uri.queryParameters['next'];
    if (next == null || next.isEmpty) {
      return '/cards';
    }

    final nextUri = Uri.tryParse(next);
    final isSafe = nextUri != null &&
        nextUri.scheme.isEmpty &&
        !nextUri.hasAuthority &&
        _isCardsPath(nextUri.path);

    return isSafe ? nextUri.toString() : '/cards';
  } on FormatException {
    return '/cards';
  }
}

bool _isCardsPath(String path) {
  return path == '/cards' || path.startsWith('/cards/');
}
