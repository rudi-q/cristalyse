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

  // Distinct data for the Line to avoid drawing a zigzag path due to multiple points
  final lineData = [
    {'month': 'Jan', 'revenue': 100},
    {'month': 'Feb', 'revenue': 120},
    {'month': 'Mar', 'revenue': 140},
    {'month': 'Apr', 'revenue': 180},
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 400,
          child: Stack(
            children: [
              // 1. Bottom Chart: The Categorical Bars
              CristalyseChart()
                  .data(comboData)
                  .mapping(x: 'month', y: 'revenue', color: 'category')
                  .geomBar(width: sliderValue.clamp(0.1, 1.0), alpha: 0.8)
                  .scaleXOrdinal()
                  .scaleYContinuous(
                    min: 0,
                    max: 250,
                  ) // Fix scale to align layers
                  .theme(currentTheme)
                  .animate(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                  )
                  .build(),
              // 2. Top Chart: The Continuous Line with average Data
              CristalyseChart()
                  .data(lineData)
                  .mapping(x: 'month', y: 'revenue') // No color mapping!
                  // Line uses explicit fixed color
                  .geomLine(color: Colors.blue.shade800, strokeWidth: 3.0)
                  .scaleXOrdinal()
                  .scaleYContinuous(
                    min: 0,
                    max: 250,
                  ) // Fix scale to align layers
                  // Make theme transparent so it doesn't draw a second set of axes/grids
                  .theme(
                    currentTheme.copyWith(
                      backgroundColor: Colors.transparent,
                      plotBackgroundColor: Colors.transparent,
                      gridColor: Colors.transparent,
                      axisColor: Colors.transparent,
                      axisLabelStyle:
                          currentTheme.axisLabelStyle != null
                              ? currentTheme.axisLabelStyle!.copyWith(
                                color: Colors.transparent,
                              )
                              : const TextStyle(color: Colors.transparent),
                    ),
                  )
                  .animate(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                  )
                  .build(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SelectableText(
          '• Demonstrates a mix of mapped aesthetic (color: category) for bars.\n• Demonstrates fixed aesthetic (color: fixed) for the line, keeping it a single continuous line instead of breaking it apart.\n• Visual confirmation for fix.',
        ),
      ],
    ),
  );
}
