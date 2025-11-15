import 'package:cristalyse/src/core/geometry.dart';
import 'package:cristalyse/src/themes/chart_theme.dart';
import 'package:cristalyse/src/widgets/animated_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnimatedCristalyseChartWidget renders without errors', (
    WidgetTester tester,
  ) async {
    // Prepare test data
    final testData = [
      {'x': 'A', 'y': 10, 'value': 5},
      {'x': 'B', 'y': 20, 'value': 15},
      {'x': 'C', 'y': 15, 'value': 10},
      {'x': 'D', 'y': 25, 'value': 20},
    ];

    // Create a simple bar chart widget
    final widget = MaterialApp(
      home: Scaffold(
        body: AnimatedCristalyseChartWidget(
          data: testData,
          xColumn: 'x',
          yColumn: 'y',
          geometries: [BarGeometry()],
          theme: ChartTheme.defaultTheme(),
        ),
      ),
    );

    // Build the widget
    await tester.pumpWidget(widget);

    // Allow animations to start
    await tester.pump();

    // Verify the widget is in the tree
    expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);

    // Allow animations to complete
    await tester.pumpAndSettle();
  });

  testWidgets('AnimatedCristalyseChartWidget renders heatmap correctly', (
    WidgetTester tester,
  ) async {
    // Prepare heatmap test data
    final heatMapData = [
      {'heatX': 'Mon', 'heatY': 'Morning', 'temp': 20},
      {'heatX': 'Mon', 'heatY': 'Afternoon', 'temp': 25},
      {'heatX': 'Tue', 'heatY': 'Morning', 'temp': 18},
      {'heatX': 'Tue', 'heatY': 'Afternoon', 'temp': 28},
    ];

    // Create a heatmap widget
    final widget = MaterialApp(
      home: Scaffold(
        body: AnimatedCristalyseChartWidget(
          data: heatMapData,
          heatMapXColumn: 'heatX',
          heatMapYColumn: 'heatY',
          heatMapValueColumn: 'temp',
          geometries: [
            HeatMapGeometry(
              showValues: true,
              interpolateColors: true,
              colorGradient: [
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.red,
              ],
            ),
          ],
          theme: ChartTheme.defaultTheme(),
        ),
      ),
    );

    // Build the widget
    await tester.pumpWidget(widget);

    // Allow animations to start
    await tester.pump();

    // Verify the widget is in the tree
    expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);

    // Allow animations to complete
    await tester.pumpAndSettle();
  });

  testWidgets('AnimatedCristalyseChartWidget handles pie chart correctly', (
    WidgetTester tester,
  ) async {
    // Prepare pie chart test data
    final pieData = [
      {'category': 'A', 'value': 30},
      {'category': 'B', 'value': 25},
      {'category': 'C', 'value': 20},
      {'category': 'D', 'value': 25},
    ];

    // Create a pie chart widget
    final widget = MaterialApp(
      home: Scaffold(
        body: AnimatedCristalyseChartWidget(
          data: pieData,
          pieCategoryColumn: 'category',
          pieValueColumn: 'value',
          geometries: [PieGeometry(showLabels: true, showPercentages: true)],
          theme: ChartTheme.defaultTheme(),
        ),
      ),
    );

    // Build the widget
    await tester.pumpWidget(widget);

    // Allow animations to start
    await tester.pump();

    // Verify the widget is in the tree
    expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);

    // Allow animations to complete
    await tester.pumpAndSettle();
  });
}
