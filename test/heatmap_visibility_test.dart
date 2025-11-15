import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeatMap Core Functionality Tests', () {
    late ChartTheme testTheme;
    late List<Map<String, dynamic>> testData;
    late List<Map<String, dynamic>> contributionData;
    late List<Map<String, dynamic>> nullData;

    setUp(() {
      testTheme = ChartTheme.defaultTheme();

      // Generate test heatmap data
      testData = [];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final hours = [
        '9am',
        '10am',
        '11am',
        '12pm',
        '1pm',
        '2pm',
        '3pm',
        '4pm',
        '5pm',
        '6pm',
        '7pm',
        '8pm',
      ];

      for (final day in days) {
        for (final hour in hours) {
          final activity = (days.indexOf(day) + hours.indexOf(hour)) * 2.5;
          testData.add({'day': day, 'hour': hour, 'activity': activity});
        }
      }

      // Generate contribution-style data
      contributionData = [];
      for (int week = 0; week < 12; week++) {
        for (int day = 0; day < 7; day++) {
          contributionData.add({
            'week': 'W${week + 1}',
            'day': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day],
            'contributions': (week + day) % 10,
          });
        }
      }

      // Generate data with null values
      nullData = [
        {'x': 'A', 'y': '1', 'value': 5.0},
        {'x': 'A', 'y': '2', 'value': null}, // Null value
        {'x': 'B', 'y': '1', 'value': 3.0},
        {'x': 'B', 'y': '2', 'value': 7.0},
      ];
    });

    testWidgets('HeatMap widget renders without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'activity',
                geometries: [
                  HeatMapGeometry(
                    cellSpacing: 1,
                    showValues: true,
                    minValue: 0,
                    maxValue: 100,
                    interpolateColors: true,
                    colorGradient: [
                      Colors.blue.shade100,
                      Colors.blue.shade300,
                      Colors.blue.shade500,
                      Colors.blue.shade700,
                      Colors.blue.shade900,
                      Colors.red.shade500,
                      Colors.red.shade700,
                    ],
                  ),
                ],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      // Verify the widget builds without throwing
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HeatMap chart widget configuration is correct', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'activity',
                geometries: [
                  HeatMapGeometry(
                    cellSpacing: 1,
                    showValues: true,
                    minValue: 0,
                    maxValue: 100,
                    interpolateColors: true,
                    colorGradient: [
                      Colors.blue.shade100,
                      Colors.blue.shade300,
                      Colors.blue.shade500,
                      Colors.blue.shade700,
                      Colors.blue.shade900,
                      Colors.red.shade500,
                      Colors.red.shade700,
                    ],
                  ),
                ],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      // Find the chart widget and verify configuration
      final chartWidget = tester.widget<AnimatedCristalyseChartWidget>(
        find.byType(AnimatedCristalyseChartWidget),
      );

      expect(chartWidget.data, isNotEmpty);
      expect(chartWidget.geometries, hasLength(1));
      expect(chartWidget.geometries.first, isA<HeatMapGeometry>());

      // Verify heatmap-specific columns are set
      expect(chartWidget.heatMapXColumn, equals('day'));
      expect(chartWidget.heatMapYColumn, equals('hour'));
      expect(chartWidget.heatMapValueColumn, equals('activity'));

      final heatMapGeometry = chartWidget.geometries.first as HeatMapGeometry;

      // Verify heatmap configuration
      expect(heatMapGeometry.cellSpacing, equals(1));
      expect(heatMapGeometry.showValues, isTrue);
      expect(heatMapGeometry.minValue, equals(0));
      expect(heatMapGeometry.maxValue, equals(100));
      expect(heatMapGeometry.interpolateColors, isTrue);
      expect(heatMapGeometry.colorGradient, isNotNull);
      expect(heatMapGeometry.colorGradient!.length, equals(7));
    });

    testWidgets('HeatMap data structure is correct', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'activity',
                geometries: [HeatMapGeometry()],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      final chartWidget = tester.widget<AnimatedCristalyseChartWidget>(
        find.byType(AnimatedCristalyseChartWidget),
      );

      final data = chartWidget.data;

      // Verify data structure
      expect(data, isNotEmpty);
      expect(data.length, equals(84)); // 7 days × 12 hours = 84 data points

      // Verify data contains expected columns
      final firstDataPoint = data.first;
      expect(firstDataPoint.containsKey('day'), isTrue);
      expect(firstDataPoint.containsKey('hour'), isTrue);
      expect(firstDataPoint.containsKey('activity'), isTrue);

      // Verify day values
      final dayValues = data.map((d) => d['day']).toSet();
      expect(dayValues, hasLength(7));
      expect(
        dayValues,
        containsAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']),
      );

      // Verify hour values
      final hourValues = data.map((d) => d['hour']).toSet();
      expect(hourValues, hasLength(12));
      expect(hourValues, contains('9am'));
      expect(hourValues, contains('8pm'));
    });

    testWidgets('HeatMap renders within constrained height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 380, // Constrained height
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'activity',
                geometries: [
                  HeatMapGeometry(
                    cellSpacing: 1,
                    showValues: false, // Don't show values to save space
                  ),
                ],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('HeatMap animation completes successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'activity',
                geometries: [HeatMapGeometry()],
                theme: testTheme,
                animationDuration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      );

      // Let the animation complete
      await tester.pump(); // Initial frame
      await tester.pump(const Duration(milliseconds: 100)); // Partial animation
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Complete animation

      // Verify no exceptions during animation
      expect(tester.takeException(), isNull);

      // The chart should still be present after animation
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('HeatMap handles null values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedCristalyseChartWidget(
                data: nullData,
                heatMapXColumn: 'x',
                heatMapYColumn: 'y',
                heatMapValueColumn: 'value',
                geometries: [
                  HeatMapGeometry(nullValueColor: Colors.grey.shade200),
                ],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final chartWidget = tester.widget<AnimatedCristalyseChartWidget>(
        find.byType(AnimatedCristalyseChartWidget),
      );

      final data = chartWidget.data;

      // Check that some data points have null values
      final nullValueCount = data.where((d) => d['value'] == null).length;
      expect(nullValueCount, equals(1)); // Should have one null value

      // Verify null value color is configured
      final heatMapGeometry = chartWidget.geometries.first as HeatMapGeometry;
      expect(heatMapGeometry.nullValueColor, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Contribution-style HeatMap renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: AnimatedCristalyseChartWidget(
                data: contributionData,
                heatMapXColumn: 'week',
                heatMapYColumn: 'day',
                heatMapValueColumn: 'contributions',
                geometries: [
                  HeatMapGeometry(
                    cellSpacing: 2,
                    showValues: false,
                    interpolateColors: false,
                    colorGradient: [
                      const Color(0xFFEBEDF0),
                      const Color(0xFF9BE9A8),
                      const Color(0xFF40C463),
                      const Color(0xFF30A14E),
                      const Color(0xFF216E39),
                    ],
                    cellBorderRadius: BorderRadius.circular(2),
                    cellAspectRatio: 1.0,
                    minValue: 0,
                    maxValue: 10,
                  ),
                ],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      // Verify the widget builds without throwing
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);

      final chartWidget = tester.widget<AnimatedCristalyseChartWidget>(
        find.byType(AnimatedCristalyseChartWidget),
      );
      expect(chartWidget.data, isNotEmpty);
      expect(
        chartWidget.data.length,
        equals(84),
      ); // 12 weeks × 7 days = 84 data points
    });

    testWidgets('HeatMap cells are rendered via CustomPaint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 380,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'activity',
                geometries: [HeatMapGeometry()],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      // Let animation complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Find CustomPaint widget which actually draws the heatmap cells
      final customPaintFinder = find.descendant(
        of: find.byType(AnimatedCristalyseChartWidget),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);

      // Verify CustomPaint has a painter (the chart painter)
      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      expect(customPaint.painter, isNotNull);

      // Verify no rendering exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('HeatMap with custom color gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: AnimatedCristalyseChartWidget(
                data: [
                  {'x': '0', 'y': '0', 'value': 0.0},
                  {'x': '1', 'y': '0', 'value': 25.0},
                  {'x': '0', 'y': '1', 'value': 50.0},
                  {'x': '1', 'y': '1', 'value': 100.0},
                ],
                heatMapXColumn: 'x',
                heatMapYColumn: 'y',
                heatMapValueColumn: 'value',
                geometries: [
                  HeatMapGeometry(
                    colorGradient: [
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.red,
                    ],
                    interpolateColors: true,
                  ),
                ],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HeatMap handles empty data gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedCristalyseChartWidget(
                data: [], // Empty data
                heatMapXColumn: 'x',
                heatMapYColumn: 'y',
                heatMapValueColumn: 'value',
                geometries: [HeatMapGeometry()],
                theme: testTheme,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors even with empty data
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
