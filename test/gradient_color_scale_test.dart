import 'package:cristalyse/src/core/scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GradientColorScale', () {
    test('heatMap preset returns correct colors', () {
      final scale = GradientColorScale.heatMap();
      scale.domain = [0, 100];

      // Test extremes
      final lowColor = scale.scale(0);
      final highColor = scale.scale(100);

      expect(lowColor, const Color(0xFF000080)); // Dark blue
      expect(highColor, const Color(0xFFFF0000)); // Bright red
    });

    test('custom gradient with interpolation', () {
      final scale = GradientColorScale(
        colors: [Colors.blue, Colors.red],
        interpolate: true,
      );
      scale.domain = [0, 10];

      final lowColor = scale.scale(0);
      final midColor = scale.scale(5);
      final highColor = scale.scale(10);

      expect(lowColor, Colors.blue);
      expect(highColor, Colors.red);
      // Mid should be interpolated
      expect(midColor.r, greaterThan(0));
      expect(midColor.b, greaterThan(0));
    });

    test('custom gradient without interpolation (discrete)', () {
      final scale = GradientColorScale(
        colors: [Colors.blue, Colors.green, Colors.red],
        interpolate: false,
      );
      scale.domain = [0, 10];

      final lowColor = scale.scale(0);
      final midColor = scale.scale(5);
      final highColor = scale.scale(10);

      // Should snap to nearest color
      expect(lowColor, Colors.blue);
      expect(midColor, Colors.green);
      expect(highColor, Colors.red);
    });

    test('normalizes values correctly', () {
      final scale = GradientColorScale.heatMap();
      scale.domain = [0, 100];

      expect(scale.normalize(0), 0.0);
      expect(scale.normalize(50), 0.5);
      expect(scale.normalize(100), 1.0);
      expect(scale.normalize(-10), 0.0); // Clamped
      expect(scale.normalize(110), 1.0); // Clamped
    });

    test('viridis preset works', () {
      final scale = GradientColorScale.viridis();
      scale.domain = [0, 1];

      final lowColor = scale.scale(0);
      final highColor = scale.scale(1);

      // Should have dark and light colors
      expect(lowColor.computeLuminance(), lessThan(0.5));
      expect(highColor.computeLuminance(), greaterThan(0.5));
    });

    test('coolWarm preset works', () {
      final scale = GradientColorScale.coolWarm();
      scale.domain = [0, 1];

      final lowColor = scale.scale(0);
      final highColor = scale.scale(1);

      // Cool colors should be bluer, warm colors redder
      expect(lowColor.b, greaterThan(lowColor.r));
      expect(highColor.r, greaterThan(highColor.b));
    });

    test('handles single color gradient', () {
      final scale = GradientColorScale(colors: [Colors.blue]);
      scale.domain = [0, 100];

      expect(scale.scale(0), Colors.blue);
      expect(scale.scale(50), Colors.blue);
      expect(scale.scale(100), Colors.blue);
    });

    test('handles empty domain gracefully', () {
      final scale = GradientColorScale.heatMap();

      // Default domain is [0, 1]
      expect(scale.domain, [0, 1]);
      expect(scale.scale(0.5), isA<Color>());
    });
  });
}
