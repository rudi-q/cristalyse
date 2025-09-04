import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildMultiSeriesLineChartTab(
    ChartTheme currentTheme, double sliderValue) {
  // Multi-series data exactly like the documentation example that was broken
  final data = [
    {'month': 'Jan', 'platform': 'iOS', 'users': 1200},
    {'month': 'Jan', 'platform': 'Android', 'users': 800},
    {'month': 'Feb', 'platform': 'iOS', 'users': 1350},
    {'month': 'Feb', 'platform': 'Android', 'users': 950},
    {'month': 'Mar', 'platform': 'iOS', 'users': 1480},
    {'month': 'Mar', 'platform': 'Android', 'users': 1100},
    {'month': 'Apr', 'platform': 'iOS', 'users': 1620},
    {'month': 'Apr', 'platform': 'Android', 'users': 1250},
    {'month': 'May', 'platform': 'iOS', 'users': 1750},
    {'month': 'May', 'platform': 'Android', 'users': 1400},
    {'month': 'Jun', 'platform': 'iOS', 'users': 1890},
    {'month': 'Jun', 'platform': 'Android', 'users': 1580},
  ];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart 1: Multi-series Line + Points (the main fix demonstration)
        Text(
          'Multi-Series Line Chart with Points',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Using the exact code from the documentation that was previously broken',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'month', y: 'users', color: 'platform')
              .geomLine(strokeWidth: 2.0 + sliderValue * 3.0)
              .geomPoint(size: 4.0 + sliderValue * 4.0)
              .scaleXOrdinal()
              .scaleYContinuous(min: 0)
              .theme(currentTheme)
              .animate(duration: const Duration(milliseconds: 1500))
              .legend(position: LegendPosition.right)
              .build(),
        ),

        const SizedBox(height: 24),

        // Chart 2: Lines only (no points)
        Text(
          'Multi-Series Lines Only',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Demonstrates clean line separation without points',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 350,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'month', y: 'users', color: 'platform')
              .geomLine(
                strokeWidth: 3.0 + sliderValue * 2.0,
                alpha: 0.8 + sliderValue * 0.2,
              )
              .scaleXOrdinal()
              .scaleYContinuous(min: 0)
              .theme(currentTheme)
              .animate(duration: const Duration(milliseconds: 1200))
              .legend(position: LegendPosition.bottom)
              .build(),
        ),

        const SizedBox(height: 24),

        // Chart 3: Three series to really show the multi-series capability
        Text(
          'Three-Series Comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'iOS vs Android vs Web platforms - each with separate lines',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 400,
          child: () {
            // Three-series data
            final threeSeriesData = [
              {'month': 'Jan', 'platform': 'iOS', 'users': 1200},
              {'month': 'Jan', 'platform': 'Android', 'users': 800},
              {'month': 'Jan', 'platform': 'Web', 'users': 600},
              {'month': 'Feb', 'platform': 'iOS', 'users': 1350},
              {'month': 'Feb', 'platform': 'Android', 'users': 950},
              {'month': 'Feb', 'platform': 'Web', 'users': 720},
              {'month': 'Mar', 'platform': 'iOS', 'users': 1480},
              {'month': 'Mar', 'platform': 'Android', 'users': 1100},
              {'month': 'Mar', 'platform': 'Web', 'users': 850},
              {'month': 'Apr', 'platform': 'iOS', 'users': 1620},
              {'month': 'Apr', 'platform': 'Android', 'users': 1250},
              {'month': 'Apr', 'platform': 'Web', 'users': 980},
              {'month': 'May', 'platform': 'iOS', 'users': 1750},
              {'month': 'May', 'platform': 'Android', 'users': 1400},
              {'month': 'May', 'platform': 'Web', 'users': 1120},
              {'month': 'Jun', 'platform': 'iOS', 'users': 1890},
              {'month': 'Jun', 'platform': 'Android', 'users': 1580},
              {'month': 'Jun', 'platform': 'Web', 'users': 1280},
            ];

            // Define colors for specific categories
            final Map<String, Color> categoryColors = {
              'iOS': const Color(0xFF007ACC), // Brand blue
              'Android': const Color(0xFF3DDC84), // Android green
              'Web': const Color(0xFFFF6B35), // Web orange
            };

            return CristalyseChart()
                .data(threeSeriesData)
                .mapping(x: 'month', y: 'users', color: 'platform')
                .geomLine(strokeWidth: 2.5)
                .geomPoint(size: 3.5)
                .scaleXOrdinal()
                .scaleYContinuous(min: 0)
                .theme(currentTheme)
                .customPalette(categoryColors: categoryColors)
                .animate(duration: const Duration(milliseconds: 1800))
                .legend(
                    position: LegendPosition.topRight,
                    orientation: LegendOrientation.horizontal)
                .build();
          }(),
        ),
      ],
    ),
  );
}
