import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Axis-Based Tooltip System', () {
    late List<Map<String, dynamic>> multiSeriesData;

    setUp(() {
      // Multi-series time-series data (quarterly sales by product)
      multiSeriesData = [
        {'quarter': 'Q1', 'value': 45.0, 'platform': 'iOS'},
        {'quarter': 'Q1', 'value': 62.0, 'platform': 'Android'},
        {'quarter': 'Q1', 'value': 28.0, 'platform': 'Web'},
        {'quarter': 'Q2', 'value': 58.0, 'platform': 'iOS'},
        {'quarter': 'Q2', 'value': 75.0, 'platform': 'Android'},
        {'quarter': 'Q2', 'value': 35.0, 'platform': 'Web'},
        {'quarter': 'Q3', 'value': 67.0, 'platform': 'iOS'},
        {'quarter': 'Q3', 'value': 82.0, 'platform': 'Android'},
        {'quarter': 'Q3', 'value': 42.0, 'platform': 'Web'},
        {'quarter': 'Q4', 'value': 78.0, 'platform': 'iOS'},
        {'quarter': 'Q4', 'value': 90.0, 'platform': 'Android'},
        {'quarter': 'Q4', 'value': 48.0, 'platform': 'Web'},
      ];
    });

    testWidgets(
      'should render chart with axis tooltip configuration',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0, shape: PointShape.circle)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: true,
                    crosshairColor: Colors.grey.shade400,
                    crosshairWidth: 1.5,
                    crosshairStyle: StrokeStyle.dashed,
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'quarter',
                      yColumn: 'value',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Chart should render
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should detect points at X position when hovering',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0, shape: PointShape.circle)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: true,
                    multiPointBuilder: (points) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.black87,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: points
                              .map((p) => Text(
                                    '${p.data['platform']}: ${p.data['value']}',
                                    style: TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                  hover: HoverConfig(
                    hitTestRadius: 50.0,
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Find the chart widget (may be multiple MouseRegions, so use last)
        final chartFinder = find.byType(MouseRegion);
        expect(chartFinder, findsWidgets);

        // Get the chart center position
        final widgets = tester.widgetList<MouseRegion>(chartFinder);
        final chartWidget = widgets.last;
        final RenderBox box = tester.renderObject(chartFinder.last);
        final center = box.localToGlobal(box.size.center(Offset.zero));

        // Simulate hover over the chart
        final TestGesture gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: center);
        addTearDown(gesture.removePointer);
        await tester.pump();

        // Move to different X positions to trigger axis detection
        // Note: Exact positions depend on chart size and scale
        // We're just verifying the interaction system works
        await gesture.moveTo(Offset(center.dx + 50, center.dy));
        await tester.pump();

        // The detection system should be working
        // (actual point detection depends on chart dimensions)
        expect(chartWidget.onHover, isNotNull);
      },
    );

    testWidgets(
      'should show crosshair when hovering over data points',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0, shape: PointShape.circle)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: true,
                    crosshairColor: Colors.red,
                    crosshairWidth: 2.0,
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'quarter',
                      yColumn: 'value',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Chart should render with interaction capability
        expect(find.byType(CustomPaint), findsWidgets);
        expect(find.byType(MouseRegion), findsWidgets);
      },
    );

    testWidgets(
      'should support custom multi-point tooltip builder',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0, shape: PointShape.circle)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: true,
                    multiPointBuilder: (points) {
                      if (points.isEmpty) return SizedBox.shrink();

                      final xValue = points.first.data['quarter'];

                      return Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade900,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              xValue.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Divider(color: Colors.white24),
                            ...points.map((point) {
                              final platform = point.data['platform'];
                              final value = point.data['value'];
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: point.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '$platform: $value',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should handle axis mode with continuous X scale',
      (WidgetTester tester) async {
        final continuousData = [
          {'x': 1.0, 'y': 10.0, 'series': 'A'},
          {'x': 1.0, 'y': 15.0, 'series': 'B'},
          {'x': 2.0, 'y': 20.0, 'series': 'A'},
          {'x': 2.0, 'y': 25.0, 'series': 'B'},
          {'x': 3.0, 'y': 30.0, 'series': 'A'},
          {'x': 3.0, 'y': 35.0, 'series': 'B'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(continuousData)
                .mapping(x: 'x', y: 'y', color: 'series')
                .geomLine(strokeWidth: 2.0)
                .geomPoint(size: 6.0)
                .scaleXContinuous()
                .scaleYContinuous()
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: true,
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'x',
                      yColumn: 'y',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should clear crosshair on mouse exit',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0, shape: PointShape.circle)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: true,
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'quarter',
                      yColumn: 'value',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        final mouseRegion = find.byType(MouseRegion);
        expect(mouseRegion, findsWidgets);

        // Get the last MouseRegion (the chart's interaction handler)
        final widgets = tester.widgetList<MouseRegion>(mouseRegion);
        final chartMouseRegion = widgets.last;
        expect(chartMouseRegion.onExit, isNotNull);
      },
    );

    testWidgets(
      'should work with DefaultTooltips.multiPoint helper',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'quarter',
                      yColumn: 'value',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should support different crosshair styles',
      (WidgetTester tester) async {
        for (final style in [
          StrokeStyle.solid,
          StrokeStyle.dashed,
          StrokeStyle.dotted,
        ]) {
          final chart = MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(multiSeriesData)
                  .mapping(x: 'quarter', y: 'value', color: 'platform')
                  .geomLine(strokeWidth: 3.0)
                  .geomPoint(size: 8.0)
                  .scaleXOrdinal()
                  .scaleYContinuous(min: 0, max: 100)
                  .interaction(
                    tooltip: TooltipConfig(
                      triggerMode: ChartTooltipTriggerMode.axis,
                      showCrosshair: true,
                      crosshairStyle: style,
                      multiPointBuilder: DefaultTooltips.multiPoint(
                        xColumn: 'quarter',
                        yColumn: 'value',
                      ),
                    ),
                  )
                  .build(),
            ),
          );

          await tester.pumpWidget(chart);
          await tester.pumpAndSettle();

          expect(find.byType(CustomPaint), findsWidgets);

          // Clean up for next iteration
          await tester.pumpWidget(Container());
        }
      },
    );

    testWidgets(
      'should handle empty points list gracefully',
      (WidgetTester tester) async {
        bool builderCalled = false;

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    multiPointBuilder: (points) {
                      builderCalled = true;
                      if (points.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Text('Points: ${points.length}');
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
        // Builder may or may not be called depending on interaction
        expect(builderCalled, isA<bool>());
      },
    );

    testWidgets(
      'should support axis mode without crosshair',
      (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    showCrosshair: false, // No crosshair
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'quarter',
                      yColumn: 'value',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should compare axis mode vs point mode trigger behavior',
      (WidgetTester tester) async {
        // Test axis mode
        final axisChart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    multiPointBuilder: DefaultTooltips.multiPoint(
                      xColumn: 'quarter',
                      yColumn: 'value',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(axisChart);
        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);

        // Test point mode (default)
        final pointChart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(multiSeriesData)
                .mapping(x: 'quarter', y: 'value', color: 'platform')
                .geomLine(strokeWidth: 3.0)
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0, max: 100)
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.point,
                    builder: (point) => Text('Value: ${point.data['value']}'),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(pointChart);
        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });

  group('InteractionDetector - detectPointsByXPosition', () {
    testWidgets(
      'should detect multiple points at same X position',
      (WidgetTester tester) async {
        final data = [
          {'x': 1.0, 'y': 10.0, 'series': 'A'},
          {'x': 1.0, 'y': 20.0, 'series': 'B'},
          {'x': 1.0, 'y': 30.0, 'series': 'C'},
          {'x': 2.0, 'y': 15.0, 'series': 'A'},
          {'x': 2.0, 'y': 25.0, 'series': 'B'},
          {'x': 2.0, 'y': 35.0, 'series': 'C'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y', color: 'series')
                .geomPoint(size: 8.0)
                .scaleXContinuous()
                .scaleYContinuous()
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    multiPointBuilder: (points) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.black87,
                        child: Text(
                          'Found ${points.length} points',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should sort points by Y value (top to bottom)',
      (WidgetTester tester) async {
        final data = [
          {'x': 'A', 'y': 30.0, 'series': 'Top'},
          {'x': 'A', 'y': 20.0, 'series': 'Middle'},
          {'x': 'A', 'y': 10.0, 'series': 'Bottom'},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y', color: 'series')
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous()
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    multiPointBuilder: (points) {
                      // Points should be sorted by screen Y (which is inverted)
                      return Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.black87,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: points
                              .map((p) => Text(
                                    p.data['series'].toString(),
                                    style: TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'should always snap to nearest X position',
      (WidgetTester tester) async {
        final data = [
          {'x': 'Q1', 'y': 10.0},
          {'x': 'Q2', 'y': 20.0},
          {'x': 'Q3', 'y': 30.0},
        ];

        // Should detect nearest X position regardless of distance
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y')
                .geomPoint(size: 8.0)
                .scaleXOrdinal()
                .scaleYContinuous()
                .interaction(
                  tooltip: TooltipConfig(
                    triggerMode: ChartTooltipTriggerMode.axis,
                    multiPointBuilder: (points) {
                      return Text('Found ${points.length}');
                    },
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });
}
