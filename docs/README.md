<svg width="177" height="24" viewBox="0 0 177 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="textGradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#4a9999;stop-opacity:1" />
            <stop offset="15%" style="stop-color:#3d8080;stop-opacity:1" />
            <stop offset="40%" style="stop-color:#2d6666;stop-opacity:1" />
            <stop offset="70%" style="stop-color:#1a4d4d;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#0f3333;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="textShine" x1="20%" y1="10%" x2="80%" y2="90%">
            <stop offset="0%" style="stop-color:#ffffff;stop-opacity:0.05" />
            <stop offset="30%" style="stop-color:#ffffff;stop-opacity:0.02" />
            <stop offset="70%" style="stop-color:#ffffff;stop-opacity:0.01" />
            <stop offset="100%" style="stop-color:#ffffff;stop-opacity:0" />
        </linearGradient>
        <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="1" result="coloredBlur"/>
            <feMerge>
                <feMergeNode in="coloredBlur"/>
                <feMergeNode in="SourceGraphic"/>
            </feMerge>
        </filter>
        <filter id="textShadow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur in="SourceAlpha" stdDeviation="1.5"/>
            <feOffset dx="1" dy="2" result="offsetblur"/>
            <feComponentTransfer>
                <feFuncA type="linear" slope="0.2"/>
            </feComponentTransfer>
            <feMerge>
                <feMergeNode/>
                <feMergeNode in="SourceGraphic"/>
            </feMerge>
        </filter>
    </defs>
    <text x="8" y="12"
          font-family="Arial, sans-serif"
          font-size="17"
          font-weight="600"
          fill="url(#textGradient)"
          text-anchor="start"
          dominant-baseline="middle"
          filter="url(#textShadow)">Cristalyse</text>
    <text x="8" y="12"
          font-family="Arial, sans-serif"
          font-size="17"
          font-weight="600"
          fill="url(#textShine)"
          text-anchor="start"
          dominant-baseline="middle"
          filter="url(#glow)">Cristalyse</text>
    <text x="95" y="12"
          font-family="Arial, sans-serif"
          font-size="17"
          font-weight="400"
          fill="#6b7280"
          text-anchor="start"
          dominant-baseline="middle">Docs</text>
</svg>

Welcome to the official documentation for **Cristalyse** - the grammar of graphics visualization library that Flutter developers have been waiting for.

## What is Cristalyse?

Cristalyse brings the power of grammar of graphics (think ggplot2) to Flutter with buttery-smooth 60fps animations and true cross-platform deployment. Create beautiful data visualizations without fighting against chart widgets or settling for web-based solutions.

## Key Features

- **Grammar of Graphics API** - Familiar syntax if you've used ggplot2 or plotly
- **Native 60fps Animations** - Leverages Flutter's rendering engine, not DOM manipulation
- **True Cross-Platform** - One codebase → Mobile, Web, Desktop, all looking identical
- **GPU-Accelerated Performance** - Handle large datasets without breaking a sweat
- **Flutter-First Design** - Seamlessly integrates with your existing Flutter apps
- **Dual Y-Axis Support** - Professional business dashboards with independent left/right scales
- **Advanced Bar Charts** - Grouped, stacked, and horizontal variations with smooth animations
- **Interactive Charts** - Engage users with tooltips, hover effects, and click events
- **SVG Export** - Export charts as professional-quality vector graphics

## Documentation Structure

### Get Started
- **Installation**: Add Cristalyse to your Flutter project
- **Quick Start**: Your first chart in 30 seconds
- **Examples**: Real-world use cases and implementations

### Chart Types
- **Scatter Plots**: Point-based visualizations with size and color mapping
- **Line Charts**: Time series and trend analysis with multi-series support
- **Bar Charts**: Vertical, horizontal, grouped, and stacked variations
- **Area Charts**: Filled visualizations perfect for showing volume over time
- **Dual Axis**: Combine different metrics on independent Y-scales

### Features
- **Animations**: Smooth 60fps transitions and progressive rendering
- **Theming**: Light, dark, and custom themes with color palettes
- **Interactions**: Tooltips, pan/zoom, and click handlers
- **Export**: SVG vector graphics for reports and presentations

### Advanced Topics
- **Scales**: Continuous, ordinal, color, and size mappings
- **Data Mapping**: Grammar of graphics aesthetic mappings
- **Performance**: Optimize for large datasets and smooth animations
- **Custom Themes**: Create your own visual styles

## Development

To preview documentation changes locally:

```bash
npm i -g mintlify
mintlify dev
```

## Quick Example

```dart
import 'package:cristalyse/cristalyse.dart';

CristalyseChart()
  .data([
    {'x': 1, 'y': 2, 'category': 'A'},
    {'x': 2, 'y': 3, 'category': 'B'},
    {'x': 3, 'y': 1, 'category': 'A'},
  ])
  .mapping(x: 'x', y: 'y', color: 'category')
  .geomPoint(size: 8.0, alpha: 0.8)
  .scaleXContinuous()
  .scaleYContinuous()
  .theme(ChartTheme.defaultTheme())
  .build();
```

## Links

- [GitHub Repository](https://github.com/rudi-q/cristalyse)
- [pub.dev Package](https://pub.dev/packages/cristalyse)
- [Issue Tracker](https://github.com/rudi-q/cristalyse/issues)
- [Contributing Guide](https://github.com/rudi-q/cristalyse/blob/main/CONTRIBUTING.md)
