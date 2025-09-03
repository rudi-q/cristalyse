import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildStackedBarTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue Breakdown by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Stacked segments showing part-to-whole relationships with currency formatting',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'quarter', y: 'revenue', color: 'category')
              .geomBar(
                  width: sliderValue.clamp(0.1, 1.0),
                  style: BarStyle.stacked, // This is the key!
                  alpha: 0.9)
              .scaleXOrdinal()
              .scaleYContinuous(
                min: 0,
                labels: NumberFormat.simpleCurrency()
                    .format, // Direct NumberFormat usage
              )
              .theme(currentTheme)
              .legend(
                  position: LegendPosition.topRight,
                  orientation: LegendOrientation.horizontal)
              .animate(
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeOutQuart)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Segments stack on top of each other\n• Each color represents a different category\n• Right-side legend shows revenue categories\n• Direct NumberFormat.simpleCurrency() usage\n• Great for showing part-to-whole relationships\n• Animated segment-by-segment building'),
      ],
    ),
  );
}
