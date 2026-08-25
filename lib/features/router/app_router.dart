import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:wallet_test/features/auth/auth_repository.dart';
import 'package:wallet_test/features/cards/card_issue_page.dart';
import 'package:wallet_test/features/cards/cards_page.dart';
import 'package:wallet_test/features/onboarding/onboarding_page.dart';
import 'package:wallet_test/features/router/auth_change_notifier.dart';
import 'package:wallet_test/features/router/cards_auth_redirect.dart';
import 'package:wallet_test/features/wallet/wallet_page.dart';

class AppRouter {
  AppRouter() {
    router = GoRouter(
      initialLocation: '/wallet',
      redirect: (context, state) {
        return cardsAuthRedirect(
          state.uri,
          GetIt.instance<IAuthRepository>().isAuthed,
        );
      },
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
    _authChangeNotifier = AuthChangeNotifier(
      auth: GetIt.instance<IAuthRepository>(),
      router: router,
    );
  }

  late final GoRouter router;
  late final AuthChangeNotifier _authChangeNotifier;

  void dispose() {
    _authChangeNotifier.dispose();
    router.dispose();
  }
}
