import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Legend Functionality Tests', () {
    final testData = [
      {'quarter': 'Q1', 'revenue': 1000, 'product': 'ProductA'},
      {'quarter': 'Q2', 'revenue': 1200, 'product': 'ProductA'},
      {'quarter': 'Q1', 'revenue': 800, 'product': 'ProductB'},
      {'quarter': 'Q2', 'revenue': 1100, 'product': 'ProductB'},
    ];

    testWidgets('Chart with basic legend should build without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'quarter', y: 'revenue', color: 'product')
                .geomBar(style: BarStyle.grouped)
                .legend() // Basic legend
                .build(),
          ),
        ),
      );

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('Chart with positioned legend should build without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'quarter', y: 'revenue', color: 'product')
                .geomBar(style: BarStyle.grouped)
                .legend(position: LegendPosition.bottom)
                .build(),
          ),
        ),
      );

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    testWidgets('Chart with custom legend styling should build without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'quarter', y: 'revenue', color: 'product')
                .geomBar(style: BarStyle.grouped)
                .legend(
                  position: LegendPosition.right,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  textStyle: const TextStyle(fontSize: 12),
                  symbolSize: 16.0,
                )
                .build(),
          ),
        ),
      );

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });

    test('LegendConfig should have correct default values', () {
      const config = LegendConfig();

      expect(config.position, LegendPosition.topRight);
      expect(config.orientation, LegendOrientation.auto);
      expect(config.spacing, 12.0);
      expect(config.itemSpacing, 8.0);
      expect(config.symbolSize, 12.0);
      expect(config.borderRadius, 4.0);
    });

    test('LegendConfig should determine correct orientation from position', () {
      const topRightConfig = LegendConfig(position: LegendPosition.topRight);
      expect(topRightConfig.effectiveOrientation, LegendOrientation.vertical);

      const bottomConfig = LegendConfig(position: LegendPosition.bottom);
      expect(bottomConfig.effectiveOrientation, LegendOrientation.horizontal);

      const rightConfig = LegendConfig(position: LegendPosition.right);
      expect(rightConfig.effectiveOrientation, LegendOrientation.vertical);

      const topConfig = LegendConfig(position: LegendPosition.top);
      expect(topConfig.effectiveOrientation, LegendOrientation.horizontal);
    });

    test('LegendGenerator should generate correct legend items', () {
      final items = LegendGenerator.generateFromData(
        data: testData,
        colorColumn: 'product',
        colorPalette: [Colors.blue, Colors.red, Colors.green],
        geometries: [BarGeometry(style: BarStyle.grouped)],
      );

      expect(items.length, 2); // ProductA and ProductB
      expect(items[0].label, 'ProductA');
      expect(items[1].label, 'ProductB');
      expect(items[0].color, Colors.blue);
      expect(items[1].color, Colors.red);
      expect(items[0].symbol,
          LegendSymbol.square); // Should be square for bar geometry
      expect(items[1].symbol, LegendSymbol.square);
    });

    test('LegendGenerator should return empty list for missing color column',
        () {
      final items = LegendGenerator.generateFromData(
        data: testData,
        colorColumn: null,
        colorPalette: [Colors.blue, Colors.red],
        geometries: [BarGeometry()],
      );

      expect(items.isEmpty, true);
    });

    test('LegendGenerator should determine correct symbol from geometry', () {
      // Test bar geometry
      final barItems = LegendGenerator.generateFromData(
        data: testData,
        colorColumn: 'product',
        colorPalette: [Colors.blue, Colors.red],
        geometries: [BarGeometry()],
      );
      expect(barItems.first.symbol, LegendSymbol.square);

      // Test line geometry
      final lineItems = LegendGenerator.generateFromData(
        data: testData,
        colorColumn: 'product',
        colorPalette: [Colors.blue, Colors.red],
        geometries: [LineGeometry()],
      );
      expect(lineItems.first.symbol, LegendSymbol.line);

      // Test point geometry
      final pointItems = LegendGenerator.generateFromData(
        data: testData,
        colorColumn: 'product',
        colorPalette: [Colors.blue, Colors.red],
        geometries: [PointGeometry()],
      );
      expect(pointItems.first.symbol, LegendSymbol.circle);
    });

    test('LegendItem equality should work correctly', () {
      const item1 = LegendItem(label: 'Test', color: Colors.blue);
      const item2 = LegendItem(label: 'Test', color: Colors.blue);
      const item3 = LegendItem(label: 'Different', color: Colors.blue);

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    testWidgets('Legend text should inherit theme color for dark themes',
        (WidgetTester tester) async {
      const darkTheme = ChartTheme(
        backgroundColor: Colors.black,
        plotBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        borderColor: Colors.grey,
        gridColor: Colors.grey,
        axisColor: Colors.white, // This should be used for legend text
        gridWidth: 1.0,
        axisWidth: 1.0,
        pointSizeDefault: 4.0,
        pointSizeMin: 2.0,
        pointSizeMax: 12.0,
        colorPalette: [Colors.blue, Colors.red],
        padding: EdgeInsets.all(20),
        axisTextStyle: TextStyle(fontSize: 12, color: Colors.white),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CristalyseChart()
                .data(testData)
                .mapping(x: 'quarter', y: 'revenue', color: 'product')
                .geomBar(style: BarStyle.grouped)
                .theme(darkTheme)
                .legend() // Should use white text from dark theme
                .build(),
          ),
        ),
      );

      expect(find.byType(AnimatedCristalyseChartWidget), findsOneWidget);
    });
  });
}
