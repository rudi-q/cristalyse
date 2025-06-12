import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildLineChartTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Animated Line Chart'),
        SizedBox(height: 16),
        Container(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'x', y: 'y')
              .geomLine(strokeWidth: 1.0 + sliderValue * 9.0, alpha: 0.9)
              .scaleXContinuous()
              .scaleYContinuous()
              .theme(currentTheme)
              .animate(duration: Duration(milliseconds: 1200))
              .build(),
        ),
        SizedBox(height: 16),
        Text(
            '• Line draws from left to right\n• Smooth animation with partial segments\n• Responsive to theme changes'),
      ],
    ),
  );
}
