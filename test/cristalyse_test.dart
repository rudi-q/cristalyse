import 'package:cristalyse/cristalyse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CristalyseChart', () {
    test('should create chart with data', () {
      final data = [
        {'x': 1, 'y': 2},
        {'x': 2, 'y': 3},
      ];

      final chart = CristalyseChart()
          .data(data)
          .mapping(x: 'x', y: 'y')
          .geomPoint();

      expect(chart, isNotNull);
    });

    test('should handle empty data', () {
      final chart = CristalyseChart()
          .data([])
          .geomPoint();

      expect(chart, isNotNull);
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

    test('should generate ticks', () {
      final scale = LinearScale();
      scale.domain = [0, 10];

      final ticks = scale.getTicks(5);
      expect(ticks.length, equals(5));
      expect(ticks.first, equals(0));
      expect(ticks.last, equals(10));
    });
  });
}