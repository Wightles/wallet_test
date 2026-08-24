import 'package:wallet_test/features/address/address_repository.dart';

class InMemoryAddressRepository implements IAddressRepository {
  int copyCalls = 0;
  bool shouldFail = false;
  String? lastAddress;

  @override
  Future<void> copyAddress(String address) async {
    copyCalls++;
    lastAddress = address;

    await Future<void>.delayed(const Duration(milliseconds: 30));

    if (shouldFail) {
      throw Exception('copy failed');
    }
  }
}
