import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_v2/main.dart'; // adjust path if needed

void main() {
  testWidgets('App launches and shows HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(FinanceTrackerApp());

    expect(find.text('Personal Finance Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); // FAB icon
  });
}
