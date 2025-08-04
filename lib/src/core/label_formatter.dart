/// Label formatting utility for Cristalyse charts.
///
/// This library provides a flexible label formatting system that allows developers
/// to customize how values are displayed on chart axes and labels. It supports
/// both simple callbacks and advanced integration with e.g. NumberFormat and
/// factories with conditional logic.
///
/// Example usage:
/// ```dart
/// import 'package:intl/intl.dart';
///
/// // Simple custom formatting
/// final formatter = LabelFormatter((value) => '${value}K');
///
/// // NumberFormat integration
/// final currencyFormatter = LabelFormatter(
///   NumberFormat.currency(symbol: '\$', decimalDigits: 0).format
/// );
///
/// // Default formatting (with older cristalyse behavior)
/// final defaultFormatter = LabelFormatter();
/// ```
library;

/// Type definition for label formatting callbacks.
///
/// Defines a function that takes a numeric value and returns a formatted string.
/// This callback signature is compatible with NumberFormat.format methods.
///
/// Example:
/// ```dart
/// LabelCallback formatter = (value) => '${value.toStringAsFixed(2)}%';
/// LabelCallback currencyFormatter = NumberFormat.currency().format;
/// ```
typedef LabelCallback = String Function(num value);

/// Handles label formatting with callback support and smart fallbacks.
///
/// The [LabelFormatter] class provides a composition-based approach to value
/// formatting with a smart fallback chain:
/// 1. Custom callback (if provided)
/// 2. Default is the original integer/decimal formatting
/// 3. toString() fallback for non-numeric values
///
/// This ensures backwards compatibility while enabling robust customization.
class LabelFormatter {
  final LabelCallback? _customCallback;

  const LabelFormatter([this._customCallback]);

  /// Format a value with smart fallback chain:
  /// custom callback → default formatter → toString()
  String format(dynamic value) {
    if (value is num) {
      if (_customCallback != null) {
        return _customCallback!(value);
      }
      return _formatDefault(value);
    }
    return value.toString();
  }

  static String _formatDefault(num value) {
    if (value == value.roundToDouble()) {
      return value.round().toString(); // Integer: 42
    } else {
      return value.toStringAsFixed(1); // Decimal: 42.5
    }
  }
}
