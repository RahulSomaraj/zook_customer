// Smoke test for the Zook splash screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zook_customer_app/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('Splash shows brand wordmark', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashPage()),
    );
    await tester.pump();

    expect(find.text('ZOOK'), findsOneWidget);
    expect(find.text("UAE's trusted secondhand marketplace"), findsOneWidget);
  });
}
