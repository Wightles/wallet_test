import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
  late final ICardIssuer _issuer = GetIt.instance<ICardIssuer>();
  late final CardIssueBloc _bloc = GetIt.instance<CardIssueBloc>();

  bool _cancelRequested = false;

  void _cancelOnce() {
    if (_cancelRequested) {
      return;
    }

    _cancelRequested = true;
    _issuer.cancelPending();
  }

  @override
  void dispose() {
    _cancelOnce();
    _bloc.close();
    super.dispose();
  }

  void _issue() {
    _bloc.add(
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
