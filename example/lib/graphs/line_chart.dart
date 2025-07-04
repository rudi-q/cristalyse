import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildLineChartTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animated Line Chart'),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'x', y: 'y')
              .geomLine(strokeWidth: 1.0 + sliderValue * 9.0, alpha: 0.9)
              .scaleXContinuous()
              .scaleYContinuous()
              .theme(currentTheme)
              .animate(duration: const Duration(milliseconds: 1200))
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Line draws from left to right\n• Smooth animation with partial segments\n• Responsive to theme changes'),
      ],
    ),
  );
}
