import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressGeometry Validation Tests', () {
    test('should validate minValue < maxValue', () {
      expect(
        () => ProgressGeometry(
          minValue: 100.0,
          maxValue: 50.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate positive animationDuration', () {
      expect(
        () => ProgressGeometry(
          animationDuration: Duration.zero,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          animationDuration: const Duration(milliseconds: -100),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate non-negative thickness', () {
      expect(
        () => ProgressGeometry(
          thickness: -5.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate non-negative cornerRadius', () {
      expect(
        () => ProgressGeometry(
          cornerRadius: -2.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate non-negative strokeWidth', () {
      expect(
        () => ProgressGeometry(
          strokeWidth: -1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate non-negative labelOffset', () {
      expect(
        () => ProgressGeometry(
          labelOffset: -3.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate positive groupCount', () {
      expect(
        () => ProgressGeometry(
          groupCount: 0,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          groupCount: -2,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate positive tickCount', () {
      expect(
        () => ProgressGeometry(
          tickCount: 0,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          tickCount: -5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate positive gaugeRadius', () {
      expect(
        () => ProgressGeometry(
          gaugeRadius: 0.0,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          gaugeRadius: -10.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate sweepAngle range', () {
      expect(
        () => ProgressGeometry(
          sweepAngle: 0.0,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          sweepAngle: -math.pi / 2,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          sweepAngle: 2 * math.pi + 0.1, // Greater than 360 degrees
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass for valid range
      expect(
        () => ProgressGeometry(
          sweepAngle: math.pi,
        ),
        returnsNormally,
      );

      expect(
        () => ProgressGeometry(
          sweepAngle: 2 * math.pi, // Exactly 360 degrees should be valid
        ),
        returnsNormally,
      );
    });

    test('should validate segments and segmentColors length matching', () {
      expect(
        () => ProgressGeometry(
          segments: [10.0, 20.0, 30.0],
          segmentColors: [Colors.red, Colors.green], // Mismatched length
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass when lengths match
      expect(
        () => ProgressGeometry(
          segments: [10.0, 20.0, 30.0],
          segmentColors: [Colors.red, Colors.green, Colors.blue],
        ),
        returnsNormally,
      );

      // Should pass when one is null
      expect(
        () => ProgressGeometry(
          segments: [10.0, 20.0, 30.0],
          segmentColors: null,
        ),
        returnsNormally,
      );
    });

    test(
        'should validate concentricRadii and concentricThicknesses length matching',
        () {
      expect(
        () => ProgressGeometry(
          concentricRadii: [10.0, 20.0, 30.0],
          concentricThicknesses: [2.0, 4.0], // Mismatched length
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass when lengths match
      expect(
        () => ProgressGeometry(
          concentricRadii: [10.0, 20.0, 30.0],
          concentricThicknesses: [2.0, 4.0, 6.0],
        ),
        returnsNormally,
      );

      // Should pass when both are null
      expect(
        () => ProgressGeometry(
          concentricRadii: null,
          concentricThicknesses: null,
        ),
        returnsNormally,
      );
    });

    test('should validate non-negative segment values', () {
      expect(
        () => ProgressGeometry(
          segments: [10.0, -5.0, 30.0], // Negative segment value
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass with all positive values
      expect(
        () => ProgressGeometry(
          segments: [10.0, 0.0, 30.0], // Zero is allowed
        ),
        returnsNormally,
      );
    });

    test('should validate positive concentricRadii values', () {
      expect(
        () => ProgressGeometry(
          concentricRadii: [10.0, 0.0, 30.0], // Zero radius not allowed
          concentricThicknesses: [2.0, 4.0, 6.0],
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          concentricRadii: [10.0, -5.0, 30.0], // Negative radius
          concentricThicknesses: [2.0, 4.0, 6.0],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate positive concentricThicknesses values', () {
      expect(
        () => ProgressGeometry(
          concentricRadii: [10.0, 20.0, 30.0],
          concentricThicknesses: [2.0, 0.0, 6.0], // Zero thickness not allowed
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          concentricRadii: [10.0, 20.0, 30.0],
          concentricThicknesses: [2.0, -1.0, 6.0], // Negative thickness
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should validate stacked style requires segments', () {
      expect(
        () => ProgressGeometry(
          style: ProgressStyle.stacked,
          segments: null, // Required for stacked style
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass with segments provided
      expect(
        () => ProgressGeometry(
          style: ProgressStyle.stacked,
          segments: [10.0, 20.0, 30.0],
        ),
        returnsNormally,
      );
    });

    test('should validate gauge style requires gaugeRadius', () {
      expect(
        () => ProgressGeometry(
          style: ProgressStyle.gauge,
          gaugeRadius: null, // Required for gauge style
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass with gaugeRadius provided
      expect(
        () => ProgressGeometry(
          style: ProgressStyle.gauge,
          gaugeRadius: 50.0,
        ),
        returnsNormally,
      );
    });

    test(
        'should validate concentric style requires both concentricRadii and concentricThicknesses',
        () {
      expect(
        () => ProgressGeometry(
          style: ProgressStyle.concentric,
          concentricRadii: null,
          concentricThicknesses: null, // Both required
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          style: ProgressStyle.concentric,
          concentricRadii: [10.0, 20.0],
          concentricThicknesses: null, // Missing thicknesses
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ProgressGeometry(
          style: ProgressStyle.concentric,
          concentricRadii: null,
          concentricThicknesses: [2.0, 4.0], // Missing radii
        ),
        throwsA(isA<AssertionError>()),
      );

      // Should pass with both provided
      expect(
        () => ProgressGeometry(
          style: ProgressStyle.concentric,
          concentricRadii: [10.0, 20.0],
          concentricThicknesses: [2.0, 4.0],
        ),
        returnsNormally,
      );
    });

    test('should allow valid constructor parameters', () {
      // Basic valid constructor
      expect(
        () => ProgressGeometry(
          orientation: ProgressOrientation.horizontal,
          thickness: 20.0,
          cornerRadius: 4.0,
          minValue: 0.0,
          maxValue: 100.0,
          animationDuration: const Duration(milliseconds: 800),
          strokeWidth: 1.0,
          labelOffset: 5.0,
          groupSpacing: 8.0,
          groupCount: 3,
          tickCount: 10,
          gaugeRadius: 50.0,
          sweepAngle: math.pi,
        ),
        returnsNormally,
      );
    });
  });
}
