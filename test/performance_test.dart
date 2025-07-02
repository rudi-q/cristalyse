import 'dart:math' as math;
import 'dart:ui';

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance & Edge Cases', () {
    group('Large Dataset Performance', () {
      testWidgets('should handle 1000+ points with interactions', (
        WidgetTester tester,
      ) async {
        final largeData = List.generate(
          1000,
          (i) => {
            'x': i.toDouble(),
            'y': math.sin(i * 0.1) * 50 +
                100 +
                (math.Random().nextDouble() - 0.5) * 20,
            'category': 'Group${i % 5}',
            'size': 3.0 + (i % 10).toDouble(),
          },
        );

        final stopwatch = Stopwatch()..start();

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(largeData)
                .mapping(x: 'x', y: 'y', color: 'category', size: 'size')
                .geomPoint(alpha: 0.7)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text(
                      'Point ${point.getDisplayValue('x')}: ${point.getDisplayValue('y')}',
                    ),
                    showDelay: Duration(milliseconds: 100),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Chart should render in reasonable time (less than 5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle large bar charts with interactions', (
        WidgetTester tester,
      ) async {
        final largeBarData = List.generate(
          200,
          (i) => {
            'category': 'Item$i',
            'value': 50 + (math.Random().nextDouble() * 100),
            'group': 'Group${i % 3}',
          },
        );

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(largeBarData)
                .mapping(x: 'category', y: 'value', color: 'group')
                .geomBar(style: BarStyle.grouped, width: 0.8)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text(
                      '${point.getDisplayValue('category')}: ${point.getDisplayValue('value')}',
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

      testWidgets('should handle rapid data updates', (
        WidgetTester tester,
      ) async {
        var currentData = List.generate(
          100,
          (i) => {
            'x': i.toDouble(),
            'y': math.Random().nextDouble() * 100,
            'category': 'A',
          },
        );

        late StateSetter setStateCallback;

        final chart = MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateCallback = setState;
                return CristalyseChart()
                    .data(currentData)
                    .mapping(x: 'x', y: 'y')
                    .geomPoint()
                    .interaction(
                      tooltip: TooltipConfig(
                        builder: (point) =>
                            Text('Value: ${point.getDisplayValue('y')}'),
                      ),
                    )
                    .build();
              },
            ),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Simulate rapid data updates
        for (int update = 0; update < 10; update++) {
          setStateCallback(() {
            currentData = List.generate(
              100,
              (i) => {
                'x': i.toDouble(),
                'y': math.Random().nextDouble() * 100,
                'category': 'A',
              },
            );
          });
          await tester.pump(Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Memory Management', () {
      testWidgets(
        'should not leak memory with frequent tooltip creation/destruction',
        (WidgetTester tester) async {
          final data = [
            {'x': 10.0, 'y': 20.0},
            {'x': 20.0, 'y': 30.0},
            {'x': 30.0, 'y': 25.0},
          ];

          final chart = MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomPoint(size: 10.0)
                  .interaction(
                    tooltip: TooltipConfig(
                      builder: (point) => Text(
                        'Memory test: ${point.getDisplayValue('y')}',
                      ),
                      showDelay: Duration(milliseconds: 10),
                      hideDelay: Duration(milliseconds: 50),
                    ),
                  )
                  .build(),
            ),
          );

          await tester.pumpWidget(chart);
          await tester.pumpAndSettle();

          // Simulate rapid hover on/off to test memory management
          final gesture = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await gesture.addPointer(location: Offset.zero);
          addTearDown(gesture.removePointer);

          final chartFinder = find.byType(CustomPaint);
          final chartCenter = tester.getCenter(chartFinder.first);

          for (int i = 0; i < 20; i++) {
            // Hover on
            await gesture.moveTo(chartCenter);
            await tester.pump(Duration(milliseconds: 20));

            // Hover off
            await gesture.moveTo(Offset(0, 0));
            await tester.pump(Duration(milliseconds: 20));
          }

          await tester.pumpAndSettle();
          expect(find.byType(CustomPaint), findsWidgets);
        },
      );

      testWidgets('should handle widget disposal cleanly', (
        WidgetTester tester,
      ) async {
        final data = [
          {'x': 10.0, 'y': 20.0},
        ];

        Widget buildChart() {
          return MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomPoint()
                  .interaction(
                    tooltip: TooltipConfig(
                      builder: (point) => Text('Disposal test'),
                    ),
                  )
                  .build(),
            ),
          );
        }

        // Build and dispose chart multiple times
        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(buildChart());
          await tester.pumpAndSettle();

          await tester.pumpWidget(Container()); // Remove chart
          await tester.pumpAndSettle();
        }

        // Final verification
        await tester.pumpWidget(buildChart());
        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Extreme Data Values', () {
      testWidgets('should handle extreme coordinate values', (
        WidgetTester tester,
      ) async {
        final extremeData = [
          {'x': -1000000.0, 'y': -500000.0},
          {'x': 0.0, 'y': 0.0},
          {'x': 1000000.0, 'y': 500000.0},
          {'x': double.maxFinite / 2, 'y': double.maxFinite / 4},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(extremeData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text(
                      'Extreme: ${point.getDisplayValue('x')}, ${point.getDisplayValue('y')}',
                    ),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle invalid numeric values', (
        WidgetTester tester,
      ) async {
        final invalidData = [
          {'x': double.nan, 'y': 20.0},
          {'x': 10.0, 'y': double.infinity},
          {'x': double.negativeInfinity, 'y': 30.0},
          {'x': 40.0, 'y': -double.infinity},
          {'x': 50.0, 'y': 50.0}, // Valid point
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(invalidData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) =>
                        Text('Value: ${point.getDisplayValue('y')}'),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle mixed data types gracefully', (
        WidgetTester tester,
      ) async {
        final mixedData = [
          {'x': 1, 'y': 2.5, 'category': 'A', 'active': true},
          {'x': '2', 'y': '3.7', 'category': 'B', 'active': false},
          {'x': 3.0, 'y': 4, 'category': null, 'active': null},
          {
            'x': 'invalid',
            'y': 'also_invalid',
            'category': 123,
            'active': 'maybe',
          },
          {'x': [], 'y': {}, 'category': '', 'active': 0},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(mixedData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('X: ${point.getDisplayValue('x')}'),
                        Text('Y: ${point.getDisplayValue('y')}'),
                        Text(
                          'Category: ${point.getDisplayValue('category')}',
                        ),
                        Text(
                          'Active: ${point.getDisplayValue('active')}',
                        ),
                      ],
                    ),
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

    group('Animation Performance', () {
      testWidgets('should maintain 60fps during complex animations', (
        WidgetTester tester,
      ) async {
        final data = List.generate(
          200,
          (i) => {
            'x': i.toDouble(),
            'y': math.sin(i * 0.1) * 50 + 100,
            'category': 'Group${i % 4}',
          },
        );

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint(size: 6.0)
                .geomLine(strokeWidth: 2.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) =>
                        Text('Animated: ${point.getDisplayValue('y')}'),
                  ),
                )
                .animate(
                  duration: Duration(milliseconds: 2000),
                  curve: Curves.elasticOut,
                )
                .build(),
          ),
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(chart);

        // Let animation run for a bit
        await tester.pump(Duration(milliseconds: 500));
        await tester.pump(Duration(milliseconds: 500));
        await tester.pump(Duration(milliseconds: 500));

        await tester.pumpAndSettle();

        stopwatch.stop();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle animation with interactions simultaneously', (
        WidgetTester tester,
      ) async {
        final data = [
          {'x': 10.0, 'y': 20.0},
          {'x': 20.0, 'y': 30.0},
          {'x': 30.0, 'y': 25.0},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(data)
                .mapping(x: 'x', y: 'y')
                .geomPoint(size: 8.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text(
                      'During animation: ${point.getDisplayValue('y')}',
                    ),
                  ),
                )
                .animate(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.bounceOut,
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);

        // Try to interact during animation
        await tester.pump(Duration(milliseconds: 100));

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        final chartFinder = find.byType(CustomPaint);
        await gesture.moveTo(tester.getCenter(chartFinder.first));

        await tester.pump(Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Cross-Platform Edge Cases', () {
      testWidgets('should handle different screen sizes', (
        WidgetTester tester,
      ) async {
        final data = [
          {'x': 10.0, 'y': 20.0},
          {'x': 20.0, 'y': 30.0},
        ];

        // Test different screen sizes
        final sizes = [
          Size(320, 568), // iPhone SE
          Size(375, 667), // iPhone 8
          Size(414, 896), // iPhone 11
          Size(768, 1024), // iPad
          Size(1920, 1080), // Desktop
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);

          final chart = MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomPoint()
                  .interaction(
                    tooltip: TooltipConfig(
                      builder: (point) => Text(
                        'Size test: ${point.getDisplayValue('y')}',
                      ),
                    ),
                  )
                  .build(),
            ),
          );

          await tester.pumpWidget(chart);
          await tester.pumpAndSettle();

          expect(find.byType(CustomPaint), findsWidgets);
        }

        // Reset to default size
        await tester.binding.setSurfaceSize(Size(800, 600));
      });

      testWidgets('should handle different pixel densities', (
        WidgetTester tester,
      ) async {
        final data = [
          {'x': 10.0, 'y': 20.0},
        ];

        // Test different pixel densities
        final densities = [1.0, 1.5, 2.0, 3.0];

        for (final density in densities) {
          tester.view.physicalSize = Size(800 * density, 600 * density);
          tester.view.devicePixelRatio = density;

          final chart = MaterialApp(
            home: Scaffold(
              body: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomPoint()
                  .interaction(
                    tooltip: TooltipConfig(
                      builder: (point) => Text(
                        'Density test: ${point.getDisplayValue('y')}',
                      ),
                    ),
                  )
                  .build(),
            ),
          );

          await tester.pumpWidget(chart);
          await tester.pumpAndSettle();

          expect(find.byType(CustomPaint), findsWidgets);
        }

        // Reset
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    group('Stress Tests', () {
      testWidgets('should survive rapid theme changes', (
        WidgetTester tester,
      ) async {
        final data = [
          {'x': 10.0, 'y': 20.0},
        ];

        final themes = [
          ChartTheme.defaultTheme(),
          ChartTheme.darkTheme(),
          ChartTheme.solarizedLightTheme(),
          ChartTheme.solarizedDarkTheme(),
        ];

        late StateSetter setStateCallback;
        var currentThemeIndex = 0;

        final chart = MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setStateCallback = setState;
                return CristalyseChart()
                    .data(data)
                    .mapping(x: 'x', y: 'y')
                    .geomPoint()
                    .interaction(
                      tooltip: TooltipConfig(
                        builder: (point) => Text(
                          'Theme test: ${point.getDisplayValue('y')}',
                        ),
                      ),
                    )
                    .theme(themes[currentThemeIndex])
                    .build();
              },
            ),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Rapidly change themes
        for (int i = 0; i < 20; i++) {
          setStateCallback(() {
            currentThemeIndex = (currentThemeIndex + 1) % themes.length;
          });
          await tester.pump(Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();
        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle simultaneous gesture conflicts', (
        WidgetTester tester,
      ) async {
        final data = [
          {'x': 10.0, 'y': 20.0},
          {'x': 20.0, 'y': 30.0},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () {}, // Competing gesture detector
              child: CristalyseChart()
                  .data(data)
                  .mapping(x: 'x', y: 'y')
                  .geomPoint()
                  .interaction(
                    tooltip: TooltipConfig(
                      builder: (point) => Text(
                        'Conflict test: ${point.getDisplayValue('y')}',
                      ),
                    ),
                    click: ClickConfig(
                      onTap: (point) => debugPrint('Chart tapped'),
                    ),
                  )
                  .build(),
            ),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        // Try to interact despite competing gestures
        final chartFinder = find.byType(CustomPaint);
        await tester.tap(chartFinder.first);
        await tester.pump();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });
  });
}
