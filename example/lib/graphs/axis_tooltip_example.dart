import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

/// Example demonstrating axis-based tooltips with crosshair indicator
/// 
/// This example shows:
/// - Axis-based tooltip triggering (hover anywhere on X position)
/// - Multi-series tooltip display
/// - Crosshair visual indicator
/// - Smooth tooltip rendering without flickering
class AxisTooltipExample extends StatelessWidget {
  const AxisTooltipExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Multi-series time-series data (quarterly sales by product)
    final salesData = [
      {'quarter': 'Q1', 'ios': 45.0, 'android': 62.0, 'web': 28.0},
      {'quarter': 'Q2', 'ios': 58.0, 'android': 75.0, 'web': 35.0},
      {'quarter': 'Q3', 'ios': 67.0, 'android': 82.0, 'web': 42.0},
      {'quarter': 'Q4', 'ios': 78.0, 'android': 90.0, 'web': 48.0},
    ];

    // Transform data for multi-series
    final chartData = <Map<String, dynamic>>[];
    for (final quarter in salesData) {
      chartData.add({
        'quarter': quarter['quarter'],
        'value': quarter['ios'],
        'platform': 'iOS',
      });
      chartData.add({
        'quarter': quarter['quarter'],
        'value': quarter['android'],
        'platform': 'Android',
      });
      chartData.add({
        'quarter': quarter['quarter'],
        'value': quarter['web'],
        'platform': 'Web',
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Axis-Based Tooltips'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales by Platform',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hover anywhere on the chart to see all platforms at that quarter',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildLineChart(chartData),
            ),
            const SizedBox(height: 32),
            const Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data) {
    return CristalyseChart()
        .data(data)
        .mapping(x: 'quarter', y: 'value', color: 'platform')
        .geomLine(strokeWidth: 3.0)
        .geomPoint(size: 8.0, shape: PointShape.circle)
        .scaleXOrdinal()
        .scaleYContinuous(min: 0, max: 100)
        .interaction(
          tooltip: TooltipConfig(
            // Enable axis-based triggering
            triggerMode: ChartTooltipTriggerMode.axis,
            
            // Show crosshair line
            showCrosshair: true,
            crosshairColor: Colors.grey.shade400,
            crosshairWidth: 1.5,
            crosshairStyle: StrokeStyle.dashed,
            
            // Use multi-point tooltip builder
            multiPointBuilder: DefaultTooltips.multiPoint(
              xColumn: 'quarter',
              yColumn: 'value',
            ),
            
            // Smooth tooltip behavior
            showDelay: Duration(milliseconds: 50),
            followPointer: true,
            
            // Styling
            backgroundColor: Colors.black87,
            borderRadius: 8.0,
            padding: EdgeInsets.all(12.0),
          ),
        )
        .customPalette(
          categoryColors: {
            'iOS': Color(0xFF007AFF),      // Apple blue
            'Android': Color(0xFF3DDC84),  // Android green
            'Web': Color(0xFFFF6B35),      // Orange
          },
        )
        .legend(
          position: LegendPosition.topRight,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
        )
        .theme(ChartTheme.defaultTheme().copyWith(
          plotBackgroundColor: Colors.grey.shade50,
          gridColor: Colors.grey.shade300,
        ))
        .build();
  }

  Widget _buildFeatureList() {
    final features = [
      '✓ Hover anywhere on X-axis to trigger tooltip',
      '✓ Shows all series values at once',
      '✓ Crosshair line follows cursor',
      '✓ Smooth rendering without flicker',
      '✓ Color-coded series indicators',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          feature,
          style: const TextStyle(fontSize: 14),
        ),
      )).toList(),
    );
  }
}