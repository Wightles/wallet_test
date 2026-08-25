import 'package:get_it/get_it.dart';

import 'package:wallet_test/core/di/get_it_injector.dart';

Future<T> testWithGetIt<T>(Future<T> Function() body) async {
  final local = GetIt.instance;

  await local.reset();
  registerAppDependencies();

  try {
    return await body();
  } finally {
    await local.reset();
  }
}
