import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cristalyse/cristalyse.dart';

void main() {
  group('Bubble Size Scaling - Critical Tests', () {
    test('SizeScale should properly map data values to pixel sizes', () {
      // This is the CORE test - if this fails, bubbles won't scale correctly
      final sizeScale = SizeScale(
        domain: [5.0, 35.0], // Data range: 5% to 35% market share
        range: [8.0, 25.0], // Pixel range: 8px to 25px radius
      );

      // Test exact mappings
      expect(sizeScale.scale(5.0), equals(8.0),
          reason: 'Min value (5%) should map to min size (8px)');
      expect(sizeScale.scale(35.0), equals(25.0),
          reason: 'Max value (35%) should map to max size (25px)');

      // Test intermediate values - should be linear
      expect(sizeScale.scale(20.0), closeTo(16.5, 0.1),
          reason:
              '20% is halfway between 5% and 35%, so should map to ~16.5px');
      expect(sizeScale.scale(10.0), closeTo(10.83, 0.1),
          reason: '10% should map to about 10.83px');
      expect(sizeScale.scale(30.0), closeTo(22.17, 0.1),
          reason: '30% should map to about 22.17px');

      // Verify relative sizes are correct
      final size5 = sizeScale.scale(5.0);
      final size10 = sizeScale.scale(10.0);
      final size20 = sizeScale.scale(20.0);
      final size30 = sizeScale.scale(30.0);
      final size35 = sizeScale.scale(35.0);

      expect(size10 > size5, isTrue, reason: '10% must be bigger than 5%');
      expect(size20 > size10, isTrue, reason: '20% must be bigger than 10%');
      expect(size30 > size20, isTrue, reason: '30% must be bigger than 20%');
      expect(size35 > size30, isTrue, reason: '35% must be bigger than 30%');

      // Verify proportional differences
      final diff1 = size10 - size5; // 5% to 10% = 5% difference
      final diff2 = size20 - size10; // 10% to 20% = 10% difference
      final diff3 = size30 - size20; // 20% to 30% = 10% difference

      expect(diff2, closeTo(diff3, 0.1),
          reason:
              'Equal data differences should produce equal size differences');
      expect(diff2, closeTo(diff1 * 2, 0.2),
          reason: '10% difference should be about 2x a 5% difference');
    });

    test('Bubble chart data should produce correct size scale setup', () {
      // Test with realistic bubble chart data
      final marketData = [
        {
          'company': 'Small Co',
          'revenue': 50.0,
          'customers': 100.0,
          'marketShare': 8.0
        },
        {
          'company': 'Med Co',
          'revenue': 100.0,
          'customers': 150.0,
          'marketShare': 15.0
        },
        {
          'company': 'Large Co',
          'revenue': 200.0,
          'customers': 120.0,
          'marketShare': 35.0
        },
        {
          'company': 'Tiny Co',
          'revenue': 30.0,
          'customers': 80.0,
          'marketShare': 5.0
        },
      ];

      // Extract market share values
      final marketShares =
          marketData.map((d) => d['marketShare'] as double).toList();
      final minShare = marketShares.reduce((a, b) => a < b ? a : b);
      final maxShare = marketShares.reduce((a, b) => a > b ? a : b);

      expect(minShare, equals(5.0));
      expect(maxShare, equals(35.0));

      // Create size scale with reasonable bubble sizes
      final bubbleMinSize = 8.0; // Minimum radius in pixels
      final bubbleMaxSize = 25.0; // Maximum radius in pixels

      final sizeScale = SizeScale(
        domain: [minShare, maxShare],
        range: [bubbleMinSize, bubbleMaxSize],
      );

      // Verify each company gets appropriate size
      expect(sizeScale.scale(5.0), equals(8.0),
          reason: 'Tiny Co (5%) should get minimum size');
      expect(sizeScale.scale(35.0), equals(25.0),
          reason: 'Large Co (35%) should get maximum size');
      expect(sizeScale.scale(15.0), closeTo(13.67, 0.1),
          reason: 'Med Co (15%) should get proportional size');
      expect(sizeScale.scale(8.0), closeTo(9.7, 0.1),
          reason: 'Small Co (8%) should be slightly bigger than minimum');
    });
  });

  group('Bubble Chart Example Fix', () {
    test('Example data should produce properly scaled bubbles', () {
      // This is the EXACT data from bubble_chart_example.dart
      final exampleData = [
        {
          'company': 'TechCorp',
          'revenue': 120.0,
          'customers': 150.0,
          'marketShare': 15.0,
          'category': 'Technology'
        },
        {
          'company': 'FinanceInc',
          'revenue': 200.0,
          'customers': 120.0,
          'marketShare': 25.0,
          'category': 'Finance'
        },
        {
          'company': 'HealthPlus',
          'revenue': 80.0,
          'customers': 200.0,
          'marketShare': 10.0,
          'category': 'Healthcare'
        },
        {
          'company': 'EduLearn',
          'revenue': 60.0,
          'customers': 180.0,
          'marketShare': 8.0,
          'category': 'Education'
        },
        {
          'company': 'RetailMax',
          'revenue': 150.0,
          'customers': 220.0,
          'marketShare': 30.0,
          'category': 'Retail'
        },
        {
          'company': 'FoodChain',
          'revenue': 100.0,
          'customers': 250.0,
          'marketShare': 12.0,
          'category': 'Food'
        },
        {
          'company': 'AutoDrive',
          'revenue': 180.0,
          'customers': 100.0,
          'marketShare': 20.0,
          'category': 'Automotive'
        },
        {
          'company': 'EnergyCo',
          'revenue': 250.0,
          'customers': 80.0,
          'marketShare': 35.0,
          'category': 'Energy'
        },
        {
          'company': 'MediaHub',
          'revenue': 90.0,
          'customers': 160.0,
          'marketShare': 18.0,
          'category': 'Media'
        },
        {
          'company': 'TravelGo',
          'revenue': 110.0,
          'customers': 140.0,
          'marketShare': 22.0,
          'category': 'Travel'
        },
        {
          'company': 'RealEstate',
          'revenue': 220.0,
          'customers': 90.0,
          'marketShare': 28.0,
          'category': 'Real Estate'
        },
        {
          'company': 'SportsFit',
          'revenue': 70.0,
          'customers': 170.0,
          'marketShare': 5.0,
          'category': 'Sports'
        },
      ];

      // Get market share range
      final shares =
          exampleData.map((d) => d['marketShare'] as double).toList();
      final minShare = shares.reduce((a, b) => a < b ? a : b);
      final maxShare = shares.reduce((a, b) => a > b ? a : b);

      expect(minShare, equals(5.0), reason: 'SportsFit has min share');
      expect(maxShare, equals(35.0), reason: 'EnergyCo has max share');

      // With default bubble sizes from example (5-30)
      final defaultMin = 5.0;
      final defaultMax = 30.0;

      final sizeScale = SizeScale(
        domain: [minShare, maxShare],
        range: [defaultMin, defaultMax],
      );

      // Verify specific companies get correct sizes
      final sportsFitSize = sizeScale.scale(5.0);
      final energyCoSize = sizeScale.scale(35.0);
      final techCorpSize = sizeScale.scale(15.0);
      final retailMaxSize = sizeScale.scale(30.0);

      expect(sportsFitSize, equals(5.0),
          reason: 'Smallest company gets min size');
      expect(energyCoSize, equals(30.0),
          reason: 'Largest company gets max size');
      expect(techCorpSize, closeTo(13.33, 0.1),
          reason: 'TechCorp (15%) gets proportional size');
      expect(retailMaxSize, closeTo(25.83, 0.1),
          reason: 'RetailMax (30%) near max');

      // CRITICAL: Verify visual hierarchy
      expect(energyCoSize / sportsFitSize, equals(6.0),
          reason: 'Largest should be 6x the smallest (30/5)');
      expect(retailMaxSize > techCorpSize, isTrue,
          reason: '30% market share must be visually larger than 15%');

      // Verify no bubble is too large for viewport
      for (final company in exampleData) {
        final size = sizeScale.scale(company['marketShare'] as double);
        expect(size, lessThanOrEqualTo(30.0),
            reason: 'No bubble should exceed max size of 30px');
        expect(size, greaterThanOrEqualTo(5.0),
            reason: 'No bubble should be smaller than min size of 5px');
      }
    });
  });
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
      final shapes = [
        PointShape.circle,
        PointShape.square,
        PointShape.triangle
      ];

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
    testWidgets('should render bubble chart widget',
        (WidgetTester tester) async {
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

      // Verify chart widget exists (allow multiple CustomPaint widgets)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should handle empty data gracefully',
        (WidgetTester tester) async {
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

      // Should not crash with empty data (allow multiple CustomPaint widgets)
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
