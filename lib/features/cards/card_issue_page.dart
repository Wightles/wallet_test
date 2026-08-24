import 'package:flutter/material.dart';

import 'package:wallet_test/core/dev_stubs/dev_card_issuer.dart';
import 'package:wallet_test/features/cards/card_issue_bloc.dart';
import 'package:wallet_test/features/cards/card_issuer.dart';

class CardIssuePage extends StatefulWidget {
  const CardIssuePage({
    super.key,
    required this.cardId,
  });

  final String cardId;

  @override
  State<CardIssuePage> createState() => _CardIssuePageState();
}

class _CardIssuePageState extends State<CardIssuePage> {
  final DevCardIssuer _issuer = DevCardIssuer();
  late final CardIssueBloc _bloc = CardIssueBloc(issuer: _issuer);

  @override
  void dispose() {
    _issuer.cancelPending();
    super.dispose();
  }

  Future<void> _issue() async {
    await _bloc.add(
      IssueTapped(
        CardIssueRequest(cardId: widget.cardId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _issue,
          child: const Text('Issue card'),
        ),
      ),
    );
  }
}
