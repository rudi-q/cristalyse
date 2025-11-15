import 'package:cristalyse/cristalyse.dart' show Geometry;

import '../geometry.dart' show YAxis;

/// Intelligently sorts heatmap values with special handling for dates, times, and common patterns.
///
/// This function provides context-aware sorting that recognizes and properly orders:
/// - Days of the week (both full names and abbreviations)
/// - Months (both full names and abbreviations)
/// - Time values (12-hour and 24-hour formats)
/// - Numeric values
/// - Alphabetical fallback for other strings
///
/// The sorting normalizes Sunday to position 7 for a Monday-first weekly view.
/// Time values are converted to minutes since midnight for proper chronological ordering.
///
/// Parameters:
/// - [values]: The list of dynamic values to sort in-place.
///
/// Examples:
/// ```dart
/// final days = ['wed', 'mon', 'fri', 'tue'];
/// sortHeatMapValues(days); // Result: ['mon', 'tue', 'wed', 'fri']
///
/// final times = ['2pm', '8am', '10:30am', '14:45'];
/// sortHeatMapValues(times); // Result: ['8am', '10:30am', '2pm', '14:45']
/// ```
void sortHeatMapValues(List<dynamic> values) {
  // Define ordered lists for common patterns
  final dayOrder = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sun',
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
  ];

  final monthOrder = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];

  values.sort((a, b) {
    final aStr = a.toString().toLowerCase();
    final bStr = b.toString().toLowerCase();

    // Check if both are days of the week
    final aDay = dayOrder.indexOf(aStr);
    final bDay = dayOrder.indexOf(bStr);
    if (aDay != -1 && bDay != -1) {
      // Both are days - use day order, but normalize Sunday=0 to Sunday=7 for weekly view
      final normalizedA =
          aDay < 7 ? (aDay == 0 ? 7 : aDay) : (aDay - 7 == 0 ? 7 : aDay - 7);
      final normalizedB =
          bDay < 7 ? (bDay == 0 ? 7 : bDay) : (bDay - 7 == 0 ? 7 : bDay - 7);
      return normalizedA.compareTo(normalizedB);
    }

    // Check if both are months
    final aMonth = monthOrder.indexOf(aStr);
    final bMonth = monthOrder.indexOf(bStr);
    if (aMonth != -1 && bMonth != -1) {
      final normalizedA = aMonth < 12 ? aMonth : aMonth - 12;
      final normalizedB = bMonth < 12 ? bMonth : bMonth - 12;
      return normalizedA.compareTo(normalizedB);
    }

    // Check if both are time values (like 8am, 2pm, 14:30, etc.)
    final aTime = parseTimeValue(aStr);
    final bTime = parseTimeValue(bStr);
    if (aTime != null && bTime != null) {
      return aTime.compareTo(bTime);
    }

    // Check if both are numeric
    final aNum = double.tryParse(aStr);
    final bNum = double.tryParse(bStr);
    if (aNum != null && bNum != null) {
      return aNum.compareTo(bNum);
    }

    // Fall back to alphabetical sorting
    return aStr.compareTo(bStr);
  });
}

