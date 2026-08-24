import 'package:wallet_test/features/transfers/transfer.dart';
import 'package:wallet_test/features/transfers/transfer_repository.dart';

class InMemoryTransferRepository implements ITransferRepository {
  int applyCalls = 0;
  bool shouldFail = false;

  Transfer? lastTransfer;
  TransferStatus? lastStatus;
  DateTime? lastUpdatedAt;

  @override
  Future<void> applyStatus(
    Transfer transfer,
    TransferStatus status,
    DateTime updatedAt,
  ) async {
    applyCalls++;

    if (shouldFail) {
      throw Exception('db failed');
    }

    lastTransfer = transfer;
    lastStatus = status;
    lastUpdatedAt = updatedAt;
  }
}
