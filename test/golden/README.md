# Alchemist Visual Regression Test Suite

This directory contains comprehensive visual regression tests for the Cristalyse charting library using Alchemist.

## Purpose

These tests are designed to:
1. Provide 100% feature coverage of the charting library
2. Serve as a safety net before refactoring AnimatedChartPainter (3,861 lines)
3. Catch visual regressions when making changes to the rendering engine
4. Document all supported chart types and features through executable tests

## Structure

The test suite is organized logically into separate files:

### `helpers/chart_builders.dart`
Contains reusable helper functions for building charts. **Note:** This file needs to be updated to match the correct API:
- Use `geomPoint()`, `geomLine()`, `geomBar()`, etc. instead of `.geom()`
- Use `scaleXContinuous()`, `scaleYContinuous()`, `scaleXOrdinal()` instead of `.scale()`
- Use `limits` parameter for custom bounds
- Import `BorderRadius` and `Radius` from `package:flutter/material.dart`

### `chart_types_test.dart`
Tests for all chart types and their variations:
- **Scatter plots**: Different point shapes (circle, square, triangle), sizes, borders
- **Line charts**: Line styles (solid, dashed, dotted), stroke widths, multi-series
- **Bar charts**: Vertical/horizontal, grouped/stacked, rounded corners, borders
- **Area charts**: Filled/outline, transparency, multi-series
- **Pie charts**: Basic pie, donut, labels, percentages, exploded slices
- **Heat maps**: Color gradients (viridis, coolWarm, heatMap, greenRed), rounded cells, value labels
- **Bubble charts**: Size scaling, size guides, labels
- **Progress bars**: Orientations (horizontal, vertical, circular), styles (filled, striped, gradient, stacked, grouped, gauge, concentric)
- **Dual Y-axis**: Combined bar and line charts

### `themes_test.dart`
Tests for all built-in themes across different chart types:
- Default theme
- Dark theme
- Solarized Light theme
- Solarized Dark theme

Tested on: scatter plots, bar charts, line charts, pie charts, heat maps, multi-series charts

### `legends_test.dart`
Tests for legend functionality:
- **Positions**: topLeft, topRight, bottomLeft, bottomRight, top, bottom, left, right
- **Orientations**: horizontal, vertical, auto
- **Symbol shapes**: auto, circle, square, line
- **Theme integration**: Legends with different themes

### `features_test.dart`
Tests for special chart features:
- **Axis titles**: Custom X and Y axis labels
- **Custom bounds**: Non-zero baselines, negative to positive ranges
- **Transparency**: Various alpha values
- **Coordinate flipping**: Normal vs flipped coordinates
- **Borders**: Different border widths
- **Border radius**: Rounded corners on bars and cells

### `complex_test.dart`
Tests for complex combinations:
- **Multi-geometry**: Charts with multiple geometry types (area + line + points)
- **Dual axis with legends**: Combined features
- **Themed customizations**: Multiple features with themes
- **Comprehensive combinations**: Testing multiple features together

## API Reference

### Correct Cristalyse API Usage

Based on the codebase analysis, here's the correct API:

```dart
// Basic chart construction
CristalyseChart()
    .data(data)
    .mapping(x: 'column_x', y: 'column_y', color: 'series')
    .geomPoint()  // Not .geom(PointGeometry())
    .scaleXContinuous(title: 'X Axis', limits: (0, 100))  // Not .scale(x: LinearScale())
    .scaleYContinuous(title: 'Y Axis')
    .theme(ChartTheme.dark())
    .legend(LegendConfig(position: LegendPosition.topRight))
    .coordFlip(true)
    .build();
```

### Geometry Methods
- `geomPoint({size, color, alpha, shape, borderWidth, yAxis})`
- `geomLine({strokeWidth, color, alpha, style, yAxis})`
- `geomBar({width, color, alpha, orientation, style, borderRadius, borderWidth, yAxis})`
- `geomArea({strokeWidth, color, alpha, style, fillArea, yAxis})`
- `geomPie({innerRadius, outerRadius, showLabels, showPercentages, explodeSlices})`
- `geomHeatMap({cellSpacing, cellBorderRadius, showValues, colorGradient})`
- `geomBubble({minSize, maxSize, limits, title, alpha, shape, borderWidth, showLabels})`
- `geomProgress({orientation, style, thickness, ...})`

### Scale Methods
- `scaleXContinuous({limits, labels, title})`
- `scaleYContinuous({limits, labels, title})`
- `scaleY2Continuous({limits, labels, title})`
- `scaleXOrdinal({labels, title})`
- `scaleYOrdinal({labels, title})`

