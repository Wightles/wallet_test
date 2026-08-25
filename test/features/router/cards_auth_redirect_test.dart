import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_test/features/router/cards_auth_redirect.dart';

void main() {
  test('redirects an unauthenticated cards deep link to onboarding', () {
    final redirect = cardsAuthRedirect(
      Uri.parse('/cards/card_1/issue?step=2'),
      false,
    );

    expect(
      redirect,
      '/onboarding?next=%2Fcards%2Fcard_1%2Fissue%3Fstep%3D2',
    );
  });

  test('returns an authenticated user to the safe cards deep link', () {
    final redirect = cardsAuthRedirect(
      Uri.parse(
        '/onboarding?next=%2Fcards%2Fcard_1%2Fissue%3Fstep%3D2',
      ),
      true,
    );

    expect(redirect, '/cards/card_1/issue?step=2');
  });

  test('rejects an external next location', () {
    final redirect = cardsAuthRedirect(
      Uri.parse('/onboarding?next=https%3A%2F%2Fevil.com'),
      true,
    );

    expect(redirect, '/cards');
  });

  test('does not loop for an unauthenticated onboarding location', () {
    final redirect = cardsAuthRedirect(
      Uri.parse('/onboarding'),
      false,
    );

    expect(redirect, isNull);
  });

  test('does not redirect an authenticated cards location', () {
    final redirect = cardsAuthRedirect(
      Uri.parse('/cards'),
      true,
    );

    expect(redirect, isNull);
  });

  test('falls back to cards when next is empty', () {
    final redirect = cardsAuthRedirect(
      Uri.parse('/onboarding?next='),
      true,
    );

    expect(redirect, '/cards');
  });
}
