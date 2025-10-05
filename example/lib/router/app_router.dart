import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/chart_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/scatter-plot',
    routes: <RouteBase>[
      GoRoute(
        path: '/scatter-plot',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 0);
        },
      ),
      GoRoute(
        path: '/interactive',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 1);
        },
      ),
      GoRoute(
        path: '/panning',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 2);
        },
      ),
      GoRoute(
        path: '/line-chart',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 3);
        },
      ),
      GoRoute(
        path: '/area-chart',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 4);
        },
      ),
      GoRoute(
        path: '/bubble-chart',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 5);
        },
      ),
      GoRoute(
        path: '/bar-chart',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 6);
        },
      ),
      GoRoute(
        path: '/grouped-bars',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 7);
        },
      ),
      GoRoute(
        path: '/horizontal-bars',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 8);
        },
      ),
      GoRoute(
        path: '/stacked-bars',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 9);
        },
      ),
      GoRoute(
        path: '/pie-chart',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 10);
        },
      ),
      GoRoute(
        path: '/dual-y-axis',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 11);
        },
      ),
      GoRoute(
        path: '/heatmap',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 12);
        },
      ),
      GoRoute(
        path: '/contributions',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 13);
        },
      ),
      GoRoute(
        path: '/progress-bars',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 14);
        },
      ),
      GoRoute(
        path: '/multi-series',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 15);
        },
      ),
      GoRoute(
        path: '/export',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 16);
        },
      ),
      GoRoute(
        path: '/gradient-bars',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 17);
        },
      ),
      GoRoute(
        path: '/advanced-gradients',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 18);
        },
      ),
      GoRoute(
        path: '/legends',
        builder: (BuildContext context, GoRouterState state) {
          return const ChartScreen(chartIndex: 19);
        },
      ),
    ],
  );

  static GoRouter get router => _router;

  // Route information for navigation
  static const List<RouteInfo> routes = [
    RouteInfo(
      path: '/scatter-plot',
      title: 'Scatter Plot',
      icon: Icons.scatter_plot,
      description:
          'Interactive scatter plots with custom sizing and categorization',
      docsUrl: 'https://docs.cristalyse.com/charts/scatter-plots',
    ),
    RouteInfo(
      path: '/interactive',
      title: 'Interactive',
      icon: Icons.touch_app,
      description: 'Hover and tap for detailed insights with rich tooltips',
      docsUrl: 'https://docs.cristalyse.com/features/interactions',
    ),
    RouteInfo(
      path: '/panning',
      title: 'Panning',
      icon: Icons.pan_tool,
      description: 'Real-time pan detection with visible range callbacks',
      docsUrl: 'https://docs.cristalyse.com/features/interactions',
    ),
    RouteInfo(
      path: '/line-chart',
      title: 'Line Chart',
      icon: Icons.show_chart,
      description: 'Smooth line charts with customizable styles and animations',
      docsUrl: 'https://docs.cristalyse.com/charts/line-charts',
    ),
    RouteInfo(
      path: '/area-chart',
      title: 'Area Chart',
      icon: Icons.area_chart,
      description:
          'Smooth area fills with progressive animation and transparency',
      docsUrl: 'https://docs.cristalyse.com/charts/area-charts',
    ),
    RouteInfo(
      path: '/bubble-chart',
      title: 'Bubble Chart',
      icon: Icons.bubble_chart,
      description: 'Three-dimensional data visualization with size encoding',
      isNew: true,
      docsUrl: 'https://docs.cristalyse.com/charts/bubble-charts',
    ),
    RouteInfo(
      path: '/bar-chart',
      title: 'Bar Chart',
      icon: Icons.bar_chart,
      description: 'Classic bar charts with customizable colors and animations',
      docsUrl: 'https://docs.cristalyse.com/charts/bar-charts',
    ),
    RouteInfo(
      path: '/grouped-bars',
      title: 'Grouped Bars',
      icon: Icons.stacked_bar_chart,
      description: 'Multiple bar groups for comparative analysis',
      docsUrl: 'https://docs.cristalyse.com/charts/bar-charts',
    ),
    RouteInfo(
      path: '/horizontal-bars',
      title: 'Horizontal Bars',
      icon: Icons.horizontal_rule,
      description: 'Horizontal bar charts perfect for categorical data',
      docsUrl: 'https://docs.cristalyse.com/charts/bar-charts',
    ),
    RouteInfo(
      path: '/stacked-bars',
      title: 'Stacked Bars',
      icon: Icons.stacked_line_chart,
      description: 'Stacked bar charts showing part-to-whole relationships',
      docsUrl: 'https://docs.cristalyse.com/charts/bar-charts',
    ),
    RouteInfo(
      path: '/pie-chart',
      title: 'Pie Chart',
      icon: Icons.pie_chart,
      description: 'Interactive pie charts with customizable segments',
      docsUrl: 'https://docs.cristalyse.com/charts/pie-charts',
    ),
    RouteInfo(
      path: '/dual-y-axis',
      title: 'Dual Y-Axis',
      icon: Icons.analytics,
      description: 'Dual-axis charts for comparing different metrics',
      docsUrl: 'https://docs.cristalyse.com/charts/dual-axis',
    ),
    RouteInfo(
      path: '/heatmap',
      title: 'Heatmap',
      icon: Icons.grid_on,
      description: 'Color-coded heatmaps for pattern visualization',
      docsUrl: 'https://docs.cristalyse.com/charts/heat-map-charts',
    ),
    RouteInfo(
      path: '/contributions',
      title: 'Contributions',
      icon: Icons.calendar_view_day,
      description: 'GitHub-style contribution graphs for activity tracking',
      docsUrl: 'https://docs.cristalyse.com/charts/heat-map-charts',
    ),
    RouteInfo(
      path: '/progress-bars',
      title: 'Progress Bars',
      icon: Icons.linear_scale,
      description:
          'Multiple progress bar styles including gauge and concentric',
      isNew: true,
      docsUrl: 'https://docs.cristalyse.com/charts/progress-bars',
    ),
    RouteInfo(
      path: '/multi-series',
      title: 'Multi-Series',
      icon: Icons.timeline,
      description: 'Multi-series line charts with custom category colors',
      isNew: true,
      docsUrl: 'https://docs.cristalyse.com/charts/line-charts',
    ),
    RouteInfo(
      path: '/export',
      title: 'Export',
      icon: Icons.file_download,
      description: 'Export charts as scalable SVG vector graphics',
      docsUrl: 'https://docs.cristalyse.com/features/export',
    ),
    RouteInfo(
      path: '/gradient-bars',
      title: 'Gradient Bars',
      icon: Icons.gradient,
      description: 'Beautiful gradient fills for enhanced visual appeal',
      isExperimental: true,
      docsUrl: 'https://docs.cristalyse.com/charts/bar-charts',
    ),
    RouteInfo(
      path: '/advanced-gradients',
      title: 'Advanced Gradients',
      icon: Icons.auto_awesome,
      description: 'Multiple gradient types: Linear, Radial, Sweep',
      isExperimental: true,
      docsUrl: 'https://docs.cristalyse.com/charts/bar-charts',
    ),
    RouteInfo(
      path: '/legends',
      title: 'Legends',
      icon: Icons.legend_toggle,
      description: 'Built-in legends with 9 positions including floating',
      isNew: true,
      docsUrl: 'https://docs.cristalyse.com/features/legends',
    ),
  ];
}

class RouteInfo {
  const RouteInfo({
    required this.path,
    required this.title,
    required this.icon,
    required this.description,
    this.isNew = false,
    this.isExperimental = false,
    this.docsUrl,
  });

  final String path;
  final String title;
  final IconData icon;
  final String description;
  final bool isNew;
  final bool isExperimental;
  final String? docsUrl;
}
