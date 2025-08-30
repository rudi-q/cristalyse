import 'package:flutter/material.dart' show Colors, Color;

/// Generates vibrant heat map colors using an enhanced blue-cyan-green-red gradient.
///
/// Creates a visually appealing color gradient designed for heat map visualizations
/// with enhanced intensity to ensure all cells remain visible and distinguishable.
/// The gradient progresses from dark blue (low values) through cyan and green
/// to bright red (high values).
///
/// The function applies a minimum intensity threshold to prevent cells from being
/// too faint, ensuring good visibility across the entire value range.
///
/// Parameters:
/// - [value]: A normalized value between 0.0 and 1.0. Values outside this range
///   are automatically clamped.
///
/// Returns a [Color] object representing the heat map color for the given value.
///
/// Color mapping:
/// - 0.0-0.5: Dark blue → Bright cyan
/// - 0.5-0.75: Bright cyan → Lime green
/// - 0.75-1.0: Lime green → Bright red
///
/// Examples:
/// ```dart
/// defaultHeatMapColor(0.0) => Dark blue (#000080 region)
/// defaultHeatMapColor(0.5) => Bright cyan (#00FFFF)
/// defaultHeatMapColor(1.0) => Bright red (#FF0000 region)
/// ```
Color defaultHeatMapColor(double value) {
  // Enhanced default gradient with higher intensity
  value = value.clamp(0.0, 1.0).toDouble();
  value = value.clamp(0.0, 1.0);

  // Make colors more vibrant and increase the minimum intensity
  final minIntensity = 0.4; // Ensure cells are never too faint
  final adjustedValue = minIntensity + (value * (1.0 - minIntensity));

  if (adjustedValue < 0.5) {
    // Dark blue to bright cyan (more intense)
    return Color.lerp(
      const Color(0xFF000080), // Dark blue
      const Color(0xFF00FFFF), // Bright cyan
      adjustedValue * 2,
    )!;
  } else if (adjustedValue < 0.75) {
    // Bright cyan to lime green
    return Color.lerp(
      const Color(0xFF00FFFF), // Bright cyan
      const Color(0xFF32FF32), // Lime green
      (adjustedValue - 0.5) * 4,
    )!;
  } else {
    // Lime green to bright red
    return Color.lerp(
      const Color(0xFF32FF32), // Lime green
      const Color(0xFFFF0000), // Bright red
      (adjustedValue - 0.75) * 4,
    )!;
  }
}

/// Interpolates smoothly between colors in a custom gradient based on a normalized value.
///
/// Given a list of colors and a normalized value (0.0-1.0), this function
/// calculates the appropriate color by interpolating between adjacent colors
/// in the gradient. The interpolation uses Flutter's [Color.lerp] for smooth
/// color transitions.
///
/// Parameters:
/// - [value]: A normalized value between 0.0 and 1.0. Values outside this range
///   are automatically clamped.
/// - [gradient]: A list of colors defining the gradient. Must not be empty.
///
/// Returns:
/// - The interpolated [Color] based on the value's position in the gradient.
/// - [Colors.grey] if the gradient list is empty.
/// - The single color if the gradient contains only one color.
/// - The last color if the value maps beyond the gradient range.
///
/// Examples:
/// ```dart
/// final gradient = [Colors.blue, Colors.green, Colors.red];
/// interpolateGradientColor(0.0, gradient) => Colors.blue
/// interpolateGradientColor(0.5, gradient) => Colors.green
/// interpolateGradientColor(1.0, gradient) => Colors.red
/// interpolateGradientColor(0.25, gradient) => Blue-green blend
/// ```
Color interpolateGradientColor(double value, List<Color> gradient) {
  // Ensure value is in [0, 1]
  value = value.clamp(0.0, 1.0).toDouble();

  if (gradient.isEmpty) return Colors.grey;
  if (gradient.length == 1) return gradient.first;

  // Calculate position in gradient
  final scaledValue = value * (gradient.length - 1);
  final index = scaledValue.floor();
  final t = scaledValue - index;

  if (index >= gradient.length - 1) {
    return gradient.last;
  }

  return Color.lerp(gradient[index], gradient[index + 1], t)!;
}
