import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildComboBarLineTab(ChartTheme currentTheme, double sliderValue) {
  // Data for the Combo Chart displaying Categorical mapping on Bars and fixed Line color
  final comboData = [
    {'month': 'Jan', 'revenue': 120, 'category': 'Product A'},
    {'month': 'Feb', 'revenue': 150, 'category': 'Product A'},
    {'month': 'Mar', 'revenue': 180, 'category': 'Product A'},
    {'month': 'Apr', 'revenue': 220, 'category': 'Product A'},
    {'month': 'Jan', 'revenue': 80, 'category': 'Product B'},
    {'month': 'Feb', 'revenue': 90, 'category': 'Product B'},
    {'month': 'Mar', 'revenue': 100, 'category': 'Product B'},
    {'month': 'Apr', 'revenue': 140, 'category': 'Product B'},
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          'Bar + Line Combo Chart',
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
                  .data(comboData)
                  .mapping(x: 'month', y: 'revenue', color: 'category')
                  // Bar uses mapped categorical color
                  .geomBar(width: sliderValue.clamp(0.1, 1.0), alpha: 0.8)
                  // Line uses a fixed color, so it should be continuous and not fragment by category
                  .geomLine(color: Colors.blue[800], strokeWidth: 3.0)
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
        const SelectableText(
          '• Demonstrates a mix of mapped aesthetic (color: category) for bars.\n• Demonstrates fixed aesthetic (color: fixed) for the line, keeping it a single continuous line instead of breaking it apart.\n• Visual confirmation for Bug Fix #82.',
        ),
      ],
    ),
  );
}
