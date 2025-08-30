import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse_example/chart_theme.dart';
import 'package:flutter/material.dart';

Widget buildScatterPlotTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Animated Scatter Plot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'x', y: 'y', color: 'category', size: 'size')
              .geomPoint(alpha: 0.8)
              .scaleXContinuous()
              .scaleYContinuous()
              .theme(currentTheme.copyWith(
                pointSizeMax: 2.0 + sliderValue * 20.0,
              ))
              .animate(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Points animate in with staggered timing\n• Size and color mapped to data\n• Smooth elastic animation curve'),
      ],
    ),
  );
}
