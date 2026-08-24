class CardIssueRequest {
  const CardIssueRequest({
    required this.cardId,
    this.payload = const {},
  });

  final String cardId;
  final Map<String, dynamic> payload;
}

abstract class ICardIssuer {
  Future<void> issue(CardIssueRequest request);
  void cancelPending();
}
