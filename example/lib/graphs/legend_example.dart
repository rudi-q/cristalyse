import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildLegendExampleTab(
  BuildContext context,
  ChartTheme currentTheme,
  List<Map<String, dynamic>> data,
  double sliderValue,
) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend Examples',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: currentTheme.axisColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Demonstrating different legend positions and configurations',
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),

        // Example 1: Floating Legend
        _buildExampleSection(
          context: context,
          title: 'Floating Legend with Custom Position & Interactivity',
          description:
              'Free-floating legend with absolute positioning - perfect for overlays',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomBar(
                      width: sliderValue.clamp(0.1, 1.0).toDouble(),
                      style: BarStyle.grouped,
                      alpha: 0.9,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 10,
                      labels: NumberFormat.simpleCurrency().format,
                      title: 'Revenue',
                    )
                    .theme(currentTheme)
                    .legend(
                      position: LegendPosition.floating,
                      interactive: true,
                      floatingOffset: const Offset(150, 30), // x: 150, y: 30
                      backgroundColor: currentTheme.backgroundColor.withValues(
                        alpha: 0.95,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      symbolSize: 12.0,
                      itemSpacing: 10.0,
                      borderRadius: 8.0,
                    ) // <- Floating legend
                    .animate(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                    )
                    .build(),
          ),
        ),

        const SizedBox(height: 32),

        // Example 2: Basic legend (default topRight position)
        _buildExampleSection(
          context: context,
          title: 'Basic Legend (Default Position)',
          description: 'Simple .legend() call with smart defaults',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomBar(
                      width: sliderValue.clamp(0.1, 1.0).toDouble(),
                      style: BarStyle.grouped,
                      alpha: 0.9,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 0,
                      labels: NumberFormat.simpleCurrency().format,
                    )
                    .theme(currentTheme)
                    .legend() // <- Basic legend with defaults
                    .animate(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                    )
                    .build(),
          ),
        ),

        const SizedBox(height: 32),

        // Example 3: Bottom positioned legend
        _buildExampleSection(
          context: context,
          title: 'Bottom Legend',
          description: 'Legend positioned at the bottom of the chart',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomBar(
                      width: sliderValue.clamp(0.1, 1.0).toDouble(),
                      style: BarStyle.grouped,
                      alpha: 0.9,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 0,
                      labels: NumberFormat.simpleCurrency().format,
                    )
                    .theme(currentTheme)
                    .legend(
                      position: LegendPosition.bottom,
                    ) // <- Bottom position
                    .animate(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                    )
                    .build(),
          ),
        ),

        const SizedBox(height: 32),

        // Example 4: Right positioned legend with custom styling
        _buildExampleSection(
          context: context,
          title: 'Right Legend with Custom Styling',
          description:
              'Custom background and symbol size (text adapts to theme)',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomBar(
                      width: sliderValue.clamp(0.1, 1.0).toDouble(),
                      style: BarStyle.grouped,
                      alpha: 0.9,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 0,
                      labels: NumberFormat.simpleCurrency().format,
                    )
                    .theme(currentTheme)
                    .legend(
                      position: LegendPosition.right,
                      backgroundColor: currentTheme.backgroundColor.withValues(
                        alpha: 0.95,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        // No color specified - automatically uses theme color
                      ),
                      symbolSize: 14.0,
                      itemSpacing: 12.0,
                      borderRadius: 8.0,
                    ) // <- Styled legend
                    .animate(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                    )
                    .build(),
          ),
        ),

        const SizedBox(height: 32),

        // Example 5: Dark Theme Demonstration
        _buildExampleSection(
          context: context,
          title: 'Dark Theme Support',
          description: 'Legend text automatically adapts to dark themes',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomBar(
                      width: sliderValue.clamp(0.1, 1.0).toDouble(),
                      style: BarStyle.grouped,
                      alpha: 0.9,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 0,
                      labels: NumberFormat.simpleCurrency().format,
                    )
                    .theme(ChartTheme.darkTheme()) // Dark theme
                    .legend(position: LegendPosition.topRight)
                    .animate(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                    )
                    .build(),
          ),
        ),

        const SizedBox(height: 32),

        // Example 6: Line chart with legend
        _buildExampleSection(
          context: context,
          title: 'Line Chart with Legend',
          description: 'Legend automatically adapts to line chart geometry',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomLine(strokeWidth: 3.0)
                    .geomPoint(size: 6.0)
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 0,
                      labels: NumberFormat.simpleCurrency().format,
                    )
                    .theme(currentTheme)
                    .legend(position: LegendPosition.topLeft)
                    .animate(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                    )
                    .build(),
          ),
        ),

        const SizedBox(height: 32),

        // Example 7: Interactive Legend
        _buildExampleSection(
          context: context,
          title: 'Interactive Legend (Click to Toggle)',
          description:
              'Click legend items to show/hide categories • Auto-managed state',
          child: SizedBox(
            height: 300,
            child:
                CristalyseChart()
                    .data(data)
                    .mapping(x: 'quarter', y: 'revenue', color: 'product')
                    .geomBar(
                      width: sliderValue.clamp(0.1, 1.0).toDouble(),
                      style: BarStyle.grouped,
                      alpha: 0.9,
                    )
                    .scaleXOrdinal()
                    .scaleYContinuous(
                      min: 0,
                      labels: NumberFormat.simpleCurrency().format,
                    )
                    .theme(currentTheme)
                    .legend(
                      position: LegendPosition.topRight,
                      interactive: true, // <- Enable click-to-toggle
                      backgroundColor: currentTheme.backgroundColor.withValues(
                        alpha: 0.95,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      symbolSize: 12.0,
                      itemSpacing: 10.0,
                      borderRadius: 8.0,
                    )
                    .interaction(
                      tooltip: TooltipConfig(
                        builder:
                            (point) => Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  point.getDisplayValue('product'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${point.getDisplayValue('quarter')}: \$${point.getDisplayValue('revenue')}k',
                                ),
                              ],
                            ),
                      ),
                    )
                    .animate(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                    )
                    .build(),
          ),
        ),
      ],
    ),
  );
}

Widget _buildExampleSection({
  required BuildContext context,
  required String title,
  required String description,
  required Widget child,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
      ),
    ],
  );
}
