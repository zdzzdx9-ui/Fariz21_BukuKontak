import 'package:flutter_test/flutter_test.dart';

import 'package:kontak_form/main.dart';

void main() {
  testWidgets('Buku Kontak app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BukuKontakApp());

    // Verify app title exists
    expect(find.text('BUKU KONTAK'), findsOneWidget);

    // Verify tabs exist
    expect(find.text('Kontak'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);

    // Verify initial empty state text
    expect(find.text('Belum ada kontak'), findsOneWidget);

    // Tap on Favorit tab
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();

    // Verify empty state text for Favorit
    expect(find.text('Belum ada kontak favorit'), findsOneWidget);
  });
}

