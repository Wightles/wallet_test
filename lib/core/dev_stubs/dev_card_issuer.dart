import 'dart:async';

import 'package:wallet_test/core/errors/app_exception.dart';
import 'package:wallet_test/features/cards/card_issuer.dart';

class DevCardIssuer implements ICardIssuer {
  int cancelCalls = 0;
  bool issueShouldFail = false;
  bool _cancelled = false;

  @override
  Future<void> issue(CardIssueRequest request) async {
    _cancelled = false;

    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (_cancelled) {
      throw const CancelException();
    }

    if (issueShouldFail) {
      throw Exception('issue failed');
    }
  }

  @override
  void cancelPending() {
    cancelCalls++;
    _cancelled = true;
  }
}
