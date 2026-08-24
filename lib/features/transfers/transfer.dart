enum TransferStatus {
  pending,
  confirmed,
  failed,
  unknown;

  factory TransferStatus.fromName(String name) {
    return values.firstWhere(
      (status) => status.name == name,
      orElse: () => TransferStatus.unknown,
    );
  }
}

class Transfer {
  const Transfer({
    required this.id,
    required this.network,
    required this.txHash,
    this.memo,
    this.privateNote,
    this.raw = const {},
  });

  final String id;
  final String network;
  final String txHash;
  final String? memo;
  final String? privateNote;
  final Map<String, dynamic> raw;
}
