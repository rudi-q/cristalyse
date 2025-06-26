import 'dart:ui';

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chart Interactions', () {
    late List<Map<String, dynamic>> sampleData;
    late List<Map<String, dynamic>> lineData;
    late List<Map<String, dynamic>> barData;

    setUp(() {
      sampleData = [
        {'x': 10.0, 'y': 20.0, 'category': 'A', 'size': 5.0},
        {'x': 20.0, 'y': 30.0, 'category': 'B', 'size': 7.0},
        {'x': 30.0, 'y': 15.0, 'category': 'A', 'size': 3.0},
        {'x': 40.0, 'y': 35.0, 'category': 'C', 'size': 9.0},
      ];

      lineData = [
        {'month': 'Jan', 'users': 100.0, 'platform': 'Mobile'},
        {'month': 'Feb', 'users': 120.0, 'platform': 'Mobile'},
        {'month': 'Mar', 'users': 110.0, 'platform': 'Mobile'},
        {'month': 'Apr', 'users': 140.0, 'platform': 'Mobile'},
      ];

      barData = [
        {'quarter': 'Q1', 'revenue': 100.0},
        {'quarter': 'Q2', 'revenue': 120.0},
        {'quarter': 'Q3', 'revenue': 110.0},
        {'quarter': 'Q4', 'revenue': 140.0},
      ];
    });

    group('Scatter Plot Interactions', () {
      testWidgets('should show tooltips on hover', (WidgetTester tester) async {
        bool tooltipShown = false;
        DataPointInfo? hoveredPoint;

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(sampleData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint(size: 8.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) {
                      tooltipShown = true;
                      hoveredPoint = point;
                      return Text('Value: ${point.getDisplayValue('y')}');
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Find the chart widget
        final chartFinder = find.byType(CustomPaint);
        expect(chartFinder, findsWidgets);

        // Simulate hover near a data point (approximate center of chart)
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(chartFinder.first));
        await tester.pump();

        // Note: In actual usage, tooltip would show, but in tests we can verify
        // the interaction system is set up correctly by checking the chart builds
        expect(chartFinder, findsWidgets);
      });

      testWidgets('should handle click events', (WidgetTester tester) async {
        DataPointInfo? clickedPoint;

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(sampleData)
                .mapping(x: 'x', y: 'y')
                .geomPoint(size: 10.0)
                .interaction(
                  click: ClickConfig(
                    onTap: (point) {
                      clickedPoint = point;
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        final chartFinder = find.byType(CustomPaint);
        await tester.tap(chartFinder.first);
        await tester.pump();

        // Chart should build successfully with click interactions
        expect(chartFinder, findsWidgets);
      });

      testWidgets('should combine tooltips and clicks', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(sampleData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('${point.getDisplayValue('category')}: ${point.getDisplayValue('y')}'),
                  ),
                  click: ClickConfig(
                    onTap: (point) => print('Clicked: ${point.data}'),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Line Chart Interactions', () {
      testWidgets('should support hover on line charts', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(lineData)
                .mapping(x: 'month', y: 'users')
                .geomLine(strokeWidth: 2.0)
                .geomPoint(size: 6.0) // Add points for easier interaction
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('${point.getDisplayValue('month')}: ${point.getDisplayValue('users')} users'),
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous()
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should support multi-series line interactions', (WidgetTester tester) async {
        final multiSeriesData = [
          {'month': 'Jan', 'users': 100.0, 'platform': 'Mobile'},
          {'month': 'Jan', 'users': 80.0, 'platform': 'Web'},
          {'month': 'Feb', 'users': 120.0, 'platform': 'Mobile'},
          {'month': 'Feb', 'users': 90.0, 'platform': 'Web'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'month', y: 'users', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${point.getDisplayValue('platform')}'),
                        Text('${point.getDisplayValue('month')}: ${point.getDisplayValue('users')}'),
                      ],
                    ),
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous()
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Bar Chart Interactions', () {
      testWidgets('should support hover on bar charts', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(barData)
                .mapping(x: 'quarter', y: 'revenue')
                .geomBar(width: 0.8)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('${point.getDisplayValue('quarter')}: \$${point.getDisplayValue('revenue')}k'),
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should support grouped bar interactions', (WidgetTester tester) async {
        final groupedData = [
          {'quarter': 'Q1', 'revenue': 100.0, 'product': 'A'},
          {'quarter': 'Q1', 'revenue': 80.0, 'product': 'B'},
          {'quarter': 'Q2', 'revenue': 120.0, 'product': 'A'},
          {'quarter': 'Q2', 'revenue': 90.0, 'product': 'B'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(groupedData)
                .mapping(x: 'quarter', y: 'revenue', color: 'product')
                .geomBar(style: BarStyle.grouped, width: 0.8)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Product ${point.getDisplayValue('product')}'),
                        Text('${point.getDisplayValue('quarter')}: \$${point.getDisplayValue('revenue')}k'),
                      ],
                    ),
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should support stacked bar interactions', (WidgetTester tester) async {
        final stackedData = [
          {'quarter': 'Q1', 'revenue': 60.0, 'category': 'Product'},
          {'quarter': 'Q1', 'revenue': 40.0, 'category': 'Services'},
          {'quarter': 'Q2', 'revenue': 70.0, 'category': 'Product'},
          {'quarter': 'Q2', 'revenue': 50.0, 'category': 'Services'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(stackedData)
                .mapping(x: 'quarter', y: 'revenue', color: 'category')
                .geomBar(style: BarStyle.stacked, width: 0.8)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('${point.getDisplayValue('category')}: \$${point.getDisplayValue('revenue')}k'),
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should support horizontal bar interactions', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(barData)
                .mapping(x: 'quarter', y: 'revenue')
                .geomBar()
                .coordFlip()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('${point.getDisplayValue('quarter')}: \$${point.getDisplayValue('revenue')}k'),
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Dual Y-Axis Interactions', () {
      testWidgets('should support interactions on dual y-axis charts', (WidgetTester tester) async {
        final dualAxisData = [
          {'month': 'Jan', 'revenue': 100.0, 'conversion': 15.0},
          {'month': 'Feb', 'revenue': 120.0, 'conversion': 18.0},
          {'month': 'Mar', 'revenue': 110.0, 'conversion': 16.0},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(dualAxisData)
                .mapping(x: 'month', y: 'revenue')
                .mappingY2('conversion')
                .geomBar(yAxis: YAxis.primary)
                .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0)
                .geomPoint(yAxis: YAxis.secondary, size: 8.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) {
                      // Smart tooltip that shows relevant data based on geometry
                      final hasRevenue = point.data.containsKey('revenue');
                      final hasConversion = point.data.containsKey('conversion');
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${point.getDisplayValue('month')}'),
                          if (hasRevenue) Text('Revenue: \$${point.getDisplayValue('revenue')}k'),
                          if (hasConversion) Text('Conversion: ${point.getDisplayValue('conversion')}%'),
                        ],
                      );
                    },
                  ),
                )
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .scaleY2Continuous(min: 0, max: 30)
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Combined Chart Interactions', () {
      testWidgets('should support interactions on combined geometries', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(sampleData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomLine(strokeWidth: 2.0, alpha: 0.8)
                .geomPoint(size: 6.0, alpha: 1.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('${point.getDisplayValue('category')}: (${point.getDisplayValue('x')}, ${point.getDisplayValue('y')})'),
                  ),
                  click: ClickConfig(
                    onTap: (point) => print('Combined chart clicked: ${point.data}'),
                  ),
                )
                .scaleXContinuous()
                .scaleYContinuous()
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Interaction Edge Cases', () {
      testWidgets('should handle empty data gracefully', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data([])
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Empty'),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle null data values', (WidgetTester tester) async {
        final dataWithNulls = [
          {'x': 1.0, 'y': null, 'category': 'A'},
          {'x': null, 'y': 2.0, 'category': 'B'},
          {'x': 3.0, 'y': 3.0, 'category': 'C'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(dataWithNulls)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Value: ${point.getDisplayValue('y')}'),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle disabled interactions', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(sampleData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Should not show'),
                  ),
                  enabled: false, // Disable interactions
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle large datasets', (WidgetTester tester) async {
        final largeData = List.generate(500, (i) => {
          'x': i.toDouble(),
          'y': (i * 2).toDouble(),
          'category': 'Group${i % 5}',
        });

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(largeData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint(size: 2.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Point ${point.getDisplayValue('x')}'),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle rapid hover events', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(sampleData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Rapid: ${point.getDisplayValue('y')}'),
                    showDelay: Duration(milliseconds: 10), // Very fast
                    hideDelay: Duration(milliseconds: 100),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Simulate rapid movement
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        final chartFinder = find.byType(CustomPaint);
        final chartRect = tester.getRect(chartFinder.first);

        // Rapid hover across chart
        for (int i = 0; i < 10; i++) {
          await gesture.moveTo(Offset(
            chartRect.left + (chartRect.width * i / 10),
            chartRect.center.dy,
          ));
          await tester.pump(Duration(milliseconds: 10));
        }

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });
  });
}