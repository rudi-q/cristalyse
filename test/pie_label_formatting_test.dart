import 'package:flutter_test/flutter_test.dart';
import 'package:cristalyse/src/core/chart.dart';

void main() {
  group('Pie Chart Label Formatting - Integration Tests', () {
    test('pie chart should work with default label formatter', () {
      final chart = CristalyseChart()
          .data([
            {'category': 'A', 'value': 100},
            {'category': 'B', 'value': 200},
          ])
          .mappingPie(value: 'value', category: 'category')
          .geomPie(
            showPercentages: true,
          );

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isNotNull);
    });

    test('pie chart should accept custom label formatter', () {
      final chart = CristalyseChart()
          .data([
            {'category': 'A', 'value': 100},
            {'category': 'B', 'value': 200},
          ])
          .mappingPie(value: 'value', category: 'category')
          .geomPie(
            labels: (value) => 'Custom: ${value.toStringAsFixed(1)}',
          );

      expect(chart, isNotNull);
      final widget = chart.build();
      expect(widget, isNotNull);
    });
  });
}
