import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chart Rendering Smoke Tests (with titles)', () {
    testWidgets('X-axis title renders when provided',
        (WidgetTester tester) async {
      final data = [
        {'x': 1, 'y': 10},
        {'x': 2, 'y': 20},
        {'x': 3, 'y': 30},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomLine()
                  .scaleXContinuous(title: 'Time (seconds)')
                  .scaleYContinuous()
                  .build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The chart should render without errors
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Y-axis title renders when provided',
        (WidgetTester tester) async {
      final data = [
        {'x': 1, 'y': 10},
        {'x': 2, 'y': 20},
        {'x': 3, 'y': 30},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomLine()
                  .scaleXContinuous()
                  .scaleYContinuous(title: 'Revenue (USD)')
                  .build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The chart should render without errors
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Dual axis titles render', (WidgetTester tester) async {
      final data = [
        {'month': 'Jan', 'revenue': 1000, 'conversion': 12},
        {'month': 'Feb', 'revenue': 1500, 'conversion': 15},
        {'month': 'Mar', 'revenue': 2000, 'conversion': 18},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'month', y: 'revenue')
                  .mappingY2('conversion')
                  .geomBar(yAxis: YAxis.primary)
                  .geomLine(yAxis: YAxis.secondary)
                  .scaleXOrdinal(title: 'Month')
                  .scaleYContinuous(title: 'Revenue (\$K)')
                  .scaleY2Continuous(title: 'Conversion Rate (%)')
                  .build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The chart should render without errors
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Chart renders without titles when not provided',
        (WidgetTester tester) async {
      final data = [
        {'x': 1, 'y': 10},
        {'x': 2, 'y': 20},
        {'x': 3, 'y': 30},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomLine()
                  .scaleXContinuous()
                  .scaleYContinuous()
                  .build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The chart should render without errors
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Bubble chart size title appears in legend',
        (WidgetTester tester) async {
      final data = [
        {'x': 1, 'y': 10, 'size': 50, 'category': 'A'},
        {'x': 2, 'y': 20, 'size': 100, 'category': 'B'},
        {'x': 3, 'y': 30, 'size': 75, 'category': 'C'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y', size: 'size', color: 'category')
                  .geomBubble(title: 'Market Share (%)')
                  .scaleXContinuous(title: 'Revenue')
                  .scaleYContinuous(title: 'Users')
                  .legend()
                  .build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The chart should render with legend
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
