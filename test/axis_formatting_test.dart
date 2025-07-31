import 'package:flutter_test/flutter_test.dart';
import 'package:cristalyse/src/core/axis_formatter.dart';

void main() {
  group('AxisFormatter Tests', () {
    group('Basic formatting', () {
      test('default formatter should not modify values', () {
        const formatter = AxisFormatter.defaultFormatter;

        // Test integers
        expect(formatter.format(42), equals('42'));
        expect(formatter.format(-5), equals('-5'));
        expect(formatter.format(0), equals('0'));

        // Test floats
        expect(formatter.format(3.14159), equals('3.1'));
        expect(formatter.format(2.0), equals('2'));
        expect(formatter.format(-1.5), equals('-1.5'));

        // Test strings
        expect(formatter.format('category'), equals('category'));
        expect(formatter.format(''), equals(''));
      });

      test('should handle prefix correctly', () {
        const formatter = AxisFormatter(prefix: '\$');

        expect(formatter.format(100), equals('\$100'));
        expect(formatter.format(0), equals('\$0'));
        expect(formatter.format(-50), equals('\$-50'));
        expect(formatter.format(3.14), equals('\$3.1'));
        expect(formatter.format('text'), equals('\$text'));
      });

      test('should handle suffix correctly', () {
        const formatter = AxisFormatter(suffix: '%');

        expect(formatter.format(100), equals('100%'));
        expect(formatter.format(0), equals('0%'));
        expect(formatter.format(-50), equals('-50%'));
        expect(formatter.format(3.14), equals('3.1%'));
        expect(formatter.format('high'), equals('high%'));
      });

      test('should handle both prefix and suffix', () {
        const formatter = AxisFormatter(prefix: '\$', suffix: ' USD');

        expect(formatter.format(100), equals('\$100 USD'));
        expect(formatter.format(0), equals('\$0 USD'));
        expect(formatter.format(-50), equals('\$-50 USD'));
        expect(formatter.format(3.14), equals('\$3.1 USD'));
      });
    });

    group('Decimal places formatting', () {
      test('should respect custom decimal places', () {
        const formatter = AxisFormatter(decimals: 0);

        expect(formatter.format(3.14159), equals('3'));
        expect(formatter.format(2.9), equals('3'));
        expect(formatter.format(-1.7), equals('-2'));
        expect(formatter.format(100), equals('100'));
      });

      test('should format with 2 decimal places', () {
        const formatter = AxisFormatter(decimals: 2);

        expect(formatter.format(3.14159), equals('3.14'));
        expect(formatter.format(2.0), equals('2.00'));
        expect(formatter.format(-1.7), equals('-1.70'));
        expect(formatter.format(100), equals('100.00'));
      });

      test('should format with 3 decimal places', () {
        const formatter = AxisFormatter(decimals: 3);

        expect(formatter.format(3.14159), equals('3.142'));
        expect(formatter.format(2.0), equals('2.000'));
        expect(formatter.format(-1.7), equals('-1.700'));
      });

      test('should combine decimals with prefix and suffix', () {
        const formatter = AxisFormatter(
          prefix: 'JPY ',
          suffix: '',
          decimals: 0,
        );

        expect(formatter.format(1500.75), equals('JPY 1501'));
        expect(formatter.format(100.25), equals('JPY 100'));
      });
    });

    group('Predefined formatters', () {
      test('currency formatter should add dollar prefix', () {
        expect(AxisFormatter.currency.format(100), equals('\$100'));
        expect(AxisFormatter.currency.format(3.14), equals('\$3.1'));
        expect(AxisFormatter.currency.format(0), equals('\$0'));
      });

      test('percentage formatter should add percent suffix', () {
        expect(AxisFormatter.percentage.format(75), equals('75%'));
        expect(AxisFormatter.percentage.format(3.14), equals('3.1%'));
        expect(AxisFormatter.percentage.format(0), equals('0%'));
      });

      test('custom formatter should add JPY without decimals if set to do so',
          () {
        final jpyFormatter = AxisFormatter.custom(prefix: 'JPY ', decimals: 0);
        expect(jpyFormatter.format(1500), equals('JPY 1500'));
        expect(jpyFormatter.format(3.14), equals('JPY 3'));
        expect(jpyFormatter.format(0), equals('JPY 0'));
        expect(jpyFormatter.format(1500.75), equals('JPY 1501'));
      });

      test('currencyWithSymbol should create custom currency formatter', () {
        final euroFormatter = AxisFormatter.currencyWithSymbol('€');

        expect(euroFormatter.format(100), equals('€100'));
        expect(euroFormatter.format(3.14), equals('€3.1'));
        expect(euroFormatter.format(0), equals('€0'));
      });

      test('custom formatter should handle all parameters', () {
        final formatter = AxisFormatter.custom(
          prefix: 'JPY ',
          suffix: ' per unit',
          decimals: 0,
        );

        expect(formatter.format(1500), equals('JPY 1500 per unit'));
        expect(formatter.format(3.14159), equals('JPY 3 per unit'));
      });
    });

    group('Edge cases', () {
      test('should handle null and empty values gracefully', () {
        const formatter = AxisFormatter(prefix: '\$', suffix: '%');

        expect(formatter.format(null),
            equals('null')); // Non-string, non-numeric values returned as-is
        expect(formatter.format(''),
            equals('\$%')); // Empty string still gets prefix/suffix
      });

      test('should handle very large numbers', () {
        const formatter = AxisFormatter(prefix: '\$', decimals: 2);

        expect(formatter.format(1234567.89), equals('\$1234567.89'));
        expect(formatter.format(-9876543.21), equals('\$-9876543.21'));
      });

      test('should handle very small numbers', () {
        const formatter = AxisFormatter(suffix: '%', decimals: 4);

        expect(formatter.format(0.0001), equals('0.0001%'));
        expect(formatter.format(0.00001), equals('0.0000%'));
      });

      test('should handle special double values', () {
        const formatter = AxisFormatter(prefix: '\$');

        expect(formatter.format(double.infinity), equals('\$Infinity'));
        expect(
            formatter.format(double.negativeInfinity), equals('\$-Infinity'));
        expect(formatter.format(double.nan), equals('\$NaN'));
      });
    });

    group('Object methods', () {
      test('equality should work correctly', () {
        const formatter1 =
            AxisFormatter(prefix: '\$', suffix: '%', decimals: 2);
        const formatter2 =
            AxisFormatter(prefix: '\$', suffix: '%', decimals: 2);
        const formatter3 = AxisFormatter(prefix: '€', suffix: '%', decimals: 2);

        expect(formatter1, equals(formatter2));
        expect(formatter1, isNot(equals(formatter3)));
      });

      test('hashCode should be consistent', () {
        const formatter1 =
            AxisFormatter(prefix: '\$', suffix: '%', decimals: 2);
        const formatter2 =
            AxisFormatter(prefix: '\$', suffix: '%', decimals: 2);

        expect(formatter1.hashCode, equals(formatter2.hashCode));
      });

      test('toString should provide readable output', () {
        const formatter = AxisFormatter(prefix: '\$', suffix: '%', decimals: 2);

        expect(formatter.toString(), contains('prefix'));
        expect(formatter.toString(), contains('suffix'));
        expect(formatter.toString(), contains('decimals'));
      });

      test('copyWith should create modified copies', () {
        const original = AxisFormatter(prefix: '\$', suffix: '%', decimals: 2);

        final withNewPrefix = original.copyWith(prefix: '€');
        expect(withNewPrefix.prefix, equals('€'));
        expect(withNewPrefix.suffix, equals('%'));
        expect(withNewPrefix.decimals, equals(2));

        final withNewSuffix = original.copyWith(suffix: ' USD');
        expect(withNewSuffix.prefix, equals('\$'));
        expect(withNewSuffix.suffix, equals(' USD'));
        expect(withNewSuffix.decimals, equals(2));

        final withNewDecimals = original.copyWith(decimals: 0);
        expect(withNewDecimals.prefix, equals('\$'));
        expect(withNewDecimals.suffix, equals('%'));
        expect(withNewDecimals.decimals, equals(0));
      });
    });
  });
}
