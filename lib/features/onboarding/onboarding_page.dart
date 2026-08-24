import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:wallet_test/features/auth/auth_repository.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Onboarding'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                GetIt.instance<IAuthRepository>().signIn();
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
