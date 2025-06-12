# 🔮 Cristalyse

**The grammar of graphics visualization library that Flutter developers have been waiting for.**

[![pub package](https://img.shields.io/pub/v/cristalyse.svg)](https://pub.dev/packages/cristalyse)
[![Flutter support](https://img.shields.io/badge/Flutter-1.17%2B-blue)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Finally, create beautiful data visualizations in Flutter without fighting against chart widgets or settling for web-based solutions.

## ✨ Why Cristalyse?

**Stop wrestling with limited chart libraries.** Cristalyse brings the power of grammar of graphics (think ggplot2) to Flutter with buttery-smooth 60fps animations and true cross-platform deployment.

- 🎨 **Grammar of Graphics API** - Familiar syntax if you've used ggplot2 or plotly
- 🚀 **Native 60fps Animations** - Leverages Flutter's rendering engine, not DOM manipulation
- 📱 **True Cross-Platform** - One codebase → Mobile, Web, Desktop, all looking identical
- ⚡ **GPU-Accelerated Performance** - Handle large datasets without breaking a sweat
- 🎯 **Flutter-First Design** - Seamlessly integrates with your existing Flutter apps

## 🎯 Perfect For

- **Flutter developers** building data-driven apps who need more than basic chart widgets
- **Data scientists** who want to deploy interactive visualizations to mobile without learning Swift/Kotlin
- **Enterprise teams** building dashboards that need consistent UX across all platforms

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

### Horizontal Bar Chart
```dart
// Don't forget to define your data, for example:
// final departmentData = [
//   {'department': 'Sales', 'headcount': 25},
//   {'department': 'Engineering', 'headcount': 40},
//   {'department': 'Marketing', 'headcount': 15},
//   {'department': 'HR', 'headcount': 10},
// ];

CristalyseChart()
  .data(departmentData) // Replace with your actual data
  .mapping(x: 'department', y: 'headcount') // x becomes the category axis, y the value axis
  .geomBar(
    borderRadius: BorderRadius.circular(4), // Example: rounded corners for bars
    borderWidth: 1.0,                       // Example: add a border to bars
  )
  .coordFlip() // This is the key to make the bar chart horizontal
  .scaleXOrdinal() // After coordFlip, X scale is for categories (departments)
  .scaleYContinuous(min: 0) // After coordFlip, Y scale is for values (headcount)
  .theme(ChartTheme.defaultTheme())
  .animate(duration: Duration(milliseconds: 900))
  .build()
```

## 🎨 Grammar of Graphics Made Simple

Cristalyse follows the proven grammar of graphics pattern. If you've used ggplot2, you'll feel right at home:

| Component | Purpose | Example |
|-----------|---------|---------|
| **Data** | Your dataset | `.data(salesData)` |
| **Mapping** | Connect data to visuals | `.mapping(x: 'date', y: 'revenue', color: 'region')` |
| **Geometry** | How to draw the data | `.geomPoint()`, `.geomLine()` |
| **Scales** | Transform data to screen coordinates | `.scaleXContinuous()`, `.scaleYContinuous()` |
| **Themes** | Visual styling | `.theme(ChartTheme.defaultTheme())` |
| **Animation** | Bring it to life | `.animate(duration: Duration(milliseconds: 500))` |

## 🔥 Current Features

### ✅ Ready to Use
- **Scatter plots** with size and color mapping
- **Line charts** with multi-series support
- **Bar charts** (vertical and horizontal)
- **Smooth animations** with customizable timing
- **Light and dark themes** with full customization
- **Enhanced theming** with multiple built-in themes (including Solarized) and color palettes
- **Responsive scaling** for all screen sizes
- **High-DPI support** for crisp visuals

### 🚧 Coming Soon (Next Releases)
- Area charts with stacking
- Statistical overlays (regression lines, confidence intervals)
- Interactive pan and zoom
- Faceting for small multiples
- Export to PNG/SVG

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
    .theme(ChartTheme.solarizedDarkTheme()) // Example: Use the new Solarized Dark theme
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

## 💡 Why Not Just Use...?

| Alternative | Why Cristalyse is Better |
|-------------|---------------------------|
| **fl_chart** | Grammar of graphics API vs basic chart widgets. Smooth animations vs static charts. |
| **charts_flutter** | Active development vs deprecated. Modern Flutter APIs vs legacy code. |
| **Web charts (plotly.js)** | Native performance vs DOM rendering. True mobile deployment vs responsive web. |
| **Platform-specific charts** | Write once vs write 3x for iOS/Android/Web. Consistent UX vs platform differences. |

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

### Data Mapping
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
```

## 📱 Platform Support

- ✅ **iOS 12+**
- ✅ **Android API 21+**
- ✅ **Web (Chrome 80+, Firefox, Safari)**
- ✅ **Windows 10+**
- ✅ **macOS 10.14+**
- ✅ **Linux (Ubuntu 18.04+)**

## 🧪 Development Status

**Current Version: 0.4.0** - Production ready for scatter plots and line charts and custom themes

We're shipping progressively! Each release adds new visualization types while maintaining backward compatibility.

- ✅ **v0.1.0** - Scatter plots and basic theming
- ✅ **v0.2.0** - Line charts and animations
- ✅ **v0.3.0** - Bar charts (including horizontal) and areas
- ✅ **v0.4.0** - Enhanced theming with custom colors and text styles
- 🚧 **v0.5.0** - Statistical layers

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