/// Parses various time format strings into minutes since midnight for comparison.
///
/// Supports multiple time formats including:
/// - 12-hour format: "8am", "2pm", "11:30pm", "12:15am"
/// - 24-hour format: "14:30", "09:15", "23:45"
/// - Hour-only formats: "8h", "14h"
/// - Compact formats: "830am", "1430", "915pm"
///
/// The function normalizes all formats to minutes since midnight (0-1439)
/// for consistent chronological comparison.
///
/// Parameters:
/// - [timeStr]: The time string to parse.
///
/// Returns the time as minutes since midnight, or null if parsing fails.
///
/// Examples:
/// ```dart
/// parseTimeValue('8am') => 480      // 8 * 60 = 480 minutes
/// parseTimeValue('2:30pm') => 870   // 14 * 60 + 30 = 870 minutes
/// parseTimeValue('14:30') => 870    // Same as 2:30pm
/// parseTimeValue('midnight') => null // Invalid format
/// ```
int? parseTimeValue(String timeStr) {
  // Remove common time separators and normalize
  final normalized = timeStr.replaceAll(RegExp(r'[:\s]'), '').toLowerCase();

  // Match patterns like 8am, 2pm, 14h, 830am, 915pm, etc.
  final timeRegex = RegExp(r'^(\d{1,2})(\d{2})?(am|pm|h)?$');
  final match = timeRegex.firstMatch(normalized);

  if (match == null) return null;

  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  final meridiem = match.group(3);

  if (hour == null || hour < 0 || hour > 23) return null;
  if (minute < 0 || minute > 59) return null;

  int finalHour = hour;

  // Handle AM/PM
  if (meridiem == 'am') {
    if (hour == 12) finalHour = 0; // 12am = midnight
  } else if (meridiem == 'pm') {
    if (hour != 12) finalHour = hour + 12; // Convert to 24-hour format
  }
  // For 'h' suffix or no suffix, assume 24-hour format already

  return finalHour * 60 + minute; // Convert to minutes since midnight
}

/// Converts dynamic values to double, handling both numeric and string inputs.
///
/// Returns the numeric value as a double if the input is a number or a valid
/// numeric string. Returns null for non-numeric values.
///
/// Examples:
/// ```dart
/// getNumericValue(42) => 42.0
/// getNumericValue('3.14') => 3.14
/// getNumericValue('hello') => null
/// ```
double? getNumericValue(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Determines if a data column contains categorical (string or boolean) values.
///
/// Examines the first non-null value in the specified column to determine
/// if the data type is categorical (String or bool) rather than numeric.
/// For String values, attempts to parse as a number - only treats as categorical
/// if parsing fails.
///
/// Parameters:
/// - [column]: The column name to check. Returns false if null.
/// - [data]: The dataset to examine. Returns false if empty.
///
/// Returns true if the column contains categorical data, false otherwise.
///
/// Example:
/// ```dart
/// final data = [{'category': 'A', 'value': 10}, {'category': 'B', 'value': '200'}];
/// isColumnCategorical('category', data) => true  // String that's not numeric
/// isColumnCategorical('value', data) => false    // Numeric value
/// isColumnCategorical('value', [{'value': '200'}]) => false // Numeric string
/// ```
bool isColumnCategorical(String? column, List<Map<String, dynamic>> data) {
  if (column == null || data.isEmpty) return false;
  for (final row in data) {
    final value = row[column];
    if (value != null) {
      // Treat bool as categorical
      if (value is bool) return true;

      // Treat numeric types as non-categorical
      if (value is num) return false;

      // For strings, attempt to parse as number
      if (value is String) {
        // If we can parse it as a number, it's not categorical
        if (num.tryParse(value) != null) return false;
        // If parsing fails, it's categorical
        return true;
      }

      // For other types, consider non-categorical
      return false;
    }
  }
  return false;
}

/// Determines if the chart configuration includes a secondary Y-axis.
///
/// A secondary Y-axis is present when both conditions are met:
/// 1. A secondary Y column is specified ([y2Column] is not null)
/// 2. At least one geometry is configured to use [YAxis.secondary]
///
/// Parameters:
/// - [y2Column]: The name of the secondary Y column. Can be null.
/// - [geometries]: The list of chart geometries to examine.
///
/// Returns true if a secondary Y-axis should be displayed, false otherwise.
///
/// Example:
/// ```dart
/// final geometries = [LineGeometry(yAxis: YAxis.secondary)];
/// hasSecondaryYAxis(y2Column: 'price2', geometries: geometries) => true
/// hasSecondaryYAxis(y2Column: null, geometries: geometries) => false
/// ```
bool hasSecondaryYAxis({String? y2Column, required List<Geometry> geometries}) {
  return y2Column != null && geometries.any((g) => g.yAxis == YAxis.secondary);
}
