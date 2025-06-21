## 0.6.0 - 2025-06-21

- **Major Feature: Interactive Chart Layer**
  - Added a new interaction system to support hover, click, and pan gestures on chart data points.
  - Introduced `ChartInteraction` configuration for enabling and customizing user interactions.
  - Implemented a flexible tooltip system with `TooltipConfig` for full control over tooltip appearance, content, and behavior.
  - Added `onHover`, `onExit`, and `onTap` callbacks for developers to hook into user interaction events.

- **Example App**
  - Added a new 'Interactive' tab to the example app to showcase the new tooltip and interaction features.

#### 📖 Examples Added

```dart
// Interactive Scatter Plot with Tooltips and Click Events
CristalyseChart()
  .data(salesData)
  .mapping(x: 'week', y: 'revenue', color: 'rep')
  .geomPoint()
  .interaction(
    tooltip: TooltipConfig(
      builder: (point) => MyCustomTooltip(point: point),
      style: TooltipStyle(backgroundColor: Colors.black87),
    ),
    click: ClickConfig(
      onTap: (point) => showDetailsDialog(context, point),
    ),
  )
  .build();
```

## 0.5.1 - 2025-06-14
#### Documentation
- Updated screenshots with latest examples

## 0.5.0 - 2025-06-14

#### 🚀 Major Feature: Dual Y-Axis Support

**BREAKING THE REDDIT COMPLAINTS**: "No support for multiple Axis" → **SOLVED** ✅

- **Independent Y-Axes**: Full support for left (primary) and right (secondary) Y-axes with independent scales and data mappings
- **New API Methods**:
	- `.mappingY2(column)` - Map data to secondary Y-axis
	- `.scaleY2Continuous(min, max)` - Configure secondary Y-axis scale
	- `yAxis: YAxis.primary|secondary` parameter for all geometries
- **Smart Layout**: Automatic padding adjustment for dual axis labels with color-coded right axis
- **All Geometries Supported**: Points, lines, and bars can use either Y-axis
- **Perfect for Business Dashboards**: Revenue vs Conversion Rate, Volume vs Efficiency metrics

#### 🔧 Fixed: Ordinal Scale Support for Lines and Points

- **Critical Bug Fix**: Lines and points now properly handle categorical X-axes (strings like "Jan", "Feb")
- **Root Cause**: `_getNumericValue()` was failing on string values, breaking line/point rendering on ordinal scales
- **Solution**: Smart scale detection - uses `bandCenter()` for ordinal scales, numeric conversion for continuous scales
- **Impact**: Fixes existing charts that combine categorical X-data with line/point geometries

#### 🛠 Enhanced: Coordinate Flipping for Horizontal Charts

- **Improved Logic**: Fixed coordinate flipping interaction with dual Y-axis system
- **Backwards Compatibility**: Existing horizontal bar charts work unchanged
- **Smart Scale Routing**: Flipped coordinates properly swap X/Y axis roles regardless of dual Y-axis configuration

#### 📊 Technical Improvements

- **Dual Scale Management**: Independent domain calculation for primary and secondary Y-axes
- **Rendering Pipeline**: Enhanced geometry drawing to route data to correct Y-axis
- **Memory Optimization**: Efficient scale caching and geometry batching
- **Animation Sync**: Coordinated animations across both Y-axes

#### 🧪 Comprehensive Testing

- **100+ New Tests**: Full coverage for dual Y-axis functionality
- **Edge Case Handling**: Robust testing for invalid data, missing columns, extreme values
- **Performance Testing**: Validated with 1000+ data points
- **Cross-Platform**: Tested on iOS, Android, Web, and Desktop

#### 📖 Examples Added

```dart
// Business Dashboard: Revenue + Conversion Rate
CristalyseChart()
  .data(businessData)
  .mapping(x: 'month', y: 'revenue')      // Primary Y-axis
  .mappingY2('conversion_rate')           // Secondary Y-axis
  .geomBar(yAxis: YAxis.primary)          // Revenue bars (left scale)
  .geomLine(yAxis: YAxis.secondary)       // Conversion line (right scale)
  .scaleXOrdinal()
  .scaleYContinuous(min: 0)               // Revenue scale
  .scaleY2Continuous(min: 0, max: 100)    // Percentage scale
  .build();

// Mixed Metrics: Any two different data ranges
CristalyseChart()
  .data(performanceData)
  .mapping(x: 'week', y: 'sales_volume')
  .mappingY2('customer_satisfaction')
  .geomBar(yAxis: YAxis.primary, alpha: 0.7)
  .geomLine(yAxis: YAxis.secondary, strokeWidth: 3.0)
  .geomPoint(yAxis: YAxis.secondary, size: 8.0)
  .build();
```

#### 🎯 Use Cases Unlocked

- **Financial Dashboards**: Revenue vs Profit Margin, Volume vs Price
- **Marketing Analytics**: Traffic vs Conversion Rate, Impressions vs CTR
- **Operational Metrics**: Production Volume vs Quality Score
- **Sales Performance**: Deal Count vs Average Deal Size
- **E-commerce**: Orders vs Customer Satisfaction Score

#### ⚡ Performance Metrics

- **Rendering**: Maintains 60fps with dual Y-axis charts
- **Memory**: <10MB additional overhead for secondary axis
- **Scale Calculation**: <5ms for dual axis domain computation
- **Animation**: Smooth synchronized transitions across both axes

#### 🐛 Fixes

