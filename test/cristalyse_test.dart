import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<Map<String, dynamic>> sampleData;
  group('CristalyseChart', () {
    late List<Map<String, dynamic>> categoricalData;
    late List<Map<String, dynamic>> dualAxisData;

    setUp(() {
      sampleData = [
        {'x': 1.0, 'y': 2.0, 'category': 'A', 'size': 5.0},
        {'x': 2.0, 'y': 3.0, 'category': 'B', 'size': 7.0},
        {'x': 3.0, 'y': 1.0, 'category': 'A', 'size': 3.0},
        {'x': 4.0, 'y': 4.0, 'category': 'C', 'size': 9.0},
      ];

      categoricalData = [
        {'quarter': 'Q1', 'revenue': 100.0, 'product': 'Mobile'},
        {'quarter': 'Q1', 'revenue': 80.0, 'product': 'Web'},
        {'quarter': 'Q2', 'revenue': 120.0, 'product': 'Mobile'},
        {'quarter': 'Q2', 'revenue': 90.0, 'product': 'Web'},
      ];

      dualAxisData = [
        {'month': 'Jan', 'revenue': 100.0, 'conversion_rate': 15.0},
        {'month': 'Feb', 'revenue': 110.0, 'conversion_rate': 17.0},
        {'month': 'Mar', 'revenue': 120.0, 'conversion_rate': 19.0},
      ];
    });

    group('Basic Chart Creation', () {
      test('should create chart with scatter plot', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y', color: 'category', size: 'size')
            .geomPoint();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create chart with line plot', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y', color: 'category')
            .geomLine(strokeWidth: 2.0, alpha: 0.8);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create chart with area plot', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y', color: 'category')
            .geomArea(strokeWidth: 2.0, alpha: 0.3, fillArea: true);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create chart with bar plot', () {
        final chart = CristalyseChart()
            .data(categoricalData)
            .mapping(x: 'quarter', y: 'revenue')
            .geomBar(width: 0.8, alpha: 0.9)
            .scaleXOrdinal()
            .scaleYContinuous(min: 0);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should handle empty data', () {
        final chart =
            CristalyseChart().data([]).mapping(x: 'x', y: 'y').geomPoint();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });
    });

    group('Dual Y-Axis Support', () {
      test('should create dual Y-axis chart', () {
        final chart = CristalyseChart()
            .data(dualAxisData)
            .mapping(x: 'month', y: 'revenue')
            .mappingY2('conversion_rate')
            .geomBar(yAxis: YAxis.primary)
            .geomLine(yAxis: YAxis.secondary)
            .scaleXOrdinal()
            .scaleYContinuous(min: 0)
            .scaleY2Continuous(min: 0, max: 100);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should handle secondary Y-axis geometries', () {
        final chart = CristalyseChart()
            .data(dualAxisData)
            .mapping(x: 'month', y: 'revenue')
            .mappingY2('conversion_rate')
            .geomPoint(yAxis: YAxis.secondary, size: 8.0)
            .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });
    });

    group('Bar Chart Variations', () {
      test('should create grouped bar chart', () {
        final chart = CristalyseChart()
            .data(categoricalData)
            .mapping(x: 'quarter', y: 'revenue', color: 'product')
            .geomBar(width: 0.8, style: BarStyle.grouped)
            .scaleXOrdinal()
            .scaleYContinuous(min: 0);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create stacked bar chart', () {
        final chart = CristalyseChart()
            .data(categoricalData)
            .mapping(x: 'quarter', y: 'revenue', color: 'product')
            .geomBar(width: 0.8, style: BarStyle.stacked)
            .scaleXOrdinal()
            .scaleYContinuous(min: 0);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create horizontal bar chart', () {
        final chart = CristalyseChart()
            .data(categoricalData)
            .mapping(x: 'quarter', y: 'revenue')
            .geomBar(width: 0.8)
            .coordFlip()
            .scaleXOrdinal()
            .scaleYContinuous(min: 0);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });
    });

    group('Geometry Properties', () {
      test('should apply point geometry properties', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint(
              size: 10.0,
              alpha: 0.7,
              shape: PointShape.square,
              borderWidth: 2.0,
            );

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should apply line geometry properties', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomLine(strokeWidth: 4.0, alpha: 0.9, style: LineStyle.solid);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should apply bar geometry properties', () {
        final chart = CristalyseChart()
            .data(categoricalData)
            .mapping(x: 'quarter', y: 'revenue')
            .geomBar(
              width: 0.6,
              alpha: 0.8,
              borderRadius: BorderRadius.circular(4),
              borderWidth: 1.0,
            )
            .scaleXOrdinal()
            .scaleYContinuous();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });
    });

    group('Themes', () {
      test('should apply default theme', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint()
            .theme(ChartTheme.defaultTheme());

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should apply dark theme', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint()
            .theme(ChartTheme.darkTheme());

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should apply solarized themes', () {
        final lightChart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint()
            .theme(ChartTheme.solarizedLightTheme());

        final darkChart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint()
            .theme(ChartTheme.solarizedDarkTheme());

        expect(lightChart, isNotNull);
        expect(darkChart, isNotNull);
        expect(lightChart.build(), isA<Widget>());
        expect(darkChart.build(), isA<Widget>());
      });
    });

    group('Animations', () {
      test('should apply animation properties', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint()
            .animate(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
            );

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should handle different animation curves', () {
        final charts = [
          Curves.easeInOut,
          Curves.bounceOut,
          Curves.elasticOut,
          Curves.easeOutBack,
        ]
            .map(
              (curve) => CristalyseChart()
                  .data(sampleData)
                  .mapping(x: 'x', y: 'y')
                  .geomLine()
                  .animate(
                    duration: const Duration(milliseconds: 500),
                    curve: curve,
                  )
                  .build(),
            )
            .toList();

        expect(charts.length, equals(4));
        for (final chart in charts) {
          expect(chart, isA<Widget>());
        }
      });
    });

    group('Pie Charts', () {
      late List<Map<String, dynamic>> pieData;

      setUp(() {
        pieData = [
          {'category': 'Mobile', 'revenue': 45.2, 'users': 1200},
          {'category': 'Desktop', 'revenue': 32.8, 'users': 800},
          {'category': 'Tablet', 'revenue': 22.0, 'users': 600},
        ];
      });

      test('should create basic pie chart', () {
        final chart = CristalyseChart()
            .data(pieData)
            .mappingPie(value: 'revenue', category: 'category')
            .geomPie();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create donut chart', () {
        final chart = CristalyseChart()
            .data(pieData)
            .mappingPie(value: 'users', category: 'category')
            .geomPie(
              innerRadius: 40.0,
              outerRadius: 120.0,
              strokeWidth: 2.0,
            );

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should create pie chart with custom styling', () {
        final chart = CristalyseChart()
            .data(pieData)
            .mappingPie(value: 'revenue', category: 'category')
            .geomPie(
              outerRadius: 150.0,
              strokeWidth: 3.0,
              strokeColor: Colors.white,
              showLabels: true,
              showPercentages: true,
              explodeSlices: true,
              explodeDistance: 15.0,
            );

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should handle empty pie data', () {
        final chart = CristalyseChart()
            .data([])
            .mappingPie(value: 'revenue', category: 'category')
            .geomPie();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should handle missing pie mapping columns', () {
        final chart = CristalyseChart()
            .data(pieData)
            .mappingPie(value: 'nonexistent', category: 'category')
            .geomPie();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });
    });

    group('Combined Visualizations', () {
      test('should combine multiple geometries', () {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y', color: 'category')
            .geomLine(strokeWidth: 2.0, alpha: 0.8)
            .geomPoint(size: 6.0, alpha: 1.0)
            .scaleXContinuous()
            .scaleYContinuous();

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });

      test('should combine bars and lines with dual Y-axis', () {
        final chart = CristalyseChart()
            .data(dualAxisData)
            .mapping(x: 'month', y: 'revenue')
            .mappingY2('conversion_rate')
            .geomBar(yAxis: YAxis.primary, alpha: 0.7)
            .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0)
            .geomPoint(yAxis: YAxis.secondary, size: 8.0)
            .scaleXOrdinal()
            .scaleYContinuous(min: 0)
            .scaleY2Continuous(min: 0, max: 30);

        expect(chart, isNotNull);
        final widget = chart.build();
        expect(widget, isA<Widget>());
      });
    });
  });

  group('LinearScale', () {
    test('should scale values correctly', () {
      final scale = LinearScale();
      scale.domain = [0, 10];
      scale.range = [0, 100];

      expect(scale.scale(5), equals(50));
      expect(scale.scale(0), equals(0));
      expect(scale.scale(10), equals(100));
    });

    test('should handle custom limits', () {
      final scale = LinearScale(limits: (-5, 15));
      scale.range = [0, 200];
      scale.setBounds([0, 10], null, []);

      expect(scale.scale(0), equals(50));
      expect(scale.scale(10), equals(150));
    });

    test('should generate ticks', () {
      final scale = LinearScale();
      scale.range = [0, 100]; // Set screen range BEFORE setBounds
      scale.setBounds([0, 5, 10], null, []); // Sets domain and computes ticks

      final ticks = scale.getTicks();
      // Wilkinson determines optimal number based on density
      expect(ticks.length, greaterThanOrEqualTo(2));
      expect(ticks.length, lessThanOrEqualTo(10));
      // Should cover the domain
      expect(ticks.first, lessThanOrEqualTo(0));
      expect(ticks.last, greaterThanOrEqualTo(10));
    });

    test('should handle edge cases', () {
      final scale = LinearScale();
      scale.domain = [5, 5]; // Same min and max
      scale.range = [0, 100];

      expect(scale.scale(5), equals(0)); // Should not crash
    });
  });

  group('OrdinalScale', () {
    test('should scale categorical values', () {
      final scale = OrdinalScale();
      scale.domain = ['A', 'B', 'C'];
      scale.range = [0, 300];

      expect(scale.scale('A'), greaterThanOrEqualTo(0));
      expect(scale.scale('B'), greaterThan(scale.scale('A')));
      expect(scale.scale('C'), greaterThan(scale.scale('B')));
    });

    test('should calculate band width', () {
      final scale = OrdinalScale();
      scale.domain = ['Q1', 'Q2', 'Q3', 'Q4'];
      scale.range = [0, 400];

      expect(scale.bandWidth, greaterThan(0));
      expect(scale.bandWidth, lessThan(100)); // Should account for padding
    });

    test('should center bands correctly', () {
      final scale = OrdinalScale();
      scale.domain = ['A', 'B'];
      scale.range = [0, 200];

      final centerA = scale.bandCenter('A');
      final centerB = scale.bandCenter('B');

      expect(centerA, greaterThan(scale.scale('A')));
      expect(centerB, greaterThan(scale.scale('B')));
      expect(centerB, greaterThan(centerA));
    });

    test('should handle empty domain', () {
      final scale = OrdinalScale();
      scale.domain = [];
      scale.range = [0, 100];

      expect(scale.bandWidth, equals(0));
      expect(scale.scale('nonexistent'), equals(0));
    });

    test('should generate categorical ticks', () {
      final scale = OrdinalScale();
      scale.domain = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
      scale.range = [0, 500]; // Set screen range for proper density calculation

      final ticks = scale.getTicks();
      // Ordinal scales return all domain values when there's enough space
      expect(ticks.length, equals(5));
      expect(ticks.contains('Jan'), isTrue);
      expect(ticks.contains('May'), isTrue);
    });
  });

  group('ColorScale', () {
    test('should map values to colors', () {
      final scale = ColorScale(
        values: ['A', 'B', 'C'],
        colors: [Colors.red, Colors.green, Colors.blue],
      );

      expect(scale.scale('A'), equals(Colors.red));
      expect(scale.scale('B'), equals(Colors.green));
      expect(scale.scale('C'), equals(Colors.blue));
    });

    test('should handle missing values', () {
      final scale = ColorScale(
        values: ['A', 'B'],
        colors: [Colors.red, Colors.green],
      );

      expect(scale.scale('C'), equals(Colors.red)); // Should use first color
    });

    test('should cycle through colors', () {
      final scale = ColorScale(
        values: ['A', 'B', 'C'],
        colors: [Colors.red, Colors.green],
      );

      expect(scale.scale('A'), equals(Colors.red));
      expect(scale.scale('B'), equals(Colors.green));
      expect(scale.scale('C'), equals(Colors.red)); // Should cycle back
    });
  });

  group('SizeScale', () {
    test('should scale numeric values to sizes', () {
      final scale = SizeScale(range: [5, 15]);
      scale.setBounds([0, 10], null, []);

      expect(scale.scale(0), equals(5));
      expect(scale.scale(5), equals(10));
      expect(scale.scale(10), equals(15));
    });

    test('should handle edge cases', () {
      final scale = SizeScale(
        range: [10, 20],
      );
      scale.setBounds([5, 5], null, []); // Same min and max

      expect(scale.scale(5), equals(10)); // Should not crash
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle null/invalid data gracefully', () {
      final invalidData = [
        {'x': null, 'y': 2},
        {'x': 'invalid', 'y': 'also_invalid'},
        {'x': double.nan, 'y': double.infinity},
        {'x': 1, 'y': 2}, // Valid data point
      ];

      final chart = CristalyseChart()
          .data(invalidData)
          .mapping(x: 'x', y: 'y')
          .geomPoint();

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should handle missing columns', () {
      final chart = CristalyseChart()
          .data(sampleData)
          .mapping(x: 'nonexistent', y: 'y')
          .geomPoint();

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should handle mixed data types', () {
      final mixedData = [
        {'x': 1, 'y': 2.5, 'category': 'A'},
        {'x': '2', 'y': '3.5', 'category': 'B'}, // String numbers
        {'x': 3, 'y': 4, 'category': 123}, // Non-string category
      ];

      final chart = CristalyseChart()
          .data(mixedData)
          .mapping(x: 'x', y: 'y', color: 'category')
          .geomPoint();

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should handle extreme values', () {
      final extremeData = [
        {'x': -1000000, 'y': 0.0001},
        {'x': 1000000, 'y': 999999},
        {'x': 0, 'y': 0},
      ];

      final chart = CristalyseChart()
          .data(extremeData)
          .mapping(x: 'x', y: 'y')
          .geomPoint()
          .scaleXContinuous()
          .scaleYContinuous();

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });
  });

  group('Performance and Memory', () {
    test('should handle large datasets', () {
      final largeData = List.generate(
        1000,
        (i) => {
          'x': i.toDouble(),
          'y': (i * 2).toDouble(),
          'category': 'Group${i % 10}',
        },
      );

      final chart = CristalyseChart()
          .data(largeData)
          .mapping(x: 'x', y: 'y', color: 'category')
          .geomPoint(size: 2.0)
          .scaleXContinuous()
          .scaleYContinuous();

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isA<Widget>());
    });

    test('should handle rapid chart recreation', () {
      for (int i = 0; i < 100; i++) {
        final chart = CristalyseChart()
            .data(sampleData)
            .mapping(x: 'x', y: 'y')
            .geomPoint()
            .build();

        expect(chart, isA<Widget>());
      }
    });
  });
}
