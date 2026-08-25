import 'package:dio/dio.dart';

import 'package:wallet_test/core/errors/app_exception.dart';
import 'package:wallet_test/core/network/api_client.dart';
import 'package:wallet_test/features/transfers/transfer.dart';
import 'package:wallet_test/features/transfers/transfer_repository.dart';

class TransferStatusSyncService {
  TransferStatusSyncService({
    required ApiClient api,
    required ITransferRepository repository,
  })  : _api = api,
        _repository = repository;

  static const int _maxAttempts = 3;
  static const List<Duration> _retryDelays = [
    Duration(milliseconds: 200),
    Duration(milliseconds: 500),
  ];

  final ApiClient _api;
  final ITransferRepository _repository;

  Future<TransferStatus> sync(
    Transfer transfer, {
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> response;

    try {
      response = await _requestStatus(
        transfer,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw const CancelException();
      }

      throw TransferSyncException(
        code: _mapErrorCode(error),
      );
    }

    final data = response.data;
    final rawStatus = data is Map<String, dynamic> ? data['status'] : null;
    final status = TransferStatus.fromName(
      rawStatus is String ? rawStatus : 'unknown',
    );

    try {
      await _repository.applyStatus(
        transfer,
        status,
        DateTime.now(),
      );
    } catch (_) {
      throw const TransferSyncException(
        code: 'localPersistenceFailed',
      );
    }

    return status;
  }

  Future<Response<dynamic>> _requestStatus(
    Transfer transfer, {
    CancelToken? cancelToken,
  }) async {
    var attempt = 0;

    while (true) {
      attempt++;

      try {
        return await _api.dio.get(
          '/v1/transfers/${transfer.txHash}/status',
          cancelToken: cancelToken,
          options: Options(
            headers: {
              'Idempotency-Key':
                  '${transfer.network.toLowerCase()}:${transfer.txHash}',
            },
          ),
        );
      } on DioException catch (error) {
        if (!_isRetryable(error) || attempt >= _maxAttempts) {
          rethrow;
        }

        await _waitBeforeRetry(
          _retryDelays[attempt - 1],
          cancelToken,
        );
      }
    }
  }

  bool _isRetryable(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return statusCode == 408 || statusCode == 429 || statusCode == 503;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        return false;
    }
  }

  Future<void> _waitBeforeRetry(
    Duration delay,
    CancelToken? cancelToken,
  ) async {
    if (cancelToken == null) {
      await Future<void>.delayed(delay);
      return;
    }

    final existingCancelError = cancelToken.cancelError;
    if (existingCancelError != null) {
      throw existingCancelError;
    }

    final wasCancelled = await Future.any<bool>([
      Future<bool>.delayed(delay, () => false),
      cancelToken.whenCancel.then((_) => true),
    ]);

    if (wasCancelled) {
      throw cancelToken.cancelError!;
    }
  }

  String _mapErrorCode(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        return 'unauthorized';
      case 404:
        return 'notFound';
      case 409:
        return 'conflict';
      case 408:
      case 429:
        return 'rateLimited';
      case 503:
        return 'serverUnavailable';
      case 500:
        return 'internal';
    }

    return 'network';
  }
}