- **Stacked Bar Scale Domain**: Improved Y-axis domain calculation for stacked bars
- **Ordinal Line Rendering**: Fixed line geometry with categorical X-axes
- **Coordinate Flip Logic**: Resolved conflicts between dual Y-axis and coordinate flipping
- **Animation Edge Cases**: Better handling of invalid animation values

#### 🔄 Migration Guide

**Existing Charts**: No changes required - fully backwards compatible

**New Dual Y-Axis Charts**:
1. Add `.mappingY2('column_name')` for secondary Y-axis data
2. Add `.scaleY2Continuous()` to configure secondary axis scale
3. Specify `yAxis: YAxis.secondary` for geometries using right axis
4. Primary axis geometries work unchanged (default to `YAxis.primary`)

#### 📈 What's Next (v0.6.0)

- **Statistical Layers**: Regression lines, confidence intervals, trend analysis
- **Interactive Features**: Pan, zoom, hover tooltips, selection brushing
- **Advanced Scales**: Logarithmic scales, time series scales with smart tick formatting
- **Export Capabilities**: PNG/SVG export, print optimization, high-DPI rendering

---

**This release positions Cristalyse as a serious competitor to Tableau, Power BI, and other professional visualization tools. Dual Y-axis support is a fundamental requirement for business dashboards - now we have it! 🎯**

# 0.4.4 - 2025-06-12

## Added

* Stacked Bar Charts: Full support for stacked bars with `BarStyle.stacked`
	+ Segment-by-segment progressive animation with staggered timing
	+ Automatic cumulative value calculation for proper stacking
	+ Consistent color ordering across all stacked groups
	+ Smart Y-scale domain calculation based on total stack heights (not individual segments)

## Fixed

* Stacked Bar Scale Domain: Y-axis now correctly calculates domain based on cumulative stacked totals instead of individual segment values, preventing bars from rendering outside chart bounds
* Stacked Bar Animation: Improved animation timing with proper segment delays for smooth visual building effect

## Improved

* Example App: Added new "Stacked Bars" tab showcasing revenue breakdown by category with realistic business data
* Chart Features Documentation: Updated feature descriptions to include stacked bar capabilities

## Technical

* Enhanced `_setupYScale` method to detect stacked bar geometries and calculate proper domain bounds
* Added 10% padding to stacked bar charts for better visual spacing
* Improved data grouping logic in `_drawStackedBars` with consistent sorting for predictable stacking order

## 0.4.3 - 2025-06-12

#### Added
- 📸 Added screenshots of the example app to README

## 0.4.2 - 2025-06-12

#### Improved
- Enhanced the example project to showcase multiple chart types, themes, and color palettes.

## 0.4.1 - 2025-06-12

#### Technical
- Code quality improvements and linting compliance

## 0.4.0 - 2025-06-12

#### Added
- **Enhanced Theming**: Added `solarizedLightTheme` and `solarizedDarkTheme` to the theme factory.
- **Color Palettes**: Introduced multiple color palettes (`warm`, `cool`, `pastel`) that can be applied independently of the base theme.
- **Custom Label Styles**: Added an optional `axisLabelStyle` to `ChartTheme` for more granular control over axis label appearance.
- **Interactive Example App**: The example app now features controls to dynamically cycle through themes, color palettes, and adjust chart-specific properties like bar width, line stroke width, and point size via a slider.

#### Fixed
- **Axis Label Rendering**: Overhauled axis label drawing logic to correctly render labels with proper spacing and prevent overlap, especially on horizontal charts.
- **Color Palette Application**: Ensured that color palette changes now correctly apply to all chart types, including those without explicit color mappings.

#### Changed
- **Improved Padding**: Increased default padding in `ChartTheme` to give axis labels more breathing room.

## 0.3.0 - 2025-06-12

#### Added
- Bar chart support with `geomBar()`.
- Horizontal bar chart functionality via `coordFlip()` method.
- Added `borderRadius` and `borderWidth` properties to `BarGeometry` for enhanced styling.

#### Fixed
- Resolved numerous rendering issues and lint errors in `animated_chart_widget.dart` to enable robust bar chart display.
- Corrected scale setup and drawing logic for flipped coordinates in horizontal bar charts.
- Ensured proper propagation of the `coordFlipped` flag throughout the chart rendering pipeline.

## 0.2.3 - 2025-06-08

#### Technical
- Code quality improvements and linting compliance

### 0.2.2 - 2025-06-08

#### Documentation
- Updated README with comprehensive examples and installation guide
- Added CONTRIBUTING.md for new contributors

### 0.2.1 - 2025-06-08

#### Changed
- Updated deprecated code to use `withValues` instead of `withOpacity`

### [0.2.0] - 2025-06-08

#### Added
- Line chart support with `geom_line()`
- Basic animations with configurable duration and curves
- Multi-series support with color-grouped lines
- Staggered point animations and progressive line drawing
- Dark theme support and theme switching

#### Fixed
- Canvas rendering crashes due to invalid opacity values
- TextPainter missing textDirection parameter
- Coordinate validation for edge cases and invalid data
- Animation progress validation and fallback handling
- Y-axis label positioning and overlap issues

#### Technical
- Comprehensive input validation for all numeric values
- Graceful handling of NaN, infinite, and out-of-bounds data
- Improved error recovery and fallback mechanisms


## 0.1.0

* Initial release
* Basic scatter plot support (`geom_point`)
* Grammar of graphics API
* Linear scales for continuous data
* Light and dark themes
* Cross-platform Flutter support

## Planned for 0.2.0

* Line charts (`geom_line`)
* Basic animations
* Improved documentation
* Performance optimizations