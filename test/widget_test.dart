import 'package:flutter_test/flutter_test.dart';

import 'package:stock_facile/main.dart';

void main() {
  testWidgets('affiche la barre StockFacile', (WidgetTester tester) async {
    await tester.pumpWidget(const StockFacileApp());
    expect(find.text('StockFacile'), findsOneWidget);
  });
}