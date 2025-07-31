import 'package:flutter_test/flutter_test.dart';
import 'package:cristalyse/src/core/scale.dart';

void main() {
  group('Bar Chart Centering Fix Tests', () {
    test('OrdinalScale bandCenter should center bars on tick marks', () {
      final scale = OrdinalScale();
      scale.domain = ['Q1', 'Q2', 'Q3', 'Q4'];
      scale.range = [0, 400];

      // Test that bandCenter returns the center of each band
      final q1Center = scale.bandCenter('Q1');
      final q1Left = scale.scale('Q1');
      final bandWidth = scale.bandWidth;

      // bandCenter should be at the center of the band
      expect(q1Center, equals(q1Left + bandWidth / 2));

      // Test all categories have proper spacing
      final q2Center = scale.bandCenter('Q2');
      final q3Center = scale.bandCenter('Q3');
      final q4Center = scale.bandCenter('Q4');

      expect(q2Center, greaterThan(q1Center));
      expect(q3Center, greaterThan(q2Center));
      expect(q4Center, greaterThan(q3Center));

      // Centers should be evenly spaced
      final spacing1 = q2Center - q1Center;
      final spacing2 = q3Center - q2Center;
      final spacing3 = q4Center - q3Center;

      expect(spacing1, closeTo(spacing2, 0.1));
      expect(spacing2, closeTo(spacing3, 0.1));
    });

    test('OrdinalScale should handle single category', () {
      final scale = OrdinalScale();
      scale.domain = ['Single'];
      scale.range = [0, 100];

      final center = scale.bandCenter('Single');
      final left = scale.scale('Single');
      final bandWidth = scale.bandWidth;

      expect(center, equals(left + bandWidth / 2));
      expect(bandWidth, greaterThan(0));
    });

    test('OrdinalScale should handle empty domain gracefully', () {
      final scale = OrdinalScale();
      scale.domain = [];
      scale.range = [0, 100];

      expect(scale.bandWidth, equals(0));
      expect(scale.scale('nonexistent'), equals(0));
      // bandCenter should handle non-existent values
      expect(scale.bandCenter('nonexistent'), equals(0));
    });
  });
}