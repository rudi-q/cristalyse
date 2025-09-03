import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildGroupedBarTab(ChartTheme currentTheme,
    List<Map<String, dynamic>> data, double sliderValue) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Performance by Quarter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Multiple product lines compared side-by-side with currency formatting',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'quarter', y: 'revenue', color: 'product')
              .geomBar(
                  width: sliderValue.clamp(0.1, 1.0),
                  style: BarStyle.grouped,
                  alpha: 0.9)
              .scaleXOrdinal()
              .scaleYContinuous(
                min: 0,
                labels: NumberFormat.simpleCurrency()
                    .format, // Direct NumberFormat usage
              )
              .theme(currentTheme)
              .legend(position: LegendPosition.topRight)
              .animate(
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic)
              .build(),
        ),
        const SizedBox(height: 16),
        const Text(
            '• Multiple series grouped side-by-side\n• Uses direct NumberFormat.simpleCurrency()\n• Color mapping for different products\n• Auto-generated legend shows product categories\n• Coordinated group animation'),
      ],
    ),
  );
}
