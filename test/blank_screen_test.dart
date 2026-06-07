import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:academy_pro/main.dart'; // Adjust if package name is different

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // We mock the Firebase init provider so it doesn't try to connect
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseInitializerProvider.overrideWith((ref) async {}),
        ],
        child: const AcademyProApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(true, isTrue);
  });
}
