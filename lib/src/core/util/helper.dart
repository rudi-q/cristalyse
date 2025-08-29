import 'package:cristalyse/cristalyse.dart' show Geometry;

import '../geometry.dart' show YAxis;

/// Smart sorting for heatmap values that handles days of the week and time properly
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
    'sat'
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
    'dec'
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

/// Parse time values like "8am", "2pm", "14:30", "9:15am" into comparable integers (minutes since midnight)
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

double? getNumericValue(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool isColumnCategorical(String? column, List<Map<String, dynamic>> data) {
  if (column == null || data.isEmpty) return false;
  for (final row in data) {
    final value = row[column];
    if (value != null) {
      return value is String || value is bool;
    }
  }
  return false;
}

bool hasSecondaryYAxis({String? y2Column, required List<Geometry> geometries}) {
  return y2Column != null && geometries.any((g) => g.yAxis == YAxis.secondary);
}
