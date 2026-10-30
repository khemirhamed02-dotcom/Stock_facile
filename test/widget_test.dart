import 'package:flutter_test/flutter_test.dart';

import 'package:stock_facile/main.dart';

void main() {
  testWidgets('affiche le banc d\'essai', (WidgetTester tester) async {
    await tester.pumpWidget(const StockFacileApp());
    expect(find.text("Banc d'essai"), findsOneWidget);
    expect(find.text('Ouvrir la base'), findsOneWidget);
  });
}