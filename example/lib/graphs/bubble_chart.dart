import 'dart:math' as math;

import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

Widget buildBubbleChartTab(
  ChartTheme theme,
  List<Map<String, dynamic>> data,
  double sliderValue,
) {
  // Generate bubble chart data if not provided or transform existing data
  final bubbleData = data.isNotEmpty
      ? data.map((item) {
          // Transform existing data to include bubble size
          return {
            ...item,
            'revenue': item['y'] ?? item['revenue'] ?? 0,
            'customers': (item['size'] ?? 1.0) * 50 + math.Random().nextDouble() * 50,
            'marketShare': (item['y'] ?? 20) / 4 + math.Random().nextDouble() * 15,
          };
        }).toList()
      : _generateBubbleData();

  final minSize = 8.0 + sliderValue * 15.0; // 8-23
  final maxSize = 25.0 + sliderValue * 25.0; // 25-50

  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Company performance by revenue, customer count, and market share',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
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
                alpha: 0.7,
                borderWidth: 2.0,
                borderColor: Colors.white,
                shape: PointShape.circle,
                showLabels: true,
                labelFormatter: (value) => '${value.toStringAsFixed(1)}%',
                labelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                labelOffset: 8.0,
              )
              .scaleXContinuous(min: 0)
              .scaleYContinuous(min: 0)
              .theme(theme)
              .animate(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
              )
              .interaction(
                tooltip: TooltipConfig(
                  builder: (point) {
                    final revenue = point.getDisplayValue('revenue');
                    final customers = point.getDisplayValue('customers');
                    final marketShare = point.getDisplayValue('marketShare');
                    final category = point.getDisplayValue('category');
                    
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Revenue: \$$revenue M',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Customers: ${customers}K',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Market Share: $marketShare%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
              .build(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bubble size represents market share. X-axis: Revenue, Y-axis: Customer count.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

List<Map<String, dynamic>> _generateBubbleData() {
  final companies = [
    {'name': 'TechCorp', 'category': 'Enterprise'},
    {'name': 'StartupX', 'category': 'Startup'},
    {'name': 'MidSize Co', 'category': 'SMB'},
    {'name': 'BigTech Inc', 'category': 'Enterprise'},
    {'name': 'InnovateLab', 'category': 'Startup'},
    {'name': 'GrowthCo', 'category': 'SMB'},
    {'name': 'MegaCorp', 'category': 'Enterprise'},
    {'name': 'AgileTeam', 'category': 'Startup'},
    {'name': 'SteadyCorp', 'category': 'SMB'},
    {'name': 'ScaleTech', 'category': 'Enterprise'},
  ];

  return companies.map((company) {
    final isEnterprise = company['category'] == 'Enterprise';
    final isSMB = company['category'] == 'SMB';
    
    // Enterprise companies tend to have higher revenue and customers
    final baseRevenue = isEnterprise ? 200.0 : (isSMB ? 80.0 : 30.0);
    final baseCustomers = isEnterprise ? 150.0 : (isSMB ? 75.0 : 25.0);
    final baseMarketShare = isEnterprise ? 15.0 : (isSMB ? 8.0 : 4.0);
    
    return {
      'name': company['name'],
      'category': company['category'],
      'revenue': baseRevenue + math.Random().nextDouble() * 100,
      'customers': baseCustomers + math.Random().nextDouble() * 100,
      'marketShare': baseMarketShare + math.Random().nextDouble() * 10,
    };
  }).toList();
}
