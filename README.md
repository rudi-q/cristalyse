<p>
  <a href="https://docs.cristalyse.com">
    <img src="doc/logo/logo.svg" alt="Cristalyse" width="400"/>
  </a>
</p>

**The grammar of graphics visualization library that Flutter developers have been waiting for.**

[![pub package](https://img.shields.io/pub/v/cristalyse.svg?color=2cacbf&labelColor=145261)](https://pub.dev/packages/cristalyse)
[![pub points](https://img.shields.io/pub/points/cristalyse?color=2cacbf&labelColor=145261)](https://pub.dev/packages/cristalyse/score)
[![likes](https://img.shields.io/pub/likes/cristalyse?color=2cacbf&labelColor=145261)](https://pub.dev/packages/cristalyse/score)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20windows%20%7C%20macos%20%7C%20linux-2cacbf?labelColor=145261)](https://flutter.dev/)
[![Flutter support](https://img.shields.io/badge/Flutter-1.17%2B-2cacbf?labelColor=145261)](https://flutter.dev/)
[![Dart support](https://img.shields.io/badge/Dart-2.19.2%2B-2cacbf?labelColor=145261)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-2cacbf.svg?labelColor=145261)](https://opensource.org/licenses/MIT)

> Finally, create beautiful data visualizations in Flutter without fighting against chart widgets or settling for web-based solutions.

---

<table>
<tr>
<td width="45%">

<p align="center" style="padding-left: 5em;">
  <a href="https://docs.cristalyse.com">
    <img src="doc/logo/dark.svg" alt="Cristalyse Documentation" width="400"/>
  </a>
</p>

<p>
  <strong>Visit our complete documentation for step-by-step guides, interactive examples,<br/>and everything you need to master data visualization in Flutter.</strong>
</p>

<p align="center">
  <a href="https://docs.cristalyse.com">
    <img src="https://img.shields.io/badge/📖_Read_Docs-2D3748?style=for-the-badge&logoColor=white&labelColor=2D3748" alt="Read Documentation"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://docs.cristalyse.com/quickstart">
    <img src="https://img.shields.io/badge/⚡_Quick_Start-4A5568?style=for-the-badge&logoColor=white&labelColor=4A5568" alt="Quick Start Guide"/>
  </a>
</p>

<p align="center">
  <a href="https://docs.cristalyse.com/examples">
    <img src="https://img.shields.io/badge/🎨_Examples-718096?style=for-the-badge&logoColor=white&labelColor=718096" alt="View Examples"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/rudrankriyam/cristalyse">
    <img src="https://img.shields.io/badge/📦_View_Source-8B9DC3?style=for-the-badge&logoColor=white&labelColor=8B9DC3" alt="View Source Code"/>
  </a>
</p>

<p align="center">
  <a href="https://cristalyse.com">
    <img src="https://img.shields.io/badge/🌐_Visit_Website-A0AEC0?style=for-the-badge&logoColor=white&labelColor=A0AEC0" alt="Visit Website"/>
  </a>
</p>

</td>
<td width="55%">

<p align="center">
  <a href="https://docs.cristalyse.com">
    <img src="doc/images/documentation.png" alt="Cristalyse Documentation Screenshot" width="70%"/>
  </a>
  <br/>
  <em>Comprehensive guides, examples, and API reference</em>
</p>

</td>
</tr>
</table>

---

## ✨ Why Cristalyse?

**Stop wrestling with limited chart libraries.** Cristalyse brings the power of grammar of graphics (think ggplot2) to Flutter with buttery-smooth 60fps animations and true cross-platform deployment.

- 🎨 **Grammar of Graphics API** - Familiar syntax if you've used ggplot2 or plotly
- 🚀 **Native 60fps Animations** - Leverages Flutter's rendering engine, not DOM manipulation
- 📱 **True Cross-Platform** - One codebase → Mobile, Web, Desktop, all looking identical
- ⚡ **GPU-Accelerated Performance** - Handle large datasets without breaking a sweat
- 🎯 **Flutter-First Design** - Seamlessly integrates with your existing Flutter apps
- 📊 **Dual Y-Axis Support** - Professional business dashboards with independent left/right scales
- 📈 **Advanced Bar Charts** - Grouped, stacked, and horizontal variations with smooth animations
- 👆 **Interactive Charts** - Engage users with tooltips, hover effects, and click events.

### See What You Can Build

<p align="center">
  <img src="example/screenshots/cristalyse_scatter_plot.gif" alt="Animated Scatter Plot" width="600"/>
  <br/>
  <em>Interactive scatter plots with smooth animations and multi-dimensional data mapping</em>
</p>

<p align="center">
  <img src="example/screenshots/cristalyse_line_chart.gif" alt="Progressive Line Chart" width="600"/>
  <br/>
  <em>Progressive line drawing with customizable themes and multi-series support</em>
</p>

<table>
<tr>
<td width="50%">

## 🎯 Perfect For

- **Flutter developers** building data-driven apps who need more than basic chart widgets
- **Data scientists** who want to deploy interactive visualizations to mobile without learning Swift/Kotlin
- **Enterprise teams** building dashboards that need consistent UX across all platforms
- **Business analysts** creating professional reports with dual Y-axis charts and advanced visualizations

</td>
<td width="50%">

<p align="center">
  <img src="doc/images/hero-dark.png" alt="Cristalyse Chart Showcase" width="400"/>
  <br/>
  <em>Build stunning, interactive charts with the power of grammar of graphics</em>
</p>

</td>
</tr>
</table>

## 🚀 Quick Start

### Installation

```bash
flutter pub add cristalyse
```

That's it! No complex setup, no additional configuration.

### Your First Chart (30 seconds)

```dart
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/material.dart';

class MyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [
      {'x': 1, 'y': 2, 'category': 'A'},
      {'x': 2, 'y': 3, 'category': 'B'},
      {'x': 3, 'y': 1, 'category': 'A'},
      {'x': 4, 'y': 4, 'category': 'C'},
    ];

    return CristalyseChart()
      .data(data)
      .mapping(x: 'x', y: 'y', color: 'category')
      .geomPoint(
        size: 8.0, // Made points a bit larger to see border clearly
        alpha: 0.8,
        shape: PointShape.triangle, // Example: use triangles
        borderWidth: 1.5,           // Example: add a border to points
      )
      .scaleXContinuous()
      .scaleYContinuous()
      .theme(ChartTheme.defaultTheme())
      .build();
  }
}
```

**Result:** A beautiful, animated scatter plot that works identically on iOS, Android, Web, and Desktop.

<p align="center">
  <img src="example/screenshots/cristalyse_scatter_plot.png" alt="Simple Scatter Plot" width="600"/>
  <br/>
  <em>Your first chart - clean, responsive, and cross-platform</em>
</p>

## 💡 Interactive Charts

### New: Enhanced Panning Behavior

Add real-time panning capabilities to your charts with seamless range updates and smooth interaction.

```dart
CristalyseChart()
  .data(myData)
  .mapping(x: 'x', y: 'y')
  .geomLine()
  .interaction(
    pan: PanConfig(
      enabled: true,
      onPanUpdate: (info) {
        // Handle real-time updates based on visible X range
        print('Visible X range: \\${info.visibleMinX} - \\${info.visibleMaxX}');
      },
    ),
  )
  .build();
```
**Features:**
- Maintains pan state across interactions
- Synchronizes displayed range between header and chart axis
- Enhanced UI for range display card

Bring your data to life with a fully interactive layer. Add rich tooltips, hover effects, and click/tap events to give users a more engaging experience.

```dart
// Add tooltips and click handlers
CristalyseChart()
  .data(salesData)
  .mapping(x: 'week', y: 'revenue', color: 'rep')
  .geomPoint(size: 8.0)
  .interaction(
    tooltip: TooltipConfig(
      builder: (point) {
        // Build a custom widget for the tooltip
        final category = point.getDisplayValue('rep');
        final value = point.getDisplayValue('revenue');
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$category: \$$value k',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      },
    ),
    click: ClickConfig(
      onTap: (point) {
        // Handle tap event, e.g., show a dialog
        print('Tapped on: ${point.data}');
      },
    ),
  )
  .build();
```

## 🎬 See It In Action

### Animated Scatter Plot
```dart
CristalyseChart()
  .data(salesData)
  .mapping(x: 'date', y: 'revenue', color: 'region', size: 'deals')
  .geomPoint(alpha: 0.7)
  .animate(duration: Duration(milliseconds: 800), curve: Curves.elasticOut)
  .theme(ChartTheme.defaultTheme())
  .build()
```

### Multi-Series Line Chart
```dart
CristalyseChart()
  .data(timeSeriesData)
  .mapping(x: 'month', y: 'users', color: 'platform')
  .geomLine(strokeWidth: 3.0)
  .geomPoint(size: 4.0)
  .animate(duration: Duration(milliseconds: 1200))
  .theme(ChartTheme.darkTheme())
  .build()
```

### Combined Visualizations
```dart
CristalyseChart()
  .data(analyticsData)
  .mapping(x: 'week', y: 'engagement')
  .geomLine(strokeWidth: 2.0, alpha: 0.8)      // Trend line
  .geomPoint(size: 5.0, alpha: 0.9)            // Data points
  .animate(duration: Duration(milliseconds: 1000), curve: Curves.easeInOutCubic)
  .build()
```

## 📊 Advanced Bar Charts

<div align="center">
  <img src="example/screenshots/cristalyse_bar_chart.gif" alt="Animated Bar Chart" width="400"/>
  <img src="example/screenshots/cristalyse_horizontal_bar_chart.gif" alt="Horizontal Bar Chart" width="400"/>
  <br/>
  <em>Vertical and horizontal bar charts with staggered animations</em>
</div>

### Stacked Bar Charts
```dart
// Perfect for budget breakdowns and composition analysis
CristalyseChart()
  .data(revenueData)
  .mapping(x: 'quarter', y: 'revenue', color: 'category')
  .geomBar(
    style: BarStyle.stacked,     // Stack segments on top of each other
    width: 0.8,
    alpha: 0.9,
  )
  .scaleXOrdinal()
  .scaleYContinuous(min: 0)
  .theme(ChartTheme.defaultTheme())
  .animate(duration: Duration(milliseconds: 1400))
  .build()
```

<p align="center">
  <img src="example/screenshots/cristalyse_stacked_bar_chart.gif" alt="Stacked Bar Chart" width="600"/>
  <br/>
  <em>Stacked bars with segment-by-segment progressive animation</em>
</p>

### Grouped Bar Charts
```dart
// Compare multiple series side-by-side
CristalyseChart()
  .data(productData)
  .mapping(x: 'quarter', y: 'revenue', color: 'product')
  .geomBar(
    style: BarStyle.grouped,     // Place bars side-by-side
    width: 0.8,
    alpha: 0.9,
  )
  .scaleXOrdinal()
  .scaleYContinuous(min: 0)
  .theme(ChartTheme.defaultTheme())
  .build()
```

<p align="center">
  <img src="example/screenshots/cristalyse_grouped_bar_chart.gif" alt="Grouped Bar Chart" width="600"/>
  <br/>
  <em>Grouped bar charts for comparing multiple series side-by-side</em>
</p>

### Horizontal Bar Charts
```dart
// Great for ranking and long category names
CristalyseChart()
  .data(departmentData)
  .mapping(x: 'department', y: 'headcount')
  .geomBar(
    borderRadius: BorderRadius.circular(4), // Rounded corners
    borderWidth: 1.0,                       // Add borders
  )
  .coordFlip()                              // Flip to horizontal
  .scaleXOrdinal()
  .scaleYContinuous(min: 0)
  .theme(ChartTheme.defaultTheme())
  .build()
```

## 🥧 Pie Charts and Donut Charts

**Perfect for part-to-whole relationships** - visualize market share, revenue distribution, user demographics, and any categorical data where proportions matter.

### Basic Pie Chart
```dart
// Revenue Distribution by Platform
CristalyseChart()
  .data([
    {'category': 'Mobile', 'revenue': 45.2},
    {'category': 'Desktop', 'revenue': 32.8},
    {'category': 'Tablet', 'revenue': 22.0},
  ])
  .mappingPie(value: 'revenue', category: 'category')
  .geomPie(
    outerRadius: 120.0,
    strokeWidth: 2.0,
    strokeColor: Colors.white,
    showLabels: true,
    showPercentages: true,
  )
  .theme(ChartTheme.defaultTheme())
  .animate(
    duration: Duration(milliseconds: 1200),
    curve: Curves.elasticOut,
  )
  .build()
```

### Donut Charts
```dart
// User Analytics with Donut Visualization
CristalyseChart()
  .data(userPlatformData)
  .mappingPie(value: 'users', category: 'platform')
  .geomPie(
    innerRadius: 60.0,        // Creates donut hole
    outerRadius: 120.0,
    strokeWidth: 3.0,
    strokeColor: Colors.white,
    showLabels: true,
    showPercentages: false,   // Show actual values
  )
  .theme(ChartTheme.darkTheme())
  .animate(
    duration: Duration(milliseconds: 1500),
    curve: Curves.easeOutBack,
  )
  .build()
```

### Advanced Pie Charts with Custom Styling
```dart
// Market Share Analysis with Exploded Slices
CristalyseChart()
  .data(marketShareData)
  .mappingPie(value: 'market_share', category: 'product')
  .geomPie(
    outerRadius: 150.0,
    strokeWidth: 2.0,
    strokeColor: Colors.white,
    showLabels: true,
    showPercentages: true,
    explodeSlices: true,      // Explode slices for emphasis
    explodeDistance: 15.0,
    labelRadius: 180.0,       // Position labels further out
    labelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  )
  .theme(ChartTheme.solarizedLightTheme())
  .build()
```

## 🎯 Dual Y-Axis Charts

**Perfect for business dashboards** - correlate volume metrics with efficiency metrics on independent scales.

```dart
// Revenue vs Conversion Rate - The Classic Business Dashboard
CristalyseChart()
  .data(businessData)
  .mapping(x: 'month', y: 'revenue')        // Primary Y-axis (left)
  .mappingY2('conversion_rate')             // Secondary Y-axis (right)
  .geomBar(
    yAxis: YAxis.primary,                   // Revenue bars use left axis
    alpha: 0.7,
  )
  .geomLine(
    yAxis: YAxis.secondary,                 // Conversion line uses right axis
    strokeWidth: 3.0,
    color: Colors.orange,
  )
  .geomPoint(
    yAxis: YAxis.secondary,                 // Points on conversion line
    size: 8.0,
    color: Colors.orange,
  )
  .scaleXOrdinal()
  .scaleYContinuous(min: 0)                 // Left axis: Revenue ($k)
  .scaleY2Continuous(min: 0, max: 100)      // Right axis: Percentage (%)
  .theme(ChartTheme.defaultTheme())
  .build()
```

<p align="center">
  <img src="example/screenshots/cristalyse_dual_axis_chart.gif" alt="Dual Axis Chart" width="600"/>
  <br/>
  <em>Dual axis charts for correlating two different metrics on independent scales</em>
</p>

### More Dual Y-Axis Examples

```dart
// Sales Volume vs Customer Satisfaction
CristalyseChart()
  .data(salesData)
  .mapping(x: 'week', y: 'sales_volume')
  .mappingY2('satisfaction_score')
  .geomBar(yAxis: YAxis.primary)            // Volume bars
  .geomLine(yAxis: YAxis.secondary)         // Satisfaction trend
  .scaleY2Continuous(min: 1, max: 5)        // Rating scale
  .build();

// Website Traffic vs Bounce Rate
CristalyseChart()
  .data(analyticsData)
  .mapping(x: 'date', y: 'page_views')
  .mappingY2('bounce_rate')
  .geomArea(yAxis: YAxis.primary, alpha: 0.3)    // Traffic area
  .geomLine(yAxis: YAxis.secondary, strokeWidth: 2.0) // Bounce rate line
  .scaleY2Continuous(min: 0, max: 100)      // Percentage scale
  .build();
```

## 🔥 Current Features

### ✅ Chart Types
- **Scatter plots** with size and color mapping
- **Line charts** with multi-series support and progressive drawing
- **Area charts** with smooth fills and multi-series transparency
- **Bar charts** (vertical, horizontal, grouped, stacked) with smooth animations
- **Pie charts and donut charts** with exploded slices and smart label positioning
- **Dual Y-axis charts** for professional business dashboards
- **Combined visualizations** (bars + lines, points + lines, etc.)

### ✅ Advanced Features
- **Grammar of Graphics API** - Familiar ggplot2-style syntax
- **Smooth 60fps animations** with customizable timing and curves
- **Dual Y-axis support** with independent scales and data routing
- **Coordinate flipping** for horizontal charts
- **Multiple themes** (Light, Dark, Solarized Light/Dark)
- **Custom color palettes** and styling options
- **Responsive scaling** for all screen sizes
- **High-DPI support** for crisp visuals

### ✅ Data Handling
- **Flexible data formats** - List<Map<String, dynamic>>
- **Mixed data types** - Automatic type detection and conversion
- **Missing value handling** - Graceful degradation for null/invalid data
- **Large dataset support** - Optimized for 1000+ data points
- **Real-time updates** - Smooth transitions when data changes

## 📸 Chart Export

**Export your charts as professional-quality SVG vector graphics** for reports, presentations, and documentation.

```dart
// Simple SVG export
final result = await chart.exportAsSvg(
  width: 1200,
  height: 800,
  filename: 'sales_report',
);
print('Chart saved to: ${result.filePath}');

// Advanced configuration
final config = ExportConfig(
  width: 1920,
  height: 1080,
  format: ExportFormat.svg,
  filename: 'high_res_dashboard',
);
final result = await chart.export(config);
```

**SVG Export Features:**
- ✅ **Scalable Vector Graphics** - Infinite zoom without quality loss
- ✅ **Professional Quality** - Perfect for presentations and reports
- ✅ **Small File Sizes** - Efficient for web and print
- ✅ **Design Software Compatible** - Editable in Figma, Adobe Illustrator, etc.
- ✅ **Cross-Platform Reliable** - Works consistently on all platforms
- ✅ **Automatic File Management** - Saves to Documents directory with timestamp

### 🚧 Coming Soon (Next Releases)
- Statistical overlays (regression lines, confidence intervals)
- Interactive zoom capabilities with scale persistence
- Faceting for small multiples and grid layouts
- Enhanced SVG export with full chart rendering

## 🎯 Real-World Examples

### Sales Dashboard
```dart
Widget buildRevenueTrend() {
  return CristalyseChart()
      .data(monthlyRevenue)
      .mapping(x: 'month', y: 'revenue', color: 'product_line')
      .geomLine(strokeWidth: 3.0)
      .geomPoint(size: 5.0)
      .scaleXContinuous()
      .scaleYContinuous(min: 0)
      .theme(ChartTheme.solarizedDarkTheme()) // Use Solarized Dark theme
      .animate(duration: Duration(milliseconds: 1500))
      .build();
}
```

### User Analytics
```dart
Widget buildEngagementScatter() {
  return CristalyseChart()
      .data(userMetrics)
      .mapping(x: 'session_length', y: 'pages_viewed',
      color: 'user_type', size: 'revenue')
      .geomPoint(alpha: 0.6)
      .scaleXContinuous()
      .scaleYContinuous()
      .theme(isDarkMode ? ChartTheme.darkTheme() : ChartTheme.defaultTheme())
      .animate(duration: Duration(milliseconds: 800), curve: Curves.elasticOut)
      .build();
}
```

### Market Share Analysis
```dart
Widget buildMarketSharePie() {
  return CristalyseChart()
      .data(marketData)
      .mappingPie(value: 'market_share', category: 'product')
      .geomPie(
        outerRadius: 140.0,
        strokeWidth: 3.0,
        strokeColor: Colors.white,
        showLabels: true,
        showPercentages: true,
        explodeSlices: true,                  // Emphasize key segments
        explodeDistance: 12.0,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      )
      .theme(ChartTheme.defaultTheme())
      .animate(duration: Duration(milliseconds: 1200), curve: Curves.elasticOut)
      .build();
}
```

### Business Intelligence Dashboard
```dart
Widget buildKPIDashboard() {
  return CristalyseChart()
      .data(kpiData)
      .mapping(x: 'quarter', y: 'revenue')
      .mappingY2('profit_margin')             // Dual Y-axis for percentage
      .geomBar(
        yAxis: YAxis.primary,
        style: BarStyle.stacked,              // Stack revenue components
        color: 'revenue_source',
      )
      .geomLine(
        yAxis: YAxis.secondary,               // Profit margin trend
        strokeWidth: 4.0,
        color: Colors.green,
      )
      .scaleXOrdinal()
      .scaleYContinuous(min: 0)               // Revenue scale
      .scaleY2Continuous(min: 0, max: 50)     // Percentage scale
      .theme(ChartTheme.defaultTheme())
      .build();
}
```

## 💡 Why Not Just Use...?

| Alternative | Why Cristalyse is Better |
|-------------|---------------------------|
| **fl_chart** | Grammar of graphics API vs basic chart widgets. Dual Y-axis support vs single axis limitation. |
| **charts_flutter** | Active development vs deprecated. Stacked bars and advanced features vs basic charts. |
| **Web charts (plotly.js)** | Native performance vs DOM rendering. True mobile deployment vs responsive web. |
| **Platform-specific charts** | Write once vs write 3x for iOS/Android/Web. Consistent UX vs platform differences. |
| **Business tools (Tableau)** | Embedded in your app vs separate tools. Full customization vs template limitations. |

## 🛠 Advanced Configuration

### Custom Themes
```dart
final customTheme = ChartTheme(
  backgroundColor: Colors.grey[50]!,
  primaryColor: Colors.deepPurple,
  colorPalette: [Colors.blue, Colors.red, Colors.green],
  gridColor: Colors.grey[300]!,
  axisTextStyle: TextStyle(fontSize: 14, color: Colors.black87),
  padding: EdgeInsets.all(40),
);

chart.theme(customTheme)
```

### Animation Control
```dart
chart.animate(
  duration: Duration(milliseconds: 1200),
  curve: Curves.elasticOut,  // Try different curves!
)
```

### Advanced Data Mapping
```dart
// Map any data structure
chart
    .data(complexData)
    .mapping(
      x: 'timestamp',           // Time series
      y: 'metric_value',        // Numeric values  
      color: 'category',        // Color grouping
      size: 'importance'        // Size encoding
    )
    .mappingY2('efficiency')    // Secondary Y-axis for dual charts
```

### Stacked Bar Configuration
```dart
chart
    .data(budgetData)
    .mapping(x: 'department', y: 'amount', color: 'category')
    .geomBar(
      style: BarStyle.stacked,        // Stack segments
      width: 0.8,                     // Bar width
      borderRadius: BorderRadius.circular(4), // Rounded corners
      alpha: 0.9,                     // Transparency
    )
    .scaleXOrdinal()
    .scaleYContinuous(min: 0)
```

## 📱 Platform Support

- ✅ **iOS 12+**
- ✅ **Android API 21+**
- ✅ **Web (Chrome 80+, Firefox, Safari)**
- ✅ **Windows 10+**
- ✅ **macOS 10.14+**
- ✅ **Linux (Ubuntu 18.04+)**

## 🧪 Development Status

**Current Version: 1.0.1** - Production ready with enhanced dual Y-axis SVG export and comprehensive interactive capabilities

We're shipping progressively! Each release adds new visualization types while maintaining backward compatibility.

- ✅ **v0.1.0** - Scatter plots and basic theming
- ✅ **v0.2.0** - Line charts and animations
- ✅ **v0.3.0** - Bar charts (including horizontal) and areas
- ✅ **v0.4.0** - Enhanced theming with custom colors and text styles, stacked bars
- ✅ **v0.5.0** - **Dual Y-axis support** and advanced bar chart variations
- ✅ **v0.6.0** - Interactive tooltips
- ✅ **v0.7.0** - Interactive panning
- ✅ **v0.8.0** - **Area chart support** with animations and multi-series capabilities
- ✅ **v0.9.0** - **Enhanced dual Y-axis SVG export** with comprehensive scale support

## 🤝 Contributing

We'd love your help! Check out our [contributing guide](CONTRIBUTING.md) and:

- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🔧 Submit pull requests

## 📄 License

MIT License - build whatever you want, commercially or otherwise.

## 🔗 Links

- 📦 [pub.dev package](https://pub.dev/packages/cristalyse)
- 📖 [Full documentation](https://github.com/rudi-q/cristalyse#readme)
- 🐛 [Issue tracker](https://github.com/rudi-q/cristalyse/issues)
- 💬 [Discussions](https://github.com/rudi-q/cristalyse/discussions)

---

**Ready to create stunning visualizations?** `flutter pub add cristalyse` and start building! 🚀

*Cristalyse: Finally, the grammar of graphics library Flutter developers deserve.*