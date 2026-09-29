import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/app/app.dart';

void main() {
  testWidgets('App renders without crashing and shows empty state',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ReelDeckApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Select a folder to start'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
