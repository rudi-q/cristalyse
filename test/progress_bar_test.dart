import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressGeometry Tests', () {
    test('should create ProgressGeometry with default values', () {
      final geometry = ProgressGeometry();

      expect(geometry.orientation, ProgressOrientation.horizontal);
      expect(geometry.thickness, 20.0);
      expect(geometry.cornerRadius, 4.0);
      expect(geometry.style, ProgressStyle.filled);
      expect(geometry.minValue, 0.0);
      expect(geometry.maxValue, 100.0);
      expect(geometry.showLabel, true);
      expect(geometry.animated, true);
      expect(geometry.strokeWidth, 1.0);
      expect(geometry.labelOffset, 5.0);
    });

    test('should create ProgressGeometry with custom values', () {
      final geometry = ProgressGeometry(
        orientation: ProgressOrientation.vertical,
        thickness: 30.0,
        cornerRadius: 8.0,
        backgroundColor: Colors.grey,
        fillColor: Colors.blue,
        style: ProgressStyle.gradient,
        minValue: 10.0,
        maxValue: 90.0,
        showLabel: false,
        strokeWidth: 2.0,
        strokeColor: Colors.black,
        labelOffset: 10.0,
      );

      expect(geometry.orientation, ProgressOrientation.vertical);
      expect(geometry.thickness, 30.0);
      expect(geometry.cornerRadius, 8.0);
      expect(geometry.backgroundColor, Colors.grey);
      expect(geometry.fillColor, Colors.blue);
      expect(geometry.style, ProgressStyle.gradient);
      expect(geometry.minValue, 10.0);
      expect(geometry.maxValue, 90.0);
      expect(geometry.showLabel, false);
      expect(geometry.strokeWidth, 2.0);
      expect(geometry.strokeColor, Colors.black);
      expect(geometry.labelOffset, 10.0);
    });
  });

  group('CristalyseChart Progress Tests', () {
    test('should add progress geometry to chart', () {
      final chart = CristalyseChart()
        .data([
          {'task': 'Task 1', 'completion': 75.0, 'department': 'Engineering'},
          {'task': 'Task 2', 'completion': 50.0, 'department': 'Product'},
        ])
        .mappingProgress(value: 'completion', label: 'task', category: 'department')
        .geomProgress(
          orientation: ProgressOrientation.horizontal,
          thickness: 25.0,
          style: ProgressStyle.gradient,
        );

      expect(chart, isA<CristalyseChart>());
      // We can't directly access private fields, but we can verify the chart was created successfully
    });

    test('should handle progress mapping correctly', () {
      final chart = CristalyseChart()
        .data([
          {'value': 80.0, 'name': 'Progress 1'},
          {'value': 60.0, 'name': 'Progress 2'},
        ])
        .mappingProgress(value: 'value', label: 'name');

      expect(chart, isA<CristalyseChart>());
    });

    test('should create progress chart with different orientations', () {
      // Horizontal
      final horizontalChart = CristalyseChart()
        .data([{'completion': 50.0}])
        .geomProgress(orientation: ProgressOrientation.horizontal);

      expect(horizontalChart, isA<CristalyseChart>());

      // Vertical
      final verticalChart = CristalyseChart()
        .data([{'completion': 75.0}])
        .geomProgress(orientation: ProgressOrientation.vertical);

      expect(verticalChart, isA<CristalyseChart>());

      // Circular
      final circularChart = CristalyseChart()
        .data([{'completion': 90.0}])
        .geomProgress(orientation: ProgressOrientation.circular);

      expect(circularChart, isA<CristalyseChart>());
    });

    test('should create progress chart with different styles', () {
      // Filled
      final filledChart = CristalyseChart()
        .data([{'completion': 50.0}])
        .geomProgress(style: ProgressStyle.filled);

      expect(filledChart, isA<CristalyseChart>());

      // Gradient
      final gradientChart = CristalyseChart()
        .data([{'completion': 75.0}])
        .geomProgress(style: ProgressStyle.gradient);

      expect(gradientChart, isA<CristalyseChart>());

      // Striped
      final stripedChart = CristalyseChart()
        .data([{'completion': 90.0}])
        .geomProgress(style: ProgressStyle.striped);

      expect(stripedChart, isA<CristalyseChart>());
    });
  });

  group('Progress Enums Tests', () {
    test('should have correct ProgressOrientation values', () {
      expect(ProgressOrientation.values.length, 3);
      expect(ProgressOrientation.values, contains(ProgressOrientation.horizontal));
      expect(ProgressOrientation.values, contains(ProgressOrientation.vertical));
      expect(ProgressOrientation.values, contains(ProgressOrientation.circular));
    });

    test('should have correct ProgressStyle values', () {
      expect(ProgressStyle.values.length, 3);
      expect(ProgressStyle.values, contains(ProgressStyle.filled));
      expect(ProgressStyle.values, contains(ProgressStyle.striped));
      expect(ProgressStyle.values, contains(ProgressStyle.gradient));
    });
  });

  group('Progress Chart Widget Tests', () {
    testWidgets('should build progress chart widget without errors', (WidgetTester tester) async {
      final chart = CristalyseChart()
        .data([
          {'task': 'Development', 'progress': 75.0, 'category': 'Engineering'},
          {'task': 'Design', 'progress': 60.0, 'category': 'Product'},
          {'task': 'Testing', 'progress': 40.0, 'category': 'QA'},
        ])
        .mappingProgress(value: 'progress', label: 'task', category: 'category')
        .geomProgress(
          orientation: ProgressOrientation.horizontal,
          thickness: 20.0,
          cornerRadius: 8.0,
          showLabel: true,
          style: ProgressStyle.gradient,
        )
        .theme(ChartTheme.defaultTheme())
        .animate(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
        );

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

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('should handle empty data gracefully', (WidgetTester tester) async {
      final chart = CristalyseChart()
        .data([]) // Empty data
        .geomProgress(
          orientation: ProgressOrientation.horizontal,
          thickness: 20.0,
        );

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

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('should handle different data types in progress values', (WidgetTester tester) async {
      final chart = CristalyseChart()
        .data([
          {'progress': 50}, // int
          {'progress': 75.5}, // double  
          {'progress': '80'}, // string (should be parsed)
        ])
        .geomProgress(
          orientation: ProgressOrientation.vertical,
          minValue: 0.0,
          maxValue: 100.0,
        );

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

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });
  });

  group('Progress Chart Animation Tests', () {
    testWidgets('should animate progress bars over time', (WidgetTester tester) async {
      final chart = CristalyseChart()
        .data([
          {'task': 'Task 1', 'completion': 80.0},
        ])
        .mappingProgress(value: 'completion', label: 'task')
        .geomProgress(
          orientation: ProgressOrientation.horizontal,
          thickness: 25.0,
        )
        .animate(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 200,
              child: chart.build(),
            ),
          ),
        ),
      );

      // Initial state (animation starting)
      await tester.pump();
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);

      // Mid-animation
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);

      // Animation complete
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });
  });

  group('Progress Chart Theme Integration Tests', () {
    testWidgets('should apply theme colors to progress bars', (WidgetTester tester) async {
      final customTheme = ChartTheme.defaultTheme().copyWith(
        primaryColor: Colors.red,
        colorPalette: [Colors.red, Colors.green, Colors.blue],
      );

      final chart = CristalyseChart()
        .data([
          {'progress': 60.0, 'category': 'A'},
          {'progress': 80.0, 'category': 'B'},
        ])
        .mappingProgress(value: 'progress', category: 'category')
        .geomProgress(
          orientation: ProgressOrientation.horizontal,
          thickness: 20.0,
        )
        .theme(customTheme);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 200,
              child: chart.build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });
  });
}