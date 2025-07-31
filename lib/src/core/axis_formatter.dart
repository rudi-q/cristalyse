/// Axis type enumeration for formatter selection
enum AxisType { x, y, y2 }

/// Formatter for axis labels with support for prefix, suffix, and # of decimal places
class AxisFormatter {
  final String prefix;
  final String suffix;
  final int? decimals;

  const AxisFormatter({
    this.prefix = '',
    this.suffix = '',
    this.decimals,
  });

  /// Default formatter (no changes to labels)
  static const AxisFormatter defaultFormatter = AxisFormatter();

  /// Format a value according to the instance configuration
  String format(dynamic value) {
    if (value is num) {
      final String numericString;

      // Handle special double values
      if (value.isInfinite || value.isNaN) {
        numericString = value.toString();
      } else if (decimals != null) {
        // Use specified decimal places
        numericString = value.toStringAsFixed(decimals!);
      } else {
        // Use default logic: integers without decimals, others with 1 decimal place
        if (value == value.roundToDouble()) {
          numericString = value.round().toString();
        } else {
          numericString = value.toStringAsFixed(1);
        }
      }

      return '$prefix$numericString$suffix';
    } else if (value is String) {
      // For string values, add prefix/suffix
      return '$prefix$value$suffix';
    } else {
      // For any other types that may arise, return the value as-is
      return value.toString();
    }
  }

  /// Create a copy of this formatter with updated values
  AxisFormatter copyWith({
    String? prefix,
    String? suffix,
    int? decimals,
  }) {
    return AxisFormatter(
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      decimals: decimals ?? this.decimals,
    );
  }

  /// Common formatters for convenience

  /// Currency formatter with $ prefix
  static const AxisFormatter currency = AxisFormatter(prefix: '\$');

  /// Percentage formatter with % suffix
  static const AxisFormatter percentage = AxisFormatter(suffix: '%');

  /// Currency formatter with custom prefix
  static AxisFormatter currencyWithSymbol(String symbol) =>
      AxisFormatter(prefix: symbol);

  /// Formatter with custom prefix and suffix
  static AxisFormatter custom({
    String prefix = '',
    String suffix = '',
    int? decimals,
  }) =>
      AxisFormatter(
        prefix: prefix,
        suffix: suffix,
        decimals: decimals,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AxisFormatter &&
        other.prefix == prefix &&
        other.suffix == suffix &&
        other.decimals == decimals;
  }

  @override
  int get hashCode => Object.hash(prefix, suffix, decimals);

  @override
  String toString() {
    return 'AxisFormatter(prefix: "$prefix", suffix: "$suffix", decimals: $decimals)';
  }
}
