import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeatMap Widget Tests', () {
    testWidgets('HeatMapExample renders without errors', (
      WidgetTester tester,
    ) async {
      // Create a test app with HeatMapExample
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: _TestHeatMapExample(),
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify the widget tree contains expected elements
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
      expect(find.text('Weekly Activity Heatmap'), findsOneWidget);
      expect(
        find.text('Hours spent on different activities throughout the week'),
        findsOneWidget,
      );
    });

    testWidgets('HeatMap renders with data points', (
      WidgetTester tester,
    ) async {
      // Create test data
      final testData = [
        {'day': 'Mon', 'hour': '9AM', 'value': 5},
        {'day': 'Mon', 'hour': '10AM', 'value': 8},
        {'day': 'Tue', 'hour': '9AM', 'value': 3},
        {'day': 'Tue', 'hour': '10AM', 'value': 6},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'day',
                heatMapYColumn: 'hour',
                heatMapValueColumn: 'value',
                geometries: [HeatMapGeometry(showValues: true, cellSpacing: 2)],
                theme: ChartTheme.defaultTheme(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that the chart widget is rendered
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);

      // Verify paint is called (indicates drawing is happening)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('ContributionHeatMap renders without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: _TestContributionHeatMap(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
      expect(find.text('Developer Contributions'), findsOneWidget);
      expect(
        find.text('GitHub-style contribution graph showing daily activity'),
        findsOneWidget,
      );
    });

    testWidgets('HeatMap with null values renders correctly', (
      WidgetTester tester,
    ) async {
      final testData = [
        {'x': 'A', 'y': '1', 'value': 5},
        {'x': 'A', 'y': '2', 'value': null}, // Null value
        {'x': 'B', 'y': '1', 'value': 3},
        {'x': 'B', 'y': '2', 'value': 7},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'x',
                heatMapYColumn: 'y',
                heatMapValueColumn: 'value',
                geometries: [
                  HeatMapGeometry(nullValueColor: Colors.grey.shade200),
                ],
                theme: ChartTheme.defaultTheme(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without throwing errors
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('HeatMap with custom color gradient', (
      WidgetTester tester,
    ) async {
      final testData = List.generate(
        16,
        (i) => {
          'x': (i % 4).toString(),
          'y': (i ~/ 4).toString(),
          'value': i.toDouble(),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: AnimatedCristalyseChartWidget(
                data: testData,
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
                theme: ChartTheme.defaultTheme(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('HeatMap with discrete colors', (WidgetTester tester) async {
      final testData = List.generate(
        9,
        (i) => {
          'x': (i % 3).toString(),
          'y': (i ~/ 3).toString(),
          'value': i * 10.0,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'x',
                heatMapYColumn: 'y',
                heatMapValueColumn: 'value',
                geometries: [
                  HeatMapGeometry(
                    colorGradient: [
                      Colors.green.shade100,
                      Colors.green.shade300,
                      Colors.green.shade500,
                      Colors.green.shade700,
                      Colors.green.shade900,
                    ],
                    interpolateColors: false, // Use discrete colors
                  ),
                ],
                theme: ChartTheme.defaultTheme(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
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
                theme: ChartTheme.defaultTheme(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors even with empty data
      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('HeatMap with animation test', (WidgetTester tester) async {
      final testData = [
        {'x': 'A', 'y': '1', 'value': 5},
        {'x': 'B', 'y': '1', 'value': 10},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AnimatedCristalyseChartWidget(
                data: testData,
                heatMapXColumn: 'x',
                heatMapYColumn: 'y',
                heatMapValueColumn: 'value',
                geometries: [HeatMapGeometry()],
                theme: ChartTheme.defaultTheme(),
                animationDuration: const Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Pump halfway through animation
      await tester.pump(const Duration(milliseconds: 250));

      // Complete animation
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });
  });

  group('HeatMapGeometry Tests', () {
    test('HeatMapGeometry default values', () {
      final geometry = HeatMapGeometry();

      expect(geometry.cellSpacing, 1.0);
      expect(geometry.showValues, false);
      expect(geometry.interpolateColors, true);
      expect(geometry.nullValueColor, null);
      expect(geometry.cellAspectRatio, null);
      expect(geometry.cellBorderRadius, null);
    });

    test('HeatMapGeometry custom values', () {
      final geometry = HeatMapGeometry(
        cellSpacing: 2.0,
        showValues: true,
        interpolateColors: false,
        nullValueColor: Colors.grey,
        cellAspectRatio: 1.5,
        cellBorderRadius: BorderRadius.circular(4),
        colorGradient: [Colors.blue, Colors.red],
        minValue: 0,
        maxValue: 100,
        valueFormatter: (value) => value.toStringAsFixed(0),
        valueTextStyle: const TextStyle(fontSize: 12),
      );

      expect(geometry.cellSpacing, 2.0);
      expect(geometry.showValues, true);
      expect(geometry.interpolateColors, false);
      expect(geometry.nullValueColor, Colors.grey);
      expect(geometry.cellAspectRatio, 1.5);
      expect(geometry.cellBorderRadius, BorderRadius.circular(4));
      expect(geometry.colorGradient, [Colors.blue, Colors.red]);
      expect(geometry.minValue, 0);
      expect(geometry.maxValue, 100);
      expect(geometry.valueFormatter, isNotNull);
      expect(geometry.valueTextStyle?.fontSize, 12);
    });
  });

  group('Data Generation Tests', () {
    test('Generate weekly activity data', () {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final hours = List.generate(24, (i) => '${i}h');
      final data = <Map<String, dynamic>>[];

      for (final day in days) {
        for (final hour in hours) {
          data.add({
            'day': day,
            'hour': hour,
            'value': (days.indexOf(day) + hours.indexOf(hour)) * 2,
          });
        }
      }

      expect(data.length, 7 * 24); // 7 days * 24 hours
      expect(data.first['day'], 'Mon');
      expect(data.first['hour'], '0h');
      expect(data.last['day'], 'Sun');
      expect(data.last['hour'], '23h');
    });

    test('Generate contribution data', () {
      final data = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (int week = 0; week < 52; week++) {
        for (int day = 0; day < 7; day++) {
          final date = now.subtract(
            Duration(days: (51 - week) * 7 + (6 - day)),
          );
          data.add({
            'week': 'W${week + 1}',
            'day': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day],
            'contributions': (week + day) % 10,
            'date': date,
          });
        }
      }

      expect(data.length, 52 * 7); // 52 weeks * 7 days
      expect(data.first['week'], 'W1');
      expect(data.last['week'], 'W52');
    });
  });
}

// Test implementations of the example widgets
class _TestHeatMapExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark
        ? ChartTheme.darkTheme()
        : ChartTheme.defaultTheme();

    // Generate weekly activity data
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hours = List.generate(24, (i) => '${i}h');
    final data = <Map<String, dynamic>>[];

    for (int d = 0; d < days.length; d++) {
      for (int h = 0; h < hours.length; h++) {
        double value;
        if (days[d] == 'Sat' || days[d] == 'Sun') {
          value = h >= 10 && h <= 22 ? 5 + (h % 4) * 2.0 : 1.0;
        } else {
          if (h >= 9 && h <= 17) {
            value = 7 + (h % 3) * 2.0;
          } else if (h >= 19 && h <= 22) {
            value = 4 + (h % 2) * 1.5;
          } else {
            value = h >= 6 && h <= 8 ? 3.0 : 0.5;
          }
        }

        data.add({'day': days[d], 'hour': hours[h], 'activity': value});
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Activity Heatmap',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Hours spent on different activities throughout the week',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedCristalyseChartWidget(
                data: data,
                heatMapXColumn: 'hour',
                heatMapYColumn: 'day',
                heatMapValueColumn: 'activity',
                geometries: [
                  HeatMapGeometry(
                    cellSpacing: 2,
                    showValues: false,
                    interpolateColors: true,
                    colorGradient: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                      Colors.blue.shade300,
                      Colors.blue.shade500,
                      Colors.blue.shade700,
                      Colors.blue.shade900,
                    ],
                    cellBorderRadius: BorderRadius.circular(4),
                    minValue: 0,
                    maxValue: 10,
                  ),
                ],
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestContributionHeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark
        ? ChartTheme.darkTheme()
        : ChartTheme.defaultTheme();

    // Generate contribution data (GitHub-style)
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    for (int week = 0; week < 52; week++) {
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (51 - week) * 7 + (6 - day)));
        int contributions;

        final random = (week * 7 + day) % 100;
        if (random < 30) {
          contributions = 0;
        } else if (random < 50) {
          contributions = 1 + (random % 3);
        } else if (random < 75) {
          contributions = 4 + (random % 5);
        } else if (random < 90) {
          contributions = 9 + (random % 7);
        } else {
          contributions = 16 + (random % 15);
        }

        data.add({
          'week': 'W${week + 1}',
          'day': weekDays[day],
          'contributions': contributions,
          'date': date.toIso8601String(),
        });
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer Contributions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'GitHub-style contribution graph showing daily activity',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedCristalyseChartWidget(
                data: data,
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
                    maxValue: 30,
                  ),
                ],
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
