import 'dart:math' as math;

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
      expect(ProgressStyle.values.length, 7);
      expect(ProgressStyle.values, contains(ProgressStyle.filled));
      expect(ProgressStyle.values, contains(ProgressStyle.striped));
      expect(ProgressStyle.values, contains(ProgressStyle.gradient));
      expect(ProgressStyle.values, contains(ProgressStyle.stacked));
      expect(ProgressStyle.values, contains(ProgressStyle.grouped));
      expect(ProgressStyle.values, contains(ProgressStyle.gauge));
      expect(ProgressStyle.values, contains(ProgressStyle.concentric));
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

  group('Enhanced Progress Bar Styles Tests', () {
    test('should create stacked progress bars with segments', () {
      final geometry = ProgressGeometry(
        style: ProgressStyle.stacked,
        segments: [30.0, 45.0, 25.0],
        segmentColors: [Colors.red, Colors.orange, Colors.green],
        thickness: 25.0,
        showLabel: true,
      );

      expect(geometry.style, equals(ProgressStyle.stacked));
      expect(geometry.segments, equals([30.0, 45.0, 25.0]));
      expect(geometry.segmentColors, equals([Colors.red, Colors.orange, Colors.green]));
      expect(geometry.thickness, equals(25.0));
      expect(geometry.showLabel, equals(true));
    });

    test('should create grouped progress bars with spacing', () {
      final geometry = ProgressGeometry(
        style: ProgressStyle.grouped,
        groupCount: 4,
        groupSpacing: 8.0,
        thickness: 20.0,
        orientation: ProgressOrientation.horizontal,
      );

      expect(geometry.style, equals(ProgressStyle.grouped));
      expect(geometry.groupCount, equals(4));
      expect(geometry.groupSpacing, equals(8.0));
      expect(geometry.thickness, equals(20.0));
      expect(geometry.orientation, equals(ProgressOrientation.horizontal));
    });

    test('should create gauge progress bars with ticks', () {
      final geometry = ProgressGeometry(
        style: ProgressStyle.gauge,
        startAngle: -math.pi,
        sweepAngle: math.pi,
        showTicks: true,
        tickCount: 8,
        gaugeRadius: 50.0,
        orientation: ProgressOrientation.circular,
      );

      expect(geometry.style, equals(ProgressStyle.gauge));
      expect(geometry.startAngle, equals(-math.pi));
      expect(geometry.sweepAngle, equals(math.pi));
      expect(geometry.showTicks, equals(true));
      expect(geometry.tickCount, equals(8));
      expect(geometry.gaugeRadius, equals(50.0));
      expect(geometry.orientation, equals(ProgressOrientation.circular));
    });

    test('should create concentric progress bars with radii', () {
      final geometry = ProgressGeometry(
        style: ProgressStyle.concentric,
        concentricRadii: [30.0, 50.0, 70.0],
        concentricThicknesses: [8.0, 10.0, 12.0],
        thickness: 25.0,
        orientation: ProgressOrientation.circular,
      );

      expect(geometry.style, equals(ProgressStyle.concentric));
      expect(geometry.concentricRadii, equals([30.0, 50.0, 70.0]));
      expect(geometry.concentricThicknesses, equals([8.0, 10.0, 12.0]));
      expect(geometry.thickness, equals(25.0));
      expect(geometry.orientation, equals(ProgressOrientation.circular));
    });

    testWidgets('should render stacked progress bars', (WidgetTester tester) async {
      final testData = [
        {'project': 'Mobile App', 'completion': 75.0, 'phase': 'Development'},
        {'project': 'Web Platform', 'completion': 60.0, 'phase': 'Testing'},
      ];

      final chart = CristalyseChart()
        .data(testData)
        .mappingProgress(
          value: 'completion',
          label: 'project',
          category: 'phase',
        )
        .geomProgress(
          style: ProgressStyle.stacked,
          orientation: ProgressOrientation.horizontal,
          segments: [40.0, 35.0],
          segmentColors: [Colors.blue, Colors.green],
          thickness: 20.0,
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

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('should render grouped progress bars', (WidgetTester tester) async {
      final testData = [
        {'task': 'Frontend', 'completion': 80.0, 'team': 'UI'},
        {'task': 'Backend', 'completion': 65.0, 'team': 'API'},
      ];

      final chart = CristalyseChart()
        .data(testData)
        .mappingProgress(
          value: 'completion',
          label: 'task',
          category: 'team',
        )
        .geomProgress(
          style: ProgressStyle.grouped,
          orientation: ProgressOrientation.vertical,
          groupCount: 3,
          groupSpacing: 10.0,
          thickness: 15.0,
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

    testWidgets('should render gauge progress bars with ticks', (WidgetTester tester) async {
      final testData = [
        {'metric': 'CPU Usage', 'completion': 65.0, 'type': 'System'},
        {'metric': 'Memory', 'completion': 42.0, 'type': 'System'},
      ];

      final chart = CristalyseChart()
        .data(testData)
        .mappingProgress(
          value: 'completion',
          label: 'metric',
          category: 'type',
        )
        .geomProgress(
          style: ProgressStyle.gauge,
          orientation: ProgressOrientation.circular,
          showTicks: true,
          tickCount: 10,
          startAngle: -math.pi,
          sweepAngle: math.pi,
          gaugeRadius: 60.0,
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: chart.build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('should render concentric progress rings', (WidgetTester tester) async {
      final testData = [
        {'system': 'Database', 'completion': 88.0, 'priority': 'High'},
        {'system': 'Cache', 'completion': 95.0, 'priority': 'High'},
      ];

      final chart = CristalyseChart()
        .data(testData)
        .mappingProgress(
          value: 'completion',
          label: 'system',
          category: 'priority',
        )
        .geomProgress(
          style: ProgressStyle.concentric,
          orientation: ProgressOrientation.circular,
          concentricRadii: [30.0, 50.0, 70.0],
          concentricThicknesses: [8.0, 10.0, 12.0],
          thickness: 25.0,
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: chart.build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    test('should validate progress style enum values', () {
      expect(ProgressStyle.values.length, equals(7));
      expect(ProgressStyle.values.contains(ProgressStyle.filled), isTrue);
      expect(ProgressStyle.values.contains(ProgressStyle.striped), isTrue);
      expect(ProgressStyle.values.contains(ProgressStyle.gradient), isTrue);
      expect(ProgressStyle.values.contains(ProgressStyle.stacked), isTrue);
      expect(ProgressStyle.values.contains(ProgressStyle.grouped), isTrue);
      expect(ProgressStyle.values.contains(ProgressStyle.gauge), isTrue);
      expect(ProgressStyle.values.contains(ProgressStyle.concentric), isTrue);
    });
  });

  group('Progress Bar Input Validation Tests', () {
    test('should reject invalid minValue/maxValue combinations', () {
      expect(
        () => ProgressGeometry(minValue: 100.0, maxValue: 50.0),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('minValue must be less than maxValue'),
        )),
      );
    });

    test('should reject negative thickness', () {
      expect(
        () => ProgressGeometry(thickness: -5.0),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('thickness must be >= 0'),
        )),
      );
    });

    test('should reject negative cornerRadius', () {
      expect(
        () => ProgressGeometry(cornerRadius: -2.0),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('cornerRadius must be >= 0'),
        )),
      );
    });

    test('should reject zero or negative animationDuration', () {
      expect(
        () => ProgressGeometry(animationDuration: Duration.zero),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('animationDuration must be positive'),
        )),
      );

      expect(
        () => ProgressGeometry(animationDuration: const Duration(milliseconds: -100)),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('animationDuration must be positive'),
        )),
      );
    });

    test('should reject invalid segment values', () {
      expect(
        () => ProgressGeometry(segments: [10.0, -5.0, 15.0]),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('all segments must be >= 0'),
        )),
      );
    });

    test('should reject invalid concentric radii', () {
      expect(
        () => ProgressGeometry(concentricRadii: [10.0, 0.0, 15.0]),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('all concentricRadii must be > 0'),
        )),
      );
    });

    test('should accept valid configurations', () {
      // Should not throw
      final geometry = ProgressGeometry(
        minValue: 0.0,
        maxValue: 100.0,
        thickness: 20.0,
        cornerRadius: 5.0,
        animationDuration: const Duration(milliseconds: 500),
        segments: [25.0, 50.0, 25.0],
        concentricRadii: [30.0, 60.0, 90.0],
        groupCount: 3,
        tickCount: 10,
      );

      expect(geometry.minValue, equals(0.0));
      expect(geometry.maxValue, equals(100.0));
      expect(geometry.thickness, equals(20.0));
    });
  });

  group('Progress Bar Edge Case Tests', () {
    test('should validate zero range (minValue == maxValue)', () {
      // This should be caught by validation during geometry construction
      expect(
        () => ProgressGeometry(minValue: 50.0, maxValue: 50.0),
        throwsA(isA<AssertionError>().having(
          (e) => e.message,
          'message',
          contains('minValue must be less than maxValue'),
        )),
      );
    });

    testWidgets('should handle invalid numeric values gracefully', (WidgetTester tester) async {
      final testData = [
        {'task': 'Test', 'completion': double.nan},
        {'task': 'Test2', 'completion': double.infinity},
        {'task': 'Test3', 'completion': double.negativeInfinity},
      ];

      final widget = MaterialApp(
        home: Scaffold(
          body: CristalyseChart()
              .data(testData)
              .mappingProgress(value: 'completion')
              .geomProgress(
                thickness: 20.0,
              )
              .build(),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Should not crash and should render something
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('should handle out-of-range and invalid progress values without crashing', (WidgetTester tester) async {
      final testData = [
        {'task': 'Negative', 'progress': -25.0},
        {'task': 'Above Max', 'progress': 150.0}, 
        {'task': 'Null Value', 'progress': null},
        {'task': 'String', 'progress': 'invalid'},
        {'task': 'Zero', 'progress': 0.0},
        {'task': 'Max', 'progress': 100.0},
        {'task': 'Valid', 'progress': 75.0},
      ];

      final widget = MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: CristalyseChart()
                .data(testData)
                .mappingProgress(value: 'progress', label: 'task')
                .geomProgress(
                  minValue: 0.0,
                  maxValue: 100.0,
                  orientation: ProgressOrientation.horizontal,
                  thickness: 20.0,
                )
                .build(),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Should not crash and should render the widget
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });
  });
}
