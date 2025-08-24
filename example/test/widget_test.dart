import 'package:cristalyse_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CristalyseExampleApp Tests', () {
    testWidgets('App should start and display main title',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CristalyseExampleApp());
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('🔮 Cristalyse'), findsOneWidget);
      expect(find.text('Grammar of Graphics for Flutter'), findsOneWidget);
    });

    testWidgets('TabBar should contain expected tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CristalyseExampleApp());
      await tester.pumpAndSettle();

      // Verify some key tabs are present
      expect(find.text('Scatter Plot'), findsOneWidget);
      expect(find.text('Line Chart'), findsOneWidget);
      expect(find.text('Bar Chart'), findsOneWidget);
    });

    testWidgets('Theme switching FAB should be present',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CristalyseExampleApp());
      await tester.pumpAndSettle();

      // Verify floating action buttons are present
      expect(find.byIcon(Icons.palette), findsOneWidget);
      expect(find.byIcon(Icons.color_lens), findsOneWidget);
    });

    testWidgets('Controls toggle should work', (WidgetTester tester) async {
      await tester.pumpWidget(const CristalyseExampleApp());
      await tester.pumpAndSettle();

      // Find and tap the controls toggle button
      final controlsButton = find.byIcon(Icons.visibility);
      expect(controlsButton, findsOneWidget);

      await tester.tap(controlsButton);
      await tester.pumpAndSettle();

      // After tapping, icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
