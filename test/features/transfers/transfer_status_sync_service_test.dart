import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_test/core/dev_stubs/in_memory_transfer_repository.dart';
import 'package:wallet_test/core/errors/app_exception.dart';
import 'package:wallet_test/core/network/api_client.dart';
import 'package:wallet_test/features/transfers/transfer.dart';
import 'package:wallet_test/features/transfers/transfer_status_sync_service.dart';

import '../../fakes/fake_http_client_adapter.dart';

void main() {
  const transfer = Transfer(
    id: 'transfer-42',
    network: 'EtHeReUm',
    txHash: '0xAbCd',
  );

  test('retries 429 once and persists the successful result', () async {
    final fixture = _createFixture([
      HttpOutcome(429),
      HttpOutcome(200, body: {'status': 'confirmed'}),
    ]);
    addTearDown(fixture.dio.close);
    final stopwatch = Stopwatch()..start();

    final status = await fixture.service.sync(transfer);

    stopwatch.stop();
    expect(status, TransferStatus.confirmed);
    expect(fixture.adapter.calls, hasLength(2));
    expect(fixture.repository.applyCalls, 1);
    expect(fixture.repository.lastStatus, TransferStatus.confirmed);
    expect(
      stopwatch.elapsed,
      greaterThanOrEqualTo(const Duration(milliseconds: 200)),
    );
  });

  test('maps 401 to unauthorized without retrying or persisting', () async {
    final fixture = _createFixture([
      HttpOutcome(401),
      HttpOutcome(200, body: {'status': 'confirmed'}),
    ]);
    addTearDown(fixture.dio.close);

    await expectLater(
      fixture.service.sync(transfer),
      throwsA(_transferSyncCode('unauthorized')),
    );

    expect(fixture.adapter.calls, hasLength(1));
    expect(fixture.repository.applyCalls, 0);
  });

  test('maps 500 to internal without retrying or persisting', () async {
    final fixture = _createFixture([
      HttpOutcome(500),
      HttpOutcome(200, body: {'status': 'confirmed'}),
    ]);
    addTearDown(fixture.dio.close);

    await expectLater(
      fixture.service.sync(transfer),
      throwsA(_transferSyncCode('internal')),
    );

    expect(fixture.adapter.calls, hasLength(1));
    expect(fixture.repository.applyCalls, 0);
  });

  test('stops after three 429 responses and maps rateLimited', () async {
    final fixture = _createFixture([
      HttpOutcome(429),
      HttpOutcome(429),
      HttpOutcome(429),
      HttpOutcome(200, body: {'status': 'confirmed'}),
    ]);
    addTearDown(fixture.dio.close);
    final stopwatch = Stopwatch()..start();

    await expectLater(
      fixture.service.sync(transfer),
      throwsA(_transferSyncCode('rateLimited')),
    );

    stopwatch.stop();
    expect(fixture.adapter.calls, hasLength(3));
    expect(fixture.repository.applyCalls, 0);
    expect(
      stopwatch.elapsed,
      greaterThanOrEqualTo(const Duration(milliseconds: 700)),
    );
  });

  test('maps a local database failure to localPersistenceFailed', () async {
    final fixture = _createFixture(
      [
        HttpOutcome(200, body: {'status': 'confirmed'})
      ],
      repositoryShouldFail: true,
    );
    addTearDown(fixture.dio.close);

    await expectLater(
      fixture.service.sync(transfer),
      throwsA(_transferSyncCode('localPersistenceFailed')),
    );

    expect(fixture.adapter.calls, hasLength(1));
    expect(fixture.repository.applyCalls, 1);
  });

  test('sends a stable lowercase-network idempotency key', () async {
    final fixture = _createFixture([
      HttpOutcome(429),
      HttpOutcome(200, body: {'status': 'confirmed'}),
    ]);
    addTearDown(fixture.dio.close);

    await fixture.service.sync(transfer);

    expect(
      fixture.adapter.calls.map(
        (call) => call.headers['Idempotency-Key'],
      ),
      everyElement('ethereum:0xAbCd'),
    );
  });

  for (final errorCase in const [
    (status: 404, code: 'notFound'),
    (status: 409, code: 'conflict'),
  ]) {
    test('maps ${errorCase.status} to ${errorCase.code}', () async {
      final fixture = _createFixture([HttpOutcome(errorCase.status)]);
      addTearDown(fixture.dio.close);

      await expectLater(
        fixture.service.sync(transfer),
        throwsA(_transferSyncCode(errorCase.code)),
      );

      expect(fixture.adapter.calls, hasLength(1));
      expect(fixture.repository.applyCalls, 0);
    });
  }

  test('retries 503 three times and maps serverUnavailable', () async {
    final fixture = _createFixture([
      HttpOutcome(503),
      HttpOutcome(503),
      HttpOutcome(503),
    ]);
    addTearDown(fixture.dio.close);

    await expectLater(
      fixture.service.sync(transfer),
      throwsA(_transferSyncCode('serverUnavailable')),
    );

    expect(fixture.adapter.calls, hasLength(3));
    expect(fixture.repository.applyCalls, 0);
  });

  test('maps an exhausted connection retry to network', () async {
    final fixture = _createFixture([
      HttpOutcome(0, errorType: DioExceptionType.connectionError),
      HttpOutcome(0, errorType: DioExceptionType.connectionError),
      HttpOutcome(0, errorType: DioExceptionType.connectionError),
    ]);
    addTearDown(fixture.dio.close);

    await expectLater(
      fixture.service.sync(transfer),
      throwsA(_transferSyncCode('network')),
    );

    expect(fixture.adapter.calls, hasLength(3));
    expect(fixture.repository.applyCalls, 0);
  });

  test('cancels an in-flight request without retrying or persisting', () async {
    final fixture = _createFixture([
      HttpOutcome(
        200,
        body: {'status': 'confirmed'},
        delay: const Duration(seconds: 1),
      ),
    ]);
    addTearDown(fixture.dio.close);
    final cancelToken = CancelToken();

    final syncFuture = fixture.service.sync(
      transfer,
      cancelToken: cancelToken,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(fixture.adapter.calls, hasLength(1));

    cancelToken.cancel('test cancellation');

    await expectLater(
      syncFuture,
      throwsA(isA<CancelException>()),
    );
    expect(fixture.adapter.calls, hasLength(1));
    expect(fixture.repository.applyCalls, 0);
  });
}

({
  Dio dio,
  FakeHttpClientAdapter adapter,
  InMemoryTransferRepository repository,
  TransferStatusSyncService service,
}) _createFixture(
  List<HttpOutcome> outcomes, {
  bool repositoryShouldFail = false,
}) {
  final adapter = FakeHttpClientAdapter(outcomes);
  final dio = Dio(
    BaseOptions(baseUrl: 'https://api.wallet.test/'),
  )..httpClientAdapter = adapter;
  final repository = InMemoryTransferRepository()
    ..shouldFail = repositoryShouldFail;
  final service = TransferStatusSyncService(
    api: ApiClient(dio: dio),
    repository: repository,
  );

  return (
    dio: dio,
    adapter: adapter,
    repository: repository,
    service: service,
  );
}

Matcher _transferSyncCode(String code) {
  return isA<TransferSyncException>().having(
    (error) => error.code,
    'code',
    code,
  );
}
