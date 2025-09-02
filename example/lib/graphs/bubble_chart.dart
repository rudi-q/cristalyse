import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildBubbleChartTab(
  ChartTheme theme,
  double sliderValue,
) {
  // Use proper bubble data generation without random values on each render
  final bubbleData = _generateBubbleData();

  // Calculate proper bubble sizes based on slider (RADIUS values, not diameter!)
  final minSize = 5.0 + sliderValue * 3.0; // 5-8 px radius (10-16 px diameter)
  final maxSize =
      15.0 + sliderValue * 10.0; // 15-25 px radius (30-50 px diameter)

  // Use theme's color palette for categories
  final categories = ['Enterprise', 'SMB', 'Startup'];
  final categoryColors = <String, Color>{};
  for (int i = 0; i < categories.length; i++) {
    categoryColors[categories[i]] =
        theme.colorPalette[i % theme.colorPalette.length];
  }

  // Use theme directly with its color palette
  final enhancedTheme = ChartTheme(
    backgroundColor: theme.backgroundColor,
    plotBackgroundColor: theme.plotBackgroundColor,
    primaryColor: theme.primaryColor,
    borderColor: theme.borderColor,
    gridColor: Colors.grey.withValues(alpha: 0.2),
    axisColor: theme.axisColor,
    gridWidth: theme.gridWidth,
    axisWidth: theme.axisWidth,
    pointSizeDefault: theme.pointSizeDefault,
    pointSizeMin: theme.pointSizeMin,
    pointSizeMax: theme.pointSizeMax,
    colorPalette: theme.colorPalette, // Use theme's actual color palette
    padding: theme.padding,
    axisTextStyle: theme.axisTextStyle,
    axisLabelStyle: const TextStyle(
      fontSize: 11,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    ),
  );

  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Analysis Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Company performance metrics: Revenue vs Customer base',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Legend
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: categoryColors.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[
                                800], // Explicit dark color for visibility
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: CristalyseChart()
                .data(bubbleData)
                .mapping(
                  x: 'revenue',
                  y: 'customers',
                  size: 'marketShare',
                  color: 'category',
                )
                .geomBubble(
                  minSize: minSize,
                  maxSize: maxSize,
                  alpha: 0.75, // Slightly transparent for overlapping bubbles
                  borderWidth: 2.0,
                  borderColor: Colors.white, // White border for better contrast
                  shape: PointShape.circle,
                  showLabels: false, // Clean look with tooltips
                )
                .scaleXContinuous(
                  labels: (value) => '\$${value.toStringAsFixed(0)}M',
                )
                .scaleYContinuous(
                  labels: (value) => '${value.toStringAsFixed(0)}K',
                )
                .theme(enhancedTheme)
                .animate(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                )
                .interaction(
              tooltip: TooltipConfig(
                builder: (point) {
                  final name = point.getDisplayValue('name');
                  final revenue = point.getDisplayValue('revenue');
                  final customers = point.getDisplayValue('customers');
                  final marketShare = point.getDisplayValue('marketShare');
                  final category = point.getDisplayValue('category');
                  final categoryColor = categoryColors[category] ?? Colors.grey;

                  return Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[900]!,
                          Colors.grey[850]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              _buildMetricRow(
                                Icons.attach_money,
                                'Revenue',
                                '\$${revenue}M',
                                Colors.green[400]!,
                              ),
                              const SizedBox(height: 8),
                              _buildMetricRow(
                                Icons.people,
                                'Customers',
                                '${customers}K',
                                Colors.blue[400]!,
                              ),
                              const SizedBox(height: 8),
                              _buildMetricRow(
                                Icons.pie_chart,
                                'Market Share',
                                '$marketShare%',
                                Colors.orange[400]!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ).build(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights,
                size: 20,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Chart',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Bubble size indicates market share percentage\n'
                      '• Hover over bubbles to see detailed metrics\n'
                      '• Color represents company category',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildMetricRow(
  IconData icon,
  String label,
  String value,
  Color color,
) {
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: color,
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

List<Map<String, dynamic>> _generateBubbleData() {
  // Fixed seed for consistent data generation
  final random = math.Random(42);

  final companies = [
    {'name': 'TechCorp Solutions', 'category': 'Enterprise', 'growth': 15},
    {'name': 'StartupX Labs', 'category': 'Startup', 'growth': 45},
    {'name': 'MidSize Systems', 'category': 'SMB', 'growth': 22},
    {'name': 'BigTech Industries', 'category': 'Enterprise', 'growth': 8},
    {'name': 'InnovateLab', 'category': 'Startup', 'growth': 65},
    {'name': 'GrowthCo Tech', 'category': 'SMB', 'growth': 30},
    {'name': 'MegaCorp Global', 'category': 'Enterprise', 'growth': 12},
    {'name': 'AgileTeam Pro', 'category': 'Startup', 'growth': 55},
    {'name': 'SteadyCorp Inc', 'category': 'SMB', 'growth': 18},
    {'name': 'ScaleTech Cloud', 'category': 'Enterprise', 'growth': 20},
    {'name': 'NextGen AI', 'category': 'Startup', 'growth': 80},
    {'name': 'DataFlow Systems', 'category': 'SMB', 'growth': 25},
  ];

  final result = companies.map((company) {
    final isEnterprise = company['category'] == 'Enterprise';
    final isSMB = company['category'] == 'SMB';
    final growth = (company['growth'] as int).toDouble();

    // More spread out distribution for better visualization
    final baseRevenue = isEnterprise ? 250.0 : (isSMB ? 150.0 : 50.0);
    final baseCustomers = isEnterprise ? 180.0 : (isSMB ? 120.0 : 60.0);
    final baseMarketShare = isEnterprise ? 18.0 : (isSMB ? 10.0 : 5.0);

    // Add more variance for better spread
    final variance = random.nextDouble() * 0.8 + 0.6; // 0.6 to 1.4 multiplier

    return {
      'name': company['name'],
      'category': company['category'],
      'revenue': (baseRevenue * variance).roundToDouble(),
      'customers': (baseCustomers * variance).roundToDouble(),
      'marketShare':
          (baseMarketShare * variance * (1 + growth / 100)).roundToDouble(),
      'growth': growth,
    };
  }).toList()
    ..sort((a, b) =>
        (b['marketShare'] as double).compareTo(a['marketShare'] as double));

  return result;
}
