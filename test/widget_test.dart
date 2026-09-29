import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/app/app.dart';

void main() {
  testWidgets('ReelDeckApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ReelDeckApp());
    expect(find.byType(ReelDeckApp), findsOneWidget);
  });
}
