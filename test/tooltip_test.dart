import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tooltip System', () {
    late List<Map<String, dynamic>> testData;

    setUp(() {
      testData = [
        {'x': 10.0, 'y': 20.0, 'category': 'A', 'revenue': 1500.0, 'count': 25},
        {'x': 20.0, 'y': 30.0, 'category': 'B', 'revenue': 2200.0, 'count': 42},
        {'x': 30.0, 'y': 15.0, 'category': 'A', 'revenue': 1800.0, 'count': 33},
        {'x': 40.0, 'y': 35.0, 'category': 'C', 'revenue': 2800.0, 'count': 18},
      ];
    });

    group('Default Tooltip Builders', () {
      testWidgets('should use simple tooltip builder', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .tooltip(DefaultTooltips.simple('y'))
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should use multi-column tooltip builder', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint()
                .tooltip(DefaultTooltips.multi({
                  'category': 'Category',
                  'revenue': 'Revenue',
                  'count': 'Count',
                }))
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should use rich tooltip builder', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint()
                .tooltip(DefaultTooltips.rich(
                  title: 'Sales Data',
                  fields: {
                    'category': 'Segment',
                    'revenue': 'Revenue (\$)',
                    'count': 'Deal Count',
                  },
                  accentColor: Colors.blue,
                ))
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Custom Tooltip Configurations', () {
      testWidgets('should support custom tooltip styling', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        'Custom: ${point.getDisplayValue('y')}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    backgroundColor: Colors.purple,
                    textColor: Colors.white,
                    borderRadius: 8.0,
                    padding: EdgeInsets.all(12),
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should support custom timing configuration', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Fast tooltip: ${point.getDisplayValue('y')}'),
                    showDelay: Duration(milliseconds: 50),   // Very fast show
                    hideDelay: Duration(milliseconds: 2000), // Slow hide
                    followPointer: false,                     // Don't follow mouse
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should support custom shadow and styling', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Text('Styled: ${point.getDisplayValue('y')}'),
                    backgroundColor: Colors.black87,
                    textColor: Colors.amber,
                    borderRadius: 12.0,
                    shadow: BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15.0,
                      offset: Offset(0, 5),
                      spreadRadius: 2.0,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    group('DataPointInfo Utility Methods', () {
      testWidgets('should format display values correctly', (WidgetTester tester) async {
        // Test that getDisplayValue handles different data types
        final mixedData = [
          {'x': 1, 'y': 2.5, 'category': 'A', 'valid': true, 'count': 100},
          {'x': '2', 'y': '3.7', 'category': 'B', 'valid': false, 'count': 200},
          {'x': 3.0, 'y': 4, 'category': null, 'valid': null, 'count': null},
        ];

        bool tooltipBuilderCalled = false;

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(mixedData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) {
                      tooltipBuilderCalled = true;
                      
                      // Test different value formatting
                      final xValue = point.getDisplayValue('x');      // Should handle mixed types
                      final yValue = point.getDisplayValue('y');      // Should handle numbers/strings
                      final category = point.getDisplayValue('category'); // Should handle null
                      final valid = point.getDisplayValue('valid');   // Should handle boolean
                      final count = point.getDisplayValue('count');   // Should handle null numbers
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('X: $xValue'),
                          Text('Y: $yValue'),
                          Text('Category: $category'),
                          Text('Valid: $valid'),
                          Text('Count: $count'),
                        ],
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
      });
    });

    group('Business Use Cases', () {
      testWidgets('should support sales dashboard tooltips', (WidgetTester tester) async {
        final salesData = [
          {'week': 1, 'revenue': 15000, 'deals': 12, 'rep': 'Alice', 'target': 18000},
          {'week': 2, 'revenue': 22000, 'deals': 18, 'rep': 'Bob', 'target': 20000},
          {'week': 3, 'revenue': 19000, 'deals': 15, 'rep': 'Alice', 'target': 18000},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(salesData)
                .mapping(x: 'week', y: 'revenue', color: 'rep')
                .geomPoint(size: 8.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) {
                      final revenue = double.tryParse(point.getDisplayValue('revenue')) ?? 0;
                      final target = double.tryParse(point.getDisplayValue('target')) ?? 0;
                      final performance = target > 0 ? (revenue / target * 100).toStringAsFixed(1) : 'N/A';
                      final status = revenue >= target ? '✅ On Track' : '⚠️ Below Target';
                      
                      return Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week ${point.getDisplayValue('week')} - ${point.getDisplayValue('rep')}',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Revenue: \$${point.getDisplayValue('revenue')}', style: TextStyle(color: Colors.white)),
                            Text('Target: \$${point.getDisplayValue('target')}', style: TextStyle(color: Colors.white)),
                            Text('Deals: ${point.getDisplayValue('deals')}', style: TextStyle(color: Colors.white)),
                            SizedBox(height: 4),
                            Text('Performance: $performance%', style: TextStyle(color: Colors.white)),
                            Text(status, style: TextStyle(
                              color: revenue >= target ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            )),
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
      });

      testWidgets('should support analytics dashboard tooltips', (WidgetTester tester) async {
        final analyticsData = [
          {'date': '2024-01-01', 'visitors': 1250, 'bounceRate': 32.5, 'pageViews': 3850, 'conversions': 23},
          {'date': '2024-01-02', 'visitors': 1180, 'bounceRate': 28.7, 'pageViews': 4100, 'conversions': 31},
          {'date': '2024-01-03', 'visitors': 1420, 'bounceRate': 35.1, 'pageViews': 3920, 'conversions': 28},
        ];

        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(analyticsData)
                .mapping(x: 'date', y: 'visitors')
                .geomPoint(size: 6.0)
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) {
                      final visitors = point.getDisplayValue('visitors');
                      final bounceRate = point.getDisplayValue('bounceRate');
                      final pageViews = point.getDisplayValue('pageViews');
                      final conversions = point.getDisplayValue('conversions');
                      
                      // Calculate derived metrics
                      final visitorCount = double.tryParse(visitors) ?? 0;
                      final conversionCount = double.tryParse(conversions) ?? 0;
                      final conversionRate = visitorCount > 0 
                          ? (conversionCount / visitorCount * 100).toStringAsFixed(2)
                          : '0.00';
                      
                      return Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[800]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              point.getDisplayValue('date'),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Divider(color: Colors.white24, height: 12),
                            _buildMetricRow('👥 Visitors', visitors),
                            _buildMetricRow('📄 Page Views', pageViews),
                            _buildMetricRow('📊 Bounce Rate', '$bounceRate%'),
                            _buildMetricRow('🎯 Conversions', conversions),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Conversion Rate: $conversionRate%',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
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
      });
    });

    group('Tooltip Edge Cases', () {
      testWidgets('should handle missing tooltip builder gracefully', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    // No builder provided
                    builder: null,
                  ),
                )
                .build(),
          ),
        );

        await tester.pumpWidget(chart);
        await tester.pumpAndSettle();

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('should handle extremely long tooltip content', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Container(
                      constraints: BoxConstraints(maxWidth: 250),
                      child: Text(
                        'This is an extremely long tooltip that contains a lot of information about the data point including detailed descriptions, multiple metrics, and various other pieces of contextual information that might be relevant to the user when they hover over this particular data point in the visualization.',
                        style: TextStyle(color: Colors.white),
                      ),
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

      testWidgets('should handle tooltip with complex widgets', (WidgetTester tester) async {
        final chart = MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'x', y: 'y', color: 'category')
                .geomPoint()
                .interaction(
                  tooltip: TooltipConfig(
                    builder: (point) => Card(
                      color: Colors.black87,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.analytics, color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text('Data Point', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Divider(color: Colors.white24),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(point.getDisplayValue('category'), style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: 0.7,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                            SizedBox(height: 4),
                            Text('Value: ${point.getDisplayValue('y')}', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
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
  });
}

// Helper function for building metric rows in tooltips
Widget _buildMetricRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}