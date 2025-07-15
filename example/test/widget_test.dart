import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Pick Image button is present and tappable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Verify the Pick Image button exists
    expect(find.text('Pick Image'), findsOneWidget);

    // Tap the Pick Image button
    await tester.tap(find.text('Pick Image'));
    await tester.pump();

    // You can add more expectations here if you mock image picking
  });
}