### Theme Methods
- `ChartTheme.defaultTheme()`
- `ChartTheme.dark()`
- `ChartTheme.solarizedLight()`
- `ChartTheme.solarizedDark()`

### Gradient Color Scales
- `GradientColorScale.viridis()`
- `GradientColorScale.coolWarm()`
- `GradientColorScale.heatMap()`
- `GradientColorScale.greenRed()`

## Feature Coverage Checklist

### Chart Types
- [x] Scatter Plot
  - [x] Circle points
  - [x] Square points
  - [x] Triangle points
  - [x] Variable sizes
  - [x] Borders
  - [x] Multi-series
- [x] Line Chart
  - [x] Solid lines
  - [x] Dashed lines
  - [x] Dotted lines
  - [x] Variable stroke widths
  - [x] Multi-series
- [x] Bar Chart
  - [x] Vertical orientation
  - [x] Horizontal orientation
  - [x] Grouped style
  - [x] Stacked style
  - [x] Rounded corners
  - [x] Borders
- [x] Area Chart
  - [x] Filled
  - [x] Outline only
  - [x] Multi-series
- [x] Pie Chart
  - [x] Basic pie
  - [x] Donut (inner radius)
  - [x] Labels
  - [x] Percentages
  - [x] Exploded slices
- [x] Heat Map
  - [x] Viridis gradient
  - [x] Cool-warm gradient
  - [x] Heat map gradient
  - [x] Green-red gradient
  - [x] Rounded cells
  - [x] Value labels
- [x] Bubble Chart
  - [x] Size scaling
  - [x] Size guides
  - [x] Labels
- [x] Progress Bars
  - [x] Horizontal
  - [x] Vertical
  - [x] Circular
  - [x] Filled style
  - [x] Striped style
  - [x] Gradient style
  - [x] Stacked style
  - [x] Grouped style
  - [x] Gauge style
  - [x] Concentric style
- [x] Dual Y-Axis Charts

### Themes
- [x] Default theme (all chart types)
- [x] Dark theme (all chart types)
- [x] Solarized Light theme (all chart types)
- [x] Solarized Dark theme (all chart types)

### Legends
- [x] All 8 positions (topLeft, topRight, bottomLeft, bottomRight, top, bottom, left, right)
- [x] Orientations (horizontal, vertical, auto)
- [x] Symbol shapes (auto, circle, square, line)
- [x] Theme integration

### Special Features
- [x] Axis titles
- [x] Custom bounds (min/max)
- [x] Transparency (alpha)
- [x] Coordinate flipping
- [x] Borders
- [x] Border radius
- [x] Multi-geometry charts
- [x] Color mapping for multi-series

## Running the Tests

### Generate Golden Files

```bash
# Generate all golden files
flutter test test/golden/ --update-goldens

# Generate for specific test file
flutter test test/golden/chart_types_test.dart --update-goldens
```

### Run Tests (Compare Against Goldens)

```bash
# Run all visual regression tests
flutter test test/golden/

# Run specific test file
flutter test test/golden/chart_types_test.dart
```

### CI Integration

The tests are configured to work in CI environments through `flutter_test_config.dart`:
- Platform goldens enabled for local development
- CI goldens enabled when `CI` environment variable is set

## Next Steps

The helper functions in `helpers/chart_builders.dart` need to be updated to use the correct API as documented above. The test files themselves are structured correctly but will fail until the helpers are fixed.

Key changes needed:
1. Replace `.scale()` with `scaleXContinuous()`, `scaleYContinuous()`, etc.
2. Replace `.geom(Geometry())` with specific `geomPoint()`, `geomLine()`, etc.
3. Add missing Flutter imports (`BorderRadius`, `Radius`, `ThemeData`)
4. Fix parameter names (e.g., `limits` instead of `min`/`max`)
5. Update legend config parameters

## Benefits for AnimatedChartPainter Refactoring

This test suite will:
1. **Catch regressions**: Any visual changes will be immediately detected
2. **Document behavior**: Tests serve as executable documentation
3. **Enable confident refactoring**: Make changes knowing tests will catch breaks
4. **Provide examples**: Each test is a working example of the feature
5. **Improve maintainability**: Logical organization makes tests easy to update

## Test Coverage Statistics

Once implemented correctly, this suite will provide:
- **9 chart types** with multiple variations each
- **4 themes** tested across all chart types
- **8 legend positions** + 3 orientations + 4 symbol shapes
- **15+ special features** tested in isolation and combination
- **Estimated 150+ golden file screenshots** covering the entire library

This represents comprehensive visual coverage to support the AnimatedChartPainter refactoring.
