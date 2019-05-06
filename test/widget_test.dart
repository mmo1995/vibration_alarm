
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibration_alarm/main.dart';

void main() {
  testWidgets('Tabs exist in the main view', (WidgetTester tester) async {

    await tester.pumpWidget(MyApp());

    expect(find.text('Wearable Connection'), findsNWidgets(1));

    expect(find.text('Timer'),findsNWidgets(1));

  });
}
