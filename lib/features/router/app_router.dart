import 'package:go_router/go_router.dart';

import 'package:wallet_test/features/cards/card_issue_page.dart';
import 'package:wallet_test/features/cards/cards_page.dart';
import 'package:wallet_test/features/onboarding/onboarding_page.dart';
import 'package:wallet_test/features/wallet/wallet_page.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/wallet',
    routes: [
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/cards',
        builder: (context, state) => const CardsPage(),
      ),
      GoRoute(
        path: '/cards/:id/issue',
        builder: (context, state) {
          return CardIssuePage(
            cardId: state.pathParameters['id']!,
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );
}
