import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:cristalyse/src/core/scale.dart';

void main() {
  group('LabelFormatter Core Functionality', () {
    test('default formatter preserves existing behavior', () {
      final scale = LinearScale(); // No custom formatter
      expect(scale.formatLabel(42), equals('42')); // Integer
      expect(scale.formatLabel(42.0), equals('42')); // Rounds to integer
      expect(scale.formatLabel(42.05),
          equals('42.0')); // Rounds but still displays double
      expect(scale.formatLabel(42.5), equals('42.5')); // Decimal
      expect(scale.formatLabel('text'), equals('text')); // String fallback
    });

    test('custom formatter is called when provided', () {
      final scale = LinearScale(labelFormatter: (value) => 'custom: $value');
      expect(scale.formatLabel(42), equals('custom: 42'));
    });
  });

  // Test our documentation examples work (not testing NumberFormat itself)
  group('Documentation Example Verification', () {
    test('NumberFormat.simpleCurrency example from docs works', () {
      // Testing the exact example from docs: NumberFormat.simpleCurrency().format
      final formatter = NumberFormat.simpleCurrency();
      final scale = LinearScale(labelFormatter: formatter.format);

      // Exact match verification for documentation accuracy
      expect(scale.formatLabel(1234.56), equals('\$1,234.56'));
    });

    test('NumberFormat.percentPattern example from docs works', () {
      // Testing the exact example from docs: NumberFormat.percentPattern().format
      final formatter = NumberFormat.percentPattern();
      final scale = LinearScale(labelFormatter: formatter.format);

      // Exact match verification for documentation accuracy
      expect(scale.formatLabel(0.234), equals('23%'));
    });

    test('NumberFormat.compact example #1 from docs works', () {
      // Testing the exact example from docs: NumberFormat.compact().format
      final formatter = NumberFormat.compact();
      final scale = LinearScale(labelFormatter: formatter.format);

      // Exact match verification for documentation accuracy
      expect(scale.formatLabel(1200), equals('1.2K'));
    });

    test('NumberFormat.compact example #2 from docs works', () {
      // Testing the exact example from docs: NumberFormat.compact().format
      final formatter = NumberFormat.compact();
      final scale = LinearScale(labelFormatter: formatter.format);

      // Exact match verification for documentation accuracy
      expect(scale.formatLabel(1500000), equals('1.5M'));
    });

    test('factory pattern example from docs works', () {
      // Test the createCurrencyFormatter pattern we document - exact match to docs
      String Function(num) createCurrencyFormatter({String locale = 'en_US'}) {
        final formatter =
            NumberFormat.simpleCurrency(locale: locale); // Created once
        return (num value) => formatter.format(value); // Reused callback
      }

      final scale = LinearScale(labelFormatter: createCurrencyFormatter());
      // Exact match verification for documentation accuracy
      expect(scale.formatLabel(42), equals('\$42.00'));
    });

    test('createDurationFormatter example from docs works', () {
      // Test the createDurationFormatter pattern - seconds to human readable
      String Function(num) createDurationFormatter() {
        return (num seconds) {
          final roundedSeconds =
              seconds.round(); // Round to nearest second first

          if (roundedSeconds >= 3600) {
            final hours = roundedSeconds / 3600;
            if (hours == hours.round()) {
              return '${hours.round()}h'; // Clean: "1h", "2h", "24h"
            }
            return '${hours.toStringAsFixed(1)}h'; // Decimal: "1.5h", "2.3h"
          } else if (roundedSeconds >= 60) {
            final minutes = (roundedSeconds / 60).round();
            return '${minutes}m'; // "1m", "30m", "59m"
          }
          return '${roundedSeconds}s'; // "5s", "30s", "59s"
        };
      }

      final scale = LinearScale(labelFormatter: createDurationFormatter());
      expect(scale.formatLabel(30), equals('30s')); // Seconds
      expect(scale.formatLabel(150), equals('3m')); // Minutes
      expect(scale.formatLabel(3600), equals('1h')); // Clean whole hour
      expect(scale.formatLabel(7200), equals('2h')); // Clean whole hours
      expect(scale.formatLabel(5400), equals('1.5h')); // Decimal when needed
    });

    test('createChartCurrencyFormatter example from docs works', () {
      // Test the createChartCurrencyFormatter pattern - clean integer currency
      String Function(num) createChartCurrencyFormatter() {
        final formatter = NumberFormat.simpleCurrency(locale: 'en_US');
        return (num value) {
          if (value == value.roundToDouble()) {
            return formatter.format(value).replaceAll('.00', ''); // $42
          }
          return formatter.format(value); // $42.50
        };
      }

      final scale = LinearScale(labelFormatter: createChartCurrencyFormatter());
      // Exact match verification for documentation accuracy
      expect(scale.formatLabel(42), equals('\$42')); // Clean integer (no .00)
      expect(scale.formatLabel(42.50), equals('\$42.50')); // Keep decimals
    });

    test('createProfitLossFormatter example from docs works', () {
      // Test the createProfitLossFormatter pattern - profit/loss with +/- signs
      String Function(num) createProfitLossFormatter() {
        return (num value) {
          final abs = value.abs();
          final formatted = NumberFormat.compact().format(abs);
          return value >= 0 ? formatted : '($formatted)';
        };
      }

      final scale = LinearScale(labelFormatter: createProfitLossFormatter());
      expect(scale.formatLabel(1500), equals('1.5K')); // Positive
      expect(scale.formatLabel(-1500), equals('(1.5K)')); // Negative
      expect(scale.formatLabel(0), equals('0')); // Zero
    });

    test('createBasisPointFormatter example from docs works', () {
      // Test the createBasisPointFormatter pattern - finance basis points
      String Function(num) createBasisPointFormatter() {
        return (num value) => '${(value * 10000).toStringAsFixed(0)}bp';
      }

      final scale = LinearScale(labelFormatter: createBasisPointFormatter());
      expect(scale.formatLabel(0.0025), equals('25bp')); // 0.25% = 25bp
      expect(scale.formatLabel(0.01), equals('100bp')); // 1% = 100bp
      expect(scale.formatLabel(0.0001), equals('1bp')); // 0.01% = 1bp
    });
  });
}
