import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('App loads and shows Any Image View title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Verify the app bar title is present
    expect(find.text('Any Image View - Advanced Features'), findsOneWidget);
  });

  testWidgets('Image gallery screen has photo library action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Verify the photo library IconButton exists (pick image from gallery)
    expect(find.byIcon(Icons.photo_library), findsOneWidget);
  });
}
