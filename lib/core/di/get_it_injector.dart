import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:wallet_test/core/dev_stubs/dev_auth_repository.dart';
import 'package:wallet_test/core/dev_stubs/dev_card_issuer.dart';
import 'package:wallet_test/core/dev_stubs/in_memory_address_repository.dart';
import 'package:wallet_test/core/dev_stubs/in_memory_transfer_repository.dart';
import 'package:wallet_test/core/network/api_client.dart';
import 'package:wallet_test/features/address/address_repository.dart';
import 'package:wallet_test/features/address/address_tile_bloc.dart';
import 'package:wallet_test/features/auth/auth_repository.dart';
import 'package:wallet_test/features/cards/card_issue_bloc.dart';
import 'package:wallet_test/features/cards/card_issuer.dart';
import 'package:wallet_test/features/router/app_router.dart';
import 'package:wallet_test/features/transfers/transfer_repository.dart';
import 'package:wallet_test/features/transfers/transfer_status_sync_service.dart';

final GetIt sl = GetIt.instance;

void registerAppDependencies() {
  sl.allowFactoryRetrieval = true;

  if (!sl.isRegistered<IAuthRepository>()) {
    sl.registerLazySingleton<IAuthRepository>(
      () => DevAuthRepository(),
    );
  }

  if (!sl.isRegistered<IAddressRepository>()) {
    sl.registerLazySingleton<IAddressRepository>(
      () => InMemoryAddressRepository(),
    );
  }

  if (!sl.isRegistered<ITransferRepository>()) {
    sl.registerLazySingleton<ITransferRepository>(
      () => InMemoryTransferRepository(),
    );
  }

  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(
        dio: Dio(
          BaseOptions(
            baseUrl: 'https://api.wallet.test/',
          ),
        ),
      ),
    );
  }

  if (!sl.isRegistered<ICardIssuer>()) {
    sl.registerLazySingleton<ICardIssuer>(
      () => DevCardIssuer(),
    );
  }

  if (!sl.isRegistered<TransferStatusSyncService>()) {
    sl.registerFactory<TransferStatusSyncService>(
      () => TransferStatusSyncService(
        api: sl<ApiClient>(),
        repository: sl<ITransferRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<AddressTileBloc>()) {
    sl.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(
        repository: sl<IAddressRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<CardIssueBloc>()) {
    sl.registerFactory<CardIssueBloc>(
      () => CardIssueBloc(
        issuer: sl<ICardIssuer>(),
      ),
    );
  }

  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton<AppRouter>(
      () => AppRouter(),
    );
  }
}
