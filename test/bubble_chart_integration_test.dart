import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bubble Chart Integration - FINAL VERIFICATION', () {
    test('Verify bubble chart renders with correct relative sizes', () {
      // Generate the same data as the example
      final random = math.Random(42);
      final companies = [
        {'name': 'TechCorp Solutions', 'category': 'Enterprise', 'growth': 15},
        {'name': 'StartupX Labs', 'category': 'Startup', 'growth': 45},
        {'name': 'MidSize Systems', 'category': 'SMB', 'growth': 22},
        {'name': 'BigTech Industries', 'category': 'Enterprise', 'growth': 8},
        {'name': 'InnovateLab', 'category': 'Startup', 'growth': 65},
        {'name': 'GrowthCo Tech', 'category': 'SMB', 'growth': 30},
        {'name': 'MegaCorp Global', 'category': 'Enterprise', 'growth': 12},
        {'name': 'AgileTeam Pro', 'category': 'Startup', 'growth': 55},
        {'name': 'SteadyCorp Inc', 'category': 'SMB', 'growth': 18},
        {'name': 'ScaleTech Cloud', 'category': 'Enterprise', 'growth': 20},
        {'name': 'NextGen AI', 'category': 'Startup', 'growth': 80},
        {'name': 'DataFlow Systems', 'category': 'SMB', 'growth': 25},
      ];

      final bubbleData = companies.map((company) {
        final isEnterprise = company['category'] == 'Enterprise';
        final isSMB = company['category'] == 'SMB';
        final growth = (company['growth'] as int).toDouble();

        final baseRevenue = isEnterprise ? 250.0 : (isSMB ? 150.0 : 50.0);
        final baseCustomers = isEnterprise ? 180.0 : (isSMB ? 120.0 : 60.0);
        final baseMarketShare = isEnterprise ? 18.0 : (isSMB ? 10.0 : 5.0);

        final variance = random.nextDouble() * 0.8 + 0.6;

        return {
          'name': company['name'],
          'category': company['category'],
          'revenue': (baseRevenue * variance).roundToDouble(),
          'customers': (baseCustomers * variance).roundToDouble(),
          'marketShare':
              (baseMarketShare * variance * (1 + growth / 100)).roundToDouble(),
          'growth': growth,
        };
      }).toList()
        ..sort((a, b) =>
            (b['marketShare'] as double).compareTo(a['marketShare'] as double));

      // Extract market share values
      final marketShares =
          bubbleData.map((d) => d['marketShare'] as double).toList();

      final minMarketShare = marketShares.reduce(math.min);
      final maxMarketShare = marketShares.reduce(math.max);

      // Test with slider at 0.0 (minimum sizes)
      final minBubbleSize = 5.0; // 5px radius minimum
      final maxBubbleSize = 15.0; // 15px radius maximum

      final sizeScale = SizeScale(
        range: [minBubbleSize, maxBubbleSize],
      );
      sizeScale.setBounds([minMarketShare, maxMarketShare], null, []);

      // Verify each company gets appropriate bubble size
      for (final company in bubbleData) {
        final marketShare = company['marketShare'] as double;
        final bubbleSize = sizeScale.scale(marketShare);
        final name = company['name'];

        // Check size is within bounds
        expect(bubbleSize, greaterThanOrEqualTo(minBubbleSize),
            reason: '$name bubble should be at least min size');
        expect(bubbleSize, lessThanOrEqualTo(maxBubbleSize),
            reason: '$name bubble should not exceed max size');
      }

      // Verify relative sizing is correct
      bubbleData.sort((a, b) =>
          (a['marketShare'] as double).compareTo(b['marketShare'] as double));

      for (int i = 1; i < bubbleData.length; i++) {
        final prevShare = bubbleData[i - 1]['marketShare'] as double;
        final currShare = bubbleData[i]['marketShare'] as double;
        final prevSize = sizeScale.scale(prevShare);
        final currSize = sizeScale.scale(currShare);

        expect(currSize, greaterThanOrEqualTo(prevSize),
            reason:
                'Larger market share must have larger or equal bubble size');
      }

      // Test with slider at 1.0 (maximum sizes)
      final minBubbleSizeMax = 8.0; // 8px radius at max slider
      final maxBubbleSizeMax = 25.0; // 25px radius at max slider

      final sizeScaleMax = SizeScale(
        range: [minBubbleSizeMax, maxBubbleSizeMax],
      );
      sizeScaleMax.setBounds([minMarketShare, maxMarketShare], null, []);

      // Verify slider scaling maintains proportions
      for (final company in bubbleData) {
        final marketShare = company['marketShare'] as double;
        final sizeAtMin = sizeScale.scale(marketShare);
        final sizeAtMax = sizeScaleMax.scale(marketShare);

        // Size should increase with slider
        expect(sizeAtMax, greaterThan(sizeAtMin),
            reason: 'Bubble should be larger when slider is at max');

        // But relative proportions should be maintained
        final proportionAtMin =
            (sizeAtMin - minBubbleSize) / (maxBubbleSize - minBubbleSize);
        final proportionAtMax = (sizeAtMax - minBubbleSizeMax) /
            (maxBubbleSizeMax - minBubbleSizeMax);

        expect(proportionAtMax, closeTo(proportionAtMin, 0.01),
            reason:
                'Relative size proportion should be maintained across slider values');
      }
    });

    testWidgets('Bubble chart renders without overflow',
        (WidgetTester tester) async {
      // Test that bubbles don't overflow the chart area
      final testData = [
        {'x': 10.0, 'y': 10.0, 'size': 5.0, 'cat': 'A'},
        {'x': 50.0, 'y': 50.0, 'size': 20.0, 'cat': 'B'},
        {'x': 90.0, 'y': 90.0, 'size': 35.0, 'cat': 'C'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: CristalyseChart()
                  .data(testData)
                  .mapping(x: 'x', y: 'y', size: 'size', color: 'cat')
                  .geomBubble(
                    minSize: 5.0,
                    maxSize: 20.0,
                  )
                  .scaleXContinuous()
                  .scaleYContinuous()
                  .build(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(CustomPaint), findsWidgets);

      // No render overflow errors should occur
      expect(tester.takeException(), isNull);
    });
  });
}
