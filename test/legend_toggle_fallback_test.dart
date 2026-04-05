import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Legend Toggle Fallback', () {
    testWidgets(
      'should use internal state when hiddenCategories provided without onToggle',
      (WidgetTester tester) async {
        // Test case: User provides hiddenCategories to seed initial state
        // but leaves onToggle null, expecting auto-managed toggling
        final data = [
          {'category': 'A', 'value': 10},
          {'category': 'B', 'value': 20},
          {'category': 'C', 'value': 30},
        ];

        // Initial hidden categories (e.g., start with B hidden)
        final initialHidden = <String>{'B'};

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'category', y: 'value', color: 'category')
                  .geomBar()
                  .legend(
                    interactive: true,
                    hiddenCategories: initialHidden,
                    // NO onToggle provided - should fall back to internal state
                  )
                  .build(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find legend items by text
        final legendA = find.text('A');
        final legendB = find.text('B');
        final legendC = find.text('C');

        expect(legendA, findsOneWidget);
        expect(legendB, findsOneWidget);
        expect(legendC, findsOneWidget);

        // B should start hidden (reduced opacity)
        final bOpacity = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendB,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(bOpacity.opacity, equals(0.4)); // Hidden state

        // A and C should be visible
        final aOpacity = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendA,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(aOpacity.opacity, equals(1.0)); // Visible state

        // Now tap on B to toggle it visible
        await tester.tap(legendB);
        await tester.pumpAndSettle();

        // B should now be visible
        final bOpacityAfter = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendB,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(bOpacityAfter.opacity, equals(1.0)); // Now visible

        // Tap on A to hide it
        await tester.tap(legendA);
        await tester.pumpAndSettle();

        // A should now be hidden
        final aOpacityAfter = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendA,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(aOpacityAfter.opacity, equals(0.4)); // Now hidden
      },
    );

    testWidgets(
      'should use external state when both hiddenCategories and onToggle provided',
      (WidgetTester tester) async {
        // Test case: External state management
        final data = [
          {'category': 'X', 'value': 100},
          {'category': 'Y', 'value': 200},
        ];

        final externalHidden = <String>{'X'};
        String? lastToggledCategory;
        bool? lastToggledVisible;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'category', y: 'value', color: 'category')
                  .geomBar()
                  .legend(
                    interactive: true,
                    hiddenCategories: externalHidden,
                    onToggle: (category, visible) {
                      lastToggledCategory = category;
                      lastToggledVisible = visible;
                    },
                  )
                  .build(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final legendX = find.text('X');
        final legendY = find.text('Y');

        expect(legendX, findsOneWidget);
        expect(legendY, findsOneWidget);

        // Tap on Y to hide it
        await tester.tap(legendY);
        await tester.pump();

        // onToggle should have been called
        expect(lastToggledCategory, equals('Y'));
        expect(lastToggledVisible, equals(false)); // Hiding Y

        // Tap on X to show it
        await tester.tap(legendX);
        await tester.pump();

        expect(lastToggledCategory, equals('X'));
        expect(lastToggledVisible, equals(true)); // Showing X
      },
    );

    testWidgets(
      'should use internal state when only interactive: true provided',
      (WidgetTester tester) async {
        // Test case: Standard auto-managed interactive legend
        final data = [
          {'category': 'P', 'value': 50},
          {'category': 'Q', 'value': 75},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'category', y: 'value', color: 'category')
                  .geomBar()
                  .legend(interactive: true)
                  .build(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final legendP = find.text('P');
        final legendQ = find.text('Q');

        expect(legendP, findsOneWidget);
        expect(legendQ, findsOneWidget);

        // Both should start visible
        final pOpacity = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendP,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(pOpacity.opacity, equals(1.0));

        // Tap P to hide it
        await tester.tap(legendP);
        await tester.pumpAndSettle();

        // P should now be hidden
        final pOpacityAfter = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendP,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(pOpacityAfter.opacity, equals(0.4));

        // Tap P again to show it
        await tester.tap(legendP);
        await tester.pumpAndSettle();

        // P should be visible again
        final pOpacityFinal = tester
            .widgetList<AnimatedOpacity>(
              find.ancestor(
                of: legendP,
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .first;
        expect(pOpacityFinal.opacity, equals(1.0));
      },
    );

    testWidgets(
      'should notify via onToggle even with internal state management',
      (WidgetTester tester) async {
        // Test case: onToggle can be used for notifications/analytics
        // even when not managing external state
        final data = [
          {'category': 'M', 'value': 30},
          {'category': 'N', 'value': 40},
        ];

        final toggleLog = <String>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'category', y: 'value', color: 'category')
                  .geomBar()
                  .legend(
                    interactive: true,
                    // hiddenCategories NOT provided, but onToggle IS provided
                    // Should use internal state but still call onToggle
                    onToggle: (category, visible) {
                      toggleLog.add('$category:$visible');
                    },
                  )
                  .build(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final legendM = find.text('M');

        // Tap M to hide it
        await tester.tap(legendM);
        await tester.pumpAndSettle();

        // Should have logged the toggle
        expect(toggleLog, contains('M:false'));

        // Tap M again to show it
        await tester.tap(legendM);
        await tester.pumpAndSettle();

        expect(toggleLog, contains('M:true'));
        expect(toggleLog.length, equals(2));
      },
    );
  });
}
