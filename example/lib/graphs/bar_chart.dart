import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

/// Static demo data for positive/negative value chart
const List<Map<String, dynamic>> _mixedDemoData = [
  {'category': 'A', 'value': 25.0},
  {'category': 'B', 'value': -15.0},
  {'category': 'C', 'value': 40.0},
  {'category': 'D', 'value': -30.0},
  {'category': 'E', 'value': 10.0},
  {'category': 'F', 'value': -20.0},
];

Widget buildBarChartTab(
  ChartTheme currentTheme,
  List<Map<String, dynamic>> data,
  double sliderValue,
) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standard Bar Chart
        Text(
          'Standard Bar Chart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child:
              CristalyseChart()
                  .data(data)
                  .mapping(x: 'quarter', y: 'revenue')
                  .geomBar(width: sliderValue.clamp(0.1, 1.0), alpha: 0.8)
                  .scaleXOrdinal()
                  .scaleYContinuous(min: 0)
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                  )
                  .build(),
        ),
        const SizedBox(height: 16),
        const Text(
          '• Bars grow from bottom with staggered timing\n• Categorical X-axis with ordinal scale\n• Smooth back-ease animation',
        ),
        const SizedBox(height: 32),

        // Custom Rounded Bars (Positive/Negative)
        Text(
          'Smart Rounded Corners (Positive/Negative)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.new_releases, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New Feature: roundOutwardEdges property',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976D2), // Colors.blue[700]
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child:
              CristalyseChart()
                  .data(_mixedDemoData)
                  .mapping(x: 'category', y: 'value')
                  .geomBar(
                    width: sliderValue.clamp(0.1, 1.0),
                    alpha: 0.9,
                    borderRadius: BorderRadius.circular(15),
                    roundOutwardEdges: true,
                    positiveColor: Colors.green,
                    negativeColor: Colors.red,
                  )
                  .scaleXOrdinal()
                  .scaleYContinuous()
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                  )
                  .build(),
        ),
        const SizedBox(height: 16),
        const Text(
          '• positiveColor: green for gains/profits\n• negativeColor: red for losses/deficits\n• roundOutwardEdges: smart corner rounding\n• Perfect for financial data and variance charts',
        ),
      ],
    ),
  );
}
