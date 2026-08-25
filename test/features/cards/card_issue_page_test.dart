import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:wallet_test/core/dev_stubs/dev_card_issuer.dart';
import 'package:wallet_test/features/cards/card_issue_bloc.dart';
import 'package:wallet_test/features/cards/card_issue_page.dart';
import 'package:wallet_test/features/cards/card_issuer.dart';

import '../../helpers/test_get_it.dart';

void main() {
  testWidgets('renders the card issue page', (tester) async {
    await testWithGetIt(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CardIssuePage(cardId: 'card_1'),
        ),
      );

      expect(find.byType(CardIssuePage), findsOneWidget);
      expect(find.text('Issue card'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('uses GetIt dependencies and disposes them exactly once',
      (tester) async {
    await testWithGetIt(() async {
      final issuer = GetIt.instance<ICardIssuer>() as DevCardIssuer;
      await GetIt.instance.unregister<CardIssueBloc>();
      final bloc = _TrackingCardIssueBloc(issuer: issuer);
      GetIt.instance.registerSingleton<CardIssueBloc>(bloc);

      await tester.pumpWidget(
        const MaterialApp(
          home: CardIssuePage(cardId: 'card_1'),
        ),
      );

      expect(GetIt.instance<ICardIssuer>(), same(issuer));
      expect(GetIt.instance<CardIssueBloc>(), same(bloc));

      await tester.pumpWidget(const SizedBox.shrink());

      expect(bloc.closeCalled, isTrue);
      expect(issuer.cancelCalls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(issuer.cancelCalls, 1);
    });
  });
}

class _TrackingCardIssueBloc extends CardIssueBloc {
  _TrackingCardIssueBloc({required super.issuer});

  bool closeCalled = false;

  @override
  Future<void> close() {
    closeCalled = true;
    return super.close();
  }
}
