#      README.md     
# Cristalyse

A high-performance data visualization library for Flutter implementing grammar of graphics principles.

## Features

- 🎨 Grammar of graphics API familiar to ggplot2 users
- 🚀 60fps native animations with Flutter's rendering engine
- 📱 True cross-platform deployment (mobile, web, desktop)
- ⚡ Superior performance through GPU rendering
- 🎯 Seamless integration with Flutter applications

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cristalyse: ^0.1.0
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
  .geom_point(size: 6.0, alpha: 0.8)
  .scale_x_continuous(min: 0, max: 4)
  .scale_y_continuous(min: 0, max: 4)
  .theme(ChartTheme.defaultTheme())
  .build()
```

## Documentation

See [example/](example/) for complete examples and usage patterns.

## Status

🚧 **Early Development** - Currently supports scatter plots. Line charts and animations coming soon.

