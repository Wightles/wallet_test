import 'package:dio/dio.dart';

import 'package:wallet_test/core/network/api_client.dart';
import 'package:wallet_test/features/transfers/transfer.dart';
import 'package:wallet_test/features/transfers/transfer_repository.dart';

class TransferStatusSyncService {
  TransferStatusSyncService({
    required ApiClient api,
    required ITransferRepository repository,
  })  : _api = api,
        _repository = repository;

  final ApiClient _api;
  final ITransferRepository _repository;

  Future<TransferStatus> sync(
    Transfer transfer, {
    CancelToken? cancelToken,
  }) async {
    final response = await _api.dio.get(
      '/v1/transfers/${transfer.txHash}/status',
      cancelToken: cancelToken,
    );

    print(response.data);

    final status = TransferStatus.fromName(
      response.data['status'] as String? ?? 'unknown',
    );

    await _repository.applyStatus(
      transfer,
      status,
      DateTime.now(),
    );

    return status;
  }
}
