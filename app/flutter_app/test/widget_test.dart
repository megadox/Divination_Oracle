import 'package:divination_app/src/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Subscription screen renders Plus title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SubscriptionScreen(),
      ),
    );

    expect(find.text('Plus'), findsWidgets);
    expect(find.text('RevenueCat 연동 예정'), findsOneWidget);
  });
}
