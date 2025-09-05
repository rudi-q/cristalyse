List<String> getChartFeatures(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return [
        'Grammar of graphics API with intuitive data mapping',
        'Smooth 60fps animations with elastic curves',
        'Size and color encoding for multi-dimensional data',
        'Responsive scaling and high-DPI support'
      ];
    case 1: // Interactive scatter plot
      return [
        'Rich tooltip system with customizable content and styling',
        'Hover detection with spatial indexing for smooth performance',
        'Click interactions for navigation and custom actions',
        'Mobile-optimized touch handling and gesture recognition'
      ];
    case 2: // Panning demo
      return [
        'Real-time pan detection with visible range callbacks',
        'Perfect for large datasets with efficient data loading',
        'Throttled updates to prevent overwhelming the database',
        'Coordinate transformation from screen pixels to data values'
      ];
    case 3: // Line chart
      return [
        'Progressive line drawing with smooth transitions',
        'Multi-series support with automatic color mapping',
        'Customizable stroke width and transparency',
        'Optimized for time-series and continuous data'
      ];
    case 4: // Area chart
      return [
        'Smooth area fills with customizable transparency',
        'Progressive animation revealing data over time',
        'Multi-series support with overlapping transparency',
        'Combined area + line + point visualizations'
      ];
    case 5: // Bubble chart
      return [
        'Three-dimensional data visualization with size encoding',
        'Bubble size represents additional data dimension',
        'Smooth bubble scaling animations with elastic curves',
        'Label support with automatic contrast adjustment'
      ];
    case 6: // Bar chart
      return [
        'Categorical data visualization with ordinal scales',
        'Staggered bar animations for visual impact',
        'Automatic baseline detection and scaling',
        'Customizable bar width and styling options'
      ];
    case 7: // Grouped bars
      return [
        'Side-by-side comparison of multiple data series',
        'Clean currency formatting for financial comparisons',
        'Coordinated group animations with smooth timing',
        'Automatic legend generation from color mappings',
        'Perfect for product or regional comparisons'
      ];
    case 8: // Horizontal bars
      return [
        'Coordinate system flipping for horizontal layouts',
        'Ideal for ranking and categorical comparisons',
        'Space-efficient labeling for long category names',
        'Consistent animation system across orientations'
      ];
    case 9: // Stacked bars
      return [
        'Segment-by-segment progressive stacking animation',
        'Automatic part-to-whole relationship visualization',
        'Consistent color mapping across all segments',
        'Perfect for budget breakdowns and composition analysis'
      ];
    case 10: // Pie charts
      return [
        'Smooth slice animations with staggered timing',
        'Donut chart support with configurable inner radius',
        'Smart label positioning with formatting',
        'Exploded slices for emphasis and visual impact'
      ];
    case 11: // Dual Y-axis
      return [
        'Dual Y-axis support for different data scales',
        'Independent left and right axis scaling',
        'Combined bar and line visualizations',
        'Perfect for correlating volume vs efficiency metrics'
      ];
    case 12: // Heatmap
      return [
        'Color-coded intensity visualization for multi-dimensional data',
        'Animated cell appearance with wave effect',
        'Customizable color gradients with interpolation support',
        'Value labels with automatic contrast for readability',
        'Null value support with customizable styling'
      ];
    case 13: // Contributions heatmap
      return [
        'GitHub-style contribution graph visualization',
        'Discrete color levels for activity intensity',
        'Weekly grid layout with day-based organization',
        'Animated cell scaling with elastic curves',
        'Perfect for activity tracking and habit visualization'
      ];
    case 14: // Multi-series line chart
      return [
        'Fixed multi-series line rendering with proper separation',
        'Each series gets its own line with distinct colors',
        'Points and lines work together seamlessly',
        'Fully backward compatible with single-series charts'
      ];
    case 15: // Export demo
      return [
        'Export charts as scalable SVG vector graphics',
        'Infinite zoom and professional quality output',
        'Small file sizes perfect for web and print',
        'Editable in design software and ideal for presentations'
      ];
    case 16: // Gradient bars
      return [
        'Beautiful gradient fills using Flutter\'s native shader system',
        'Linear gradients from bottom to top for depth effect',
        'Custom gradient colors per category with easy mapping',
        'Smooth animation compatibility with existing systems',
        'Rounded corners and borders work perfectly with gradients'
      ];
    case 17: // Advanced gradients
      return [
        'Multiple gradient types: Linear, Radial, Sweep gradients',
        'Mixed gradient effects within single charts',
        'Works seamlessly with both bar and point geometries',
        'Custom gradient directions and color stops',
        'Performance optimized with gradient caching and reuse'
      ];
    default:
      return [];
  }
}
