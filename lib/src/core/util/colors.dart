import 'package:flutter/material.dart' show Colors, Color;

Color defaultHeatMapColor(double value) {
  // Enhanced default gradient with higher intensity
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

Color interpolateGradientColor(double value, List<Color> gradient) {
  // Ensure value is in [0, 1]
  value = value.clamp(0.0, 1.0);

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
