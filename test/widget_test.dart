import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_flow/main.dart';

void main() {
  testWidgets('App should load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Hive initialization is async and might need mocking for full tests,
    // but for this simple check we just verify the app can be pumped.
    await tester.pumpWidget(const FreelanceFlowApp());
    expect(find.byType(FreelanceFlowApp), findsOneWidget);
  });
}
