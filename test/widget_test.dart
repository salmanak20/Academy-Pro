import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:academy_pro/main.dart';

void main() {
  testWidgets('App starts with Login Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AcademyProApp()));
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed
    expect(find.text('Academy Pro'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
  });
}
