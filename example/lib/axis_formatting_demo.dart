import 'package:flutter/material.dart';
import 'package:cristalyse/cristalyse.dart';

class AxisFormattingDemo extends StatelessWidget {
  const AxisFormattingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstrating formatting
    final revenueData = [
      {'month': 'Jan', 'revenue': 1500.50, 'conversion': 12.5},
      {'month': 'Feb', 'revenue': 2800.75, 'conversion': 15.2},
      {'month': 'Mar', 'revenue': 3200.25, 'conversion': 18.7},
      {'month': 'Apr', 'revenue': 2900.00, 'conversion': 16.3},
      {'month': 'May', 'revenue': 4100.80, 'conversion': 22.1},
      {'month': 'Jun', 'revenue': 3800.45, 'conversion': 19.8},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Axis Formatting Demo'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency formatting example
            const Text(
              'Revenue Chart with Currency Formatting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: CristalyseChart()
                  .data(revenueData)
                  .mapping(x: 'month', y: 'revenue')
                  .scaleXOrdinal()
                  .scaleYContinuous()
                  .geomBar()
                  .formatXAxis() // No formatting for X-axis (month names)
                  .formatYAxis(prefix: '\$', decimals: 0) // Currency formatting
                  .theme(ChartTheme.defaultTheme())
                  .build(),
            ),
            
            const SizedBox(height: 30),
            
            // Percentage formatting example  
            const Text(
              'Conversion Rate with Percentage Formatting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: CristalyseChart()
                  .data(revenueData)
                  .mapping(x: 'month', y: 'conversion')
                  .scaleXOrdinal()
                  .scaleYContinuous()
                  .geomLine(strokeWidth: 3.0)
                  .geomPoint(size: 6.0)
                  .formatXAxis() // No formatting for X-axis
                  .formatYAxis(suffix: '%', decimals: 1) // Percentage formatting
                  .theme(ChartTheme.defaultTheme())
                  .build(),
            ),
            
            const SizedBox(height: 30),
            
            // Dual-axis chart with different formatting
            const Text(
              'Dual-Axis Chart with Different Formatting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: CristalyseChart()
                  .data(revenueData)
                  .mapping(x: 'month', y: 'revenue')
                  .mappingY2('conversion')
                  .scaleXOrdinal()
                  .scaleYContinuous()
                  .scaleY2Continuous(min: 0, max: 25)
                  .geomBar() // Revenue bars (primary Y-axis)
                  .geomLine(strokeWidth: 3.0, color: Colors.red, yAxis: YAxis.secondary) // Conversion line (secondary Y-axis)
                  .formatXAxis() // No formatting for X-axis
                  .formatYAxis(prefix: '\$', decimals: 0) // Currency for primary Y-axis
                  .formatY2Axis(suffix: '%', decimals: 1) // Percentage for secondary Y-axis
                  .theme(ChartTheme.defaultTheme())
                  .build(),
            ),
            
            const SizedBox(height: 30),
            
            // Custom formatting example
            const Text(
              'Custom Formatting with Japanese Yen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: CristalyseChart()
                  .data(revenueData.map((d) => {
                    'month': d['month'],
                    'revenue_jpy': (d['revenue']! as double) * 150, // Convert to JPY
                  }).toList())
                  .mapping(x: 'month', y: 'revenue_jpy')
                  .scaleXOrdinal()
                  .scaleYContinuous()
                  .geomBar()
                  .formatXAxis() // No formatting for X-axis
                  .formatYAxis(prefix: 'JPY ', decimals: 0) // Japanese Yen (no decimals)
                  .theme(ChartTheme.defaultTheme())
                  .build(),
            ),
            
            const SizedBox(height: 20),
            
            // Information card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Axis Formatting Features:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Prefix support (e.g., \$, JPY, EUR)'),
                    const Text('• Suffix support (e.g., %, units, per item)'),
                    const Text('• Custom decimal places'),
                    const Text('• Predefined formatters (currency, percentage)'),
                    const Text('• Independent formatting for X, Y, and Y2 axes'),
                    const Text('• Works with all chart types'),
                    const SizedBox(height: 12),
                    const Text(
                      'Usage Examples:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'chart.formatYAxis(prefix: "\$", decimals: 2)',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          Text(
                            'chart.formatYAxis(suffix: "%", decimals: 1)',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                          Text(
                            'chart.formatYAxis(formatter: AxisFormatter.currency)',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}