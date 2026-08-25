import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:wallet_test/core/dev_stubs/in_memory_address_repository.dart';
import 'package:wallet_test/features/address/address_tile.dart';
import 'package:wallet_test/features/address/address_tile_bloc.dart';

void main() {
  const address = '0x1234567890abcdef1234567890abcdef12345678';

  setUp(() async {
    await GetIt.instance.reset();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('renders the network and formatted address', (tester) async {
    final repository = InMemoryAddressRepository();
    GetIt.instance.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(repository: repository),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AddressTile(
          address: address,
          network: 'Ethereum',
        ),
      ),
    );

    expect(find.byType(AddressTile), findsOneWidget);
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('0x123456…5678'), findsOneWidget);
  });

  testWidgets('does not overflow at text scale factor 2', (tester) async {
    final repository = InMemoryAddressRepository();
    GetIt.instance.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(repository: repository),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: AddressTile(
            address: address,
            network: 'Ethereum',
          ),
        ),
      ),
    );

    expect(find.text('0x1234…5678'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('copies the full address when the button is tapped',
      (tester) async {
    final repository = InMemoryAddressRepository();
    GetIt.instance.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(repository: repository),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AddressTile(
          address: address,
          network: 'Ethereum',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump();

    expect(repository.copyCalls, 1);
    expect(repository.lastAddress, address);
  });

  testWidgets('shows the copied state after a successful copy', (tester) async {
    final repository = InMemoryAddressRepository();
    GetIt.instance.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(repository: repository),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AddressTile(
          address: address,
          network: 'Ethereum',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsNothing);
  });

  testWidgets('shows the error state when copying fails', (tester) async {
    final repository = InMemoryAddressRepository()..shouldFail = true;
    GetIt.instance.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(repository: repository),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AddressTile(
          address: address,
          network: 'Ethereum',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('resets the copied state after 1500ms', (tester) async {
    final repository = InMemoryAddressRepository();
    GetIt.instance.registerFactory<AddressTileBloc>(
      () => AddressTileBloc(repository: repository),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: AddressTile(
          address: address,
          network: 'Ethereum',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();

    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('closes the bloc when the tile is disposed', (tester) async {
    final repository = InMemoryAddressRepository();
    late _TrackingAddressTileBloc createdBloc;
    GetIt.instance.registerFactory<AddressTileBloc>(() {
      createdBloc = _TrackingAddressTileBloc(repository: repository);
      return createdBloc;
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: AddressTile(
          address: address,
          network: 'Ethereum',
        ),
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());

    expect(createdBloc.closeCalled, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _TrackingAddressTileBloc extends AddressTileBloc {
  _TrackingAddressTileBloc({required super.repository});

  bool closeCalled = false;

  @override
  Future<void> close() {
    closeCalled = true;
    return super.close();
  }
}
