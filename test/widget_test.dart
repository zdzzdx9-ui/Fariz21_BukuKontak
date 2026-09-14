import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:kontak_form/main.dart';

void main() {
  testWidgets('Buku Kontak app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BukuKontakApp());

    expect(find.text('BUKU KONTAK'), findsOneWidget);

    expect(find.text('Kontak'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);

    expect(find.text('Belum ada kontak'), findsOneWidget);

    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kontak favorit'), findsOneWidget);
  });

  testWidgets('Kontak dapat diedit dan dihapus dengan konfirmasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BukuKontakApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'budi@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '081234567890');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
    expect(find.byTooltip('Edit kontak'), findsOneWidget);
    expect(find.byTooltip('Hapus kontak'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit kontak'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Kontak'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Siti');
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Budi'), findsNothing);

    await tester.tap(find.byTooltip('Hapus kontak'));
    await tester.pumpAndSettle();
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Siti'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus kontak'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Siti'), findsNothing);
    expect(find.text('Belum ada kontak'), findsOneWidget);
  });
}
