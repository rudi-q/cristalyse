import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class HeatMapExample extends StatelessWidget {
  final ChartTheme theme;
  final List<Color> colorPalette;

  const HeatMapExample({
    super.key,
    required this.theme,
    required this.colorPalette,
  });

  List<Map<String, dynamic>> _generateHeatMapData() {
    // Generate data for a weekly activity heatmap
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hours = [
      '12am',
      '2am',
      '4am',
      '6am',
      '8am',
      '10am',
      '12pm',
      '2pm',
      '4pm',
      '6pm',
      '8pm',
      '10pm'
    ];

    final random = math.Random(42); // Fixed seed for consistency
    final data = <Map<String, dynamic>>[];

    for (final day in days) {
      for (int i = 0; i < hours.length; i++) {
        final hour = hours[i];

        // Create realistic patterns
        double baseValue = 0.3;

        // Higher activity during work hours on weekdays
        if (['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].contains(day)) {
          if (i >= 4 && i <= 9) {
            // 8am to 6pm
            baseValue = 0.7;
          }
        }

        // Lower activity on weekends
        if (['Sat', 'Sun'].contains(day)) {
          baseValue = 0.2;
          if (i >= 5 && i <= 8) {
            // Late morning on weekends
            baseValue = 0.5;
          }
        }

        // Add some randomness
        final value =
            (baseValue + (random.nextDouble() - 0.5) * 0.3).clamp(0.0, 1.0) *
                100; // Convert to percentage

        // Occasionally add null values to show gaps
        if (random.nextDouble() < 0.05) {
          data.add({
            'day': day,
            'hour': hour,
            'activity': null,
          });
        } else {
          data.add({
            'day': day,
            'hour': hour,
            'activity': value,
          });
        }
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final heatMapData = _generateHeatMapData();

    // Create a custom color gradient from blue to red
    final heatMapColors = [
      Colors.blue.shade50,
      Colors.blue.shade200,
      Colors.green.shade300,
      Colors.yellow.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.red.shade700,
    ];

    return Column(
      children: [
        // Compact header without padding
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Activity Heatmap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.axisColor,
                      ),
                    ),
                    Text(
                      'User engagement patterns throughout the week',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.axisColor.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
              // Inline legend to save space
              Row(
                children: [
                  Text(
                    '0%',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.axisColor.withAlpha(179),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: heatMapColors,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.axisColor.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Expanded chart area with minimal padding
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: AnimatedCristalyseChartWidget(
              data: heatMapData,
              heatMapXColumn: 'day',
              heatMapYColumn: 'hour',
              heatMapValueColumn: 'activity',
              geometries: [
                HeatMapGeometry(
                  cellSpacing: 1,
                  cellBorderRadius: BorderRadius.circular(3),
                  showValues: true,
                  valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
                  valueTextStyle: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  minValue: 0,
                  maxValue: 100,
                  colorGradient: heatMapColors,
                  interpolateColors: true,
                  nullValueColor: Colors.grey.shade200,
                ),
              ],
              theme: theme,
              animationDuration: const Duration(milliseconds: 800),
              animationCurve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }
}

// Alternative: Monthly contribution heatmap (like GitHub)
class ContributionHeatMap extends StatelessWidget {
  final ChartTheme theme;

  const ContributionHeatMap({
    super.key,
    required this.theme,
  });

  List<Map<String, dynamic>> _generateContributionData() {
    final weeks = List.generate(12, (i) => 'W${i + 1}');
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final random = math.Random(42);
    final data = <Map<String, dynamic>>[];

    for (final week in weeks) {
      for (final day in days) {
        // Simulate contribution counts with realistic patterns
        double probability = 0.7; // 70% chance of having contributions

        // Lower on weekends
        if (day == 'Sun' || day == 'Sat') {
          probability = 0.3;
        }

        if (random.nextDouble() < probability) {
          // Generate contribution count (0-10)
          final contributions = (random.nextDouble() * 10).round();
          data.add({
            'week': week,
            'day': day,
            'contributions': contributions,
          });
        } else {
          data.add({
            'week': week,
            'day': day,
            'contributions': 0,
          });
        }
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final contributionData = _generateContributionData();

    // GitHub-style color scheme
    final contributionColors = [
      const Color(0xFFEBEDF0), // No contributions
      const Color(0xFF9BE9A8), // Light green
      const Color(0xFF40C463), // Medium green
      const Color(0xFF30A14E), // Dark green
      const Color(0xFF216E39), // Darkest green
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contribution Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.axisColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Code contributions over the last 12 weeks',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.axisColor.withAlpha(179),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedCristalyseChartWidget(
              data: contributionData,
              heatMapXColumn: 'week',
              heatMapYColumn: 'day',
              heatMapValueColumn: 'contributions',
              geometries: [
                HeatMapGeometry(
                  cellSpacing: 3,
                  cellBorderRadius: BorderRadius.circular(2),
                  showValues: false, // Don't show values for cleaner look
                  minValue: 0,
                  maxValue: 10,
                  colorGradient: contributionColors,
                  interpolateColors: false, // Use discrete colors
                  nullValueColor: const Color(0xFFEBEDF0),
                  cellAspectRatio: 1.0, // Square cells
                ),
              ],
              theme: theme,
              animationDuration: const Duration(milliseconds: 1000),
              animationCurve: Curves.easeOutBack,
            ),
          ),
        ),
        // Legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.axisColor.withAlpha(179),
                ),
              ),
              const SizedBox(width: 4),
              ...contributionColors.map((color) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                  )),
              const SizedBox(width: 4),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.axisColor.withAlpha(179),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget buildHeatMapTab(ChartTheme theme, List<Color> colorPalette) {
  return HeatMapExample(
    theme: theme,
    colorPalette: colorPalette,
  );
}

Widget buildContributionHeatMapTab(ChartTheme theme) {
  return ContributionHeatMap(theme: theme);
}
