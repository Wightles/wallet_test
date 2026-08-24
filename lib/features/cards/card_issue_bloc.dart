import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_test/features/cards/card_issuer.dart';

class CardIssueEvent {}

class IssueTapped extends CardIssueEvent {
  IssueTapped(this.request);

  final CardIssueRequest request;
}

class CardIssueState {
  const CardIssueState({
    this.issuing = false,
    this.error,
  });

  final bool issuing;
  final String? error;
}

class CardIssueBloc extends Bloc<CardIssueEvent, CardIssueState> {
  CardIssueBloc({
    required ICardIssuer issuer,
  }) : _issuer = issuer {
    on<IssueTapped>(_onIssueTapped);
  }

  final ICardIssuer _issuer;

  Future<void> _onIssueTapped(
    IssueTapped event,
    Emitter<CardIssueState> emit,
  ) async {
    emit(const CardIssueState(issuing: true));

    try {
      await _issuer.issue(event.request);
      emit(const CardIssueState());
    } catch (_) {
      emit(const CardIssueState(error: 'issue_failed'));
    }
  }
}
