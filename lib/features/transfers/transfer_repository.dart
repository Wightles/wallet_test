import 'package:wallet_test/features/transfers/transfer.dart';

abstract class ITransferRepository {
  Future<void> applyStatus(
    Transfer transfer,
    TransferStatus status,
    DateTime updatedAt,
  );
}
