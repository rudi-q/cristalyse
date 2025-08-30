import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BubbleGeometry', () {
    test('should create bubble geometry with default values', () {
      final geometry = BubbleGeometry();

      expect(geometry.minSize, 5.0);
      expect(geometry.maxSize, 30.0);
      expect(geometry.alpha, 0.7);
      expect(geometry.shape, PointShape.circle);
      expect(geometry.borderWidth, 1.0);
      expect(geometry.showLabels, false);
      expect(geometry.labelOffset, 5.0);
      expect(geometry.yAxis, YAxis.primary);
      expect(geometry.interactive, true);
    });

    test('should create bubble geometry with custom values', () {
      final geometry = BubbleGeometry(
        minSize: 10.0,
        maxSize: 50.0,
        alpha: 0.5,
        shape: PointShape.square,
        borderWidth: 2.0,
        borderColor: Colors.red,
        showLabels: true,
        labelOffset: 10.0,
        yAxis: YAxis.secondary,
      );

      expect(geometry.minSize, 10.0);
      expect(geometry.maxSize, 50.0);
      expect(geometry.alpha, 0.5);
      expect(geometry.shape, PointShape.square);
      expect(geometry.borderWidth, 2.0);
      expect(geometry.borderColor, Colors.red);
      expect(geometry.showLabels, true);
      expect(geometry.labelOffset, 10.0);
      expect(geometry.yAxis, YAxis.secondary);
    });
  });

  group('CristalyseChart geomBubble', () {
    test('should add bubble geometry to chart', () {
      final chart = CristalyseChart()
          .data([
            {'x': 1.0, 'y': 2.0, 'size': 10.0, 'category': 'A'},
            {'x': 2.0, 'y': 3.0, 'size': 15.0, 'category': 'B'},
          ])
          .mapping(x: 'x', y: 'y', size: 'size', color: 'category')
          .geomBubble(
            minSize: 8.0,
            maxSize: 40.0,
            alpha: 0.8,
            shape: PointShape.circle,
            borderWidth: 1.5,
          );

      // Build the chart to trigger geometry creation
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should handle bubble chart with missing size column gracefully', () {
      final chart = CristalyseChart()
          .data([
            {'x': 1.0, 'y': 2.0, 'category': 'A'},
            {'x': 2.0, 'y': 3.0, 'category': 'B'},
          ])
          .mapping(x: 'x', y: 'y', color: 'category')
          .geomBubble(
            minSize: 8.0,
            maxSize: 40.0,
          );

      // Build the chart to trigger geometry creation
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should create bubble chart with labels', () {
      final chart = CristalyseChart()
          .data([
            {'x': 1.0, 'y': 2.0, 'size': 10.0, 'category': 'A'},
            {'x': 2.0, 'y': 3.0, 'size': 15.0, 'category': 'B'},
          ])
          .mapping(x: 'x', y: 'y', size: 'size', color: 'category')
          .geomBubble(
            showLabels: true,
            labelFormatter: (value) => 'Size: ${value.toStringAsFixed(1)}',
            labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
          );

      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should support different bubble shapes', () {
      final shapes = [PointShape.circle, PointShape.square, PointShape.triangle];
      
      for (final shape in shapes) {
        final chart = CristalyseChart()
            .data([
              {'x': 1.0, 'y': 2.0, 'size': 10.0},
            ])
            .mapping(x: 'x', y: 'y', size: 'size')
            .geomBubble(shape: shape);

        final widget = chart.build();
        expect(widget, isA<Widget>());
      }
    });

    test('should support secondary Y-axis for bubble charts', () {
      final chart = CristalyseChart()
          .data([
            {'x': 1.0, 'y': 2.0, 'y2': 20.0, 'size': 10.0},
          ])
          .mapping(x: 'x', y: 'y', size: 'size')
          .mappingY2('y2')
          .geomBubble(yAxis: YAxis.secondary);

      final widget = chart.build();
      expect(widget, isA<Widget>());
    });
  });

  group('Bubble Chart Integration', () {
    testWidgets('should render bubble chart widget', (WidgetTester tester) async {
      final chart = CristalyseChart()
          .data([
            {'x': 1.0, 'y': 2.0, 'size': 10.0, 'category': 'A'},
            {'x': 2.0, 'y': 3.0, 'size': 15.0, 'category': 'B'},
            {'x': 3.0, 'y': 1.0, 'size': 8.0, 'category': 'A'},
          ])
          .mapping(x: 'x', y: 'y', size: 'size', color: 'category')
          .geomBubble(
            minSize: 10.0,
            maxSize: 30.0,
            alpha: 0.7,
          )
          .scaleXContinuous()
          .scaleYContinuous()
          .theme(ChartTheme.defaultTheme());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: chart.build(),
            ),
          ),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Verify chart widget exists
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle empty data gracefully', (WidgetTester tester) async {
      final chart = CristalyseChart()
          .data([])
          .mapping(x: 'x', y: 'y', size: 'size', color: 'category')
          .geomBubble()
          .scaleXContinuous()
          .scaleYContinuous();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: chart.build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash with empty data
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });
}
