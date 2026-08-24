import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:wallet_test/core/di/get_it_injector.dart';
import 'package:wallet_test/features/router/app_router.dart';

void main() {
  registerAppDependencies();
  runApp(const WalletApp());
}

class WalletApp extends StatelessWidget {
  const WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = GetIt.instance<AppRouter>();

    return MaterialApp.router(
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
