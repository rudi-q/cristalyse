import 'package:cristalyse/cristalyse.dart';
import 'package:cristalyse_example/chart_theme.dart';
import 'package:flutter/material.dart';

Widget buildInteractiveScatterTab(
    ChartTheme currentTheme,
    List<Map<String, dynamic>> data,
    double sliderValue,
    ) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interactive Scatter Plot',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hover over points to see tooltips • Tap points for details',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: CristalyseChart()
              .data(data)
              .mapping(x: 'x', y: 'y', color: 'category', size: 'size')
              .geomPoint(
            alpha: 0.8,
            size: 4.0 + sliderValue * 8.0,
          )
              .scaleXContinuous(min: 0, max: 50)
              .scaleYContinuous()
              .theme(currentTheme.copyWith(
            pointSizeMax: 2.0 + sliderValue * 20.0,
          ))
              .interaction(
            tooltip: TooltipConfig(
              builder: (point) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 2), // Prominent border
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Data',
                        style: TextStyle(
                          color: currentTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Week: ${point.getDisplayValue('x')}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Revenue: \$${point.getDisplayValue('y')}k',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Segment: ${point.getDisplayValue('category')}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Deal Size: ${point.getDisplayValue('size')}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
              showDelay: const Duration(milliseconds: 50), // Faster for debugging
              hideDelay: const Duration(milliseconds: 200),
            ),
            click: ClickConfig(
              onTap: (point) {
                // In a real app, you'd navigate to details or show a dialog
              },
            ),
          )
              .animate(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
          )
              .build(),
        ),
        const SizedBox(height: 16),
        const _InteractionGuide(),
      ],
    ),
  );
}

class _InteractionGuide extends StatelessWidget {
  const _InteractionGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Interactive Features',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.visibility,
            'Hover Detection',
            'Move your cursor over data points to see rich tooltips with multiple data dimensions',
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.tap_and_play,
            'Touch Interactions',
            'Tap on data points to trigger custom actions like navigation or detail views',
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.speed,
            'High Performance',
            'Spatial indexing ensures smooth interactions even with thousands of data points',
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.palette,
            'Customizable',
            'Full control over tooltip appearance, timing, and interaction behavior',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Example of different tooltip configurations you can use
class TooltipExamples {
  /// Simple single-value tooltip
  static Widget simple() {
    return CristalyseChart()
        .tooltip(DefaultTooltips.simple('revenue'))
        .build();
  }

  /// Multi-column tooltip
  static Widget multi() {
    return CristalyseChart()
        .tooltip(DefaultTooltips.multi({
      'revenue': 'Revenue',
      'deals': 'Deal Count',
      'conversion': 'Conversion Rate',
    }))
        .build();
  }

  /// Custom tooltip with business logic
  static Widget custom() {
    return CristalyseChart()
        .tooltip((point) {
      final revenue = point.getDisplayValue('revenue');
      const target = 100; // Business target
      final performance = double.tryParse(revenue) ?? 0;
      final status = performance >= target ? '✅ On Track' : '⚠️ Below Target';

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week ${point.getDisplayValue('week')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Revenue: \$${revenue}k',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            status,
            style: TextStyle(
              color: performance >= target ? Colors.green : Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      );
    })
        .build();
  }

  /// With click actions
  static Widget withActions(BuildContext context) {
    return CristalyseChart()
        .tooltip(DefaultTooltips.simple('revenue'))
        .onClick((point) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Point Details'),
          content: Text('Selected: ${point.data}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    })
        .build();
  }
}