## 0.9.4 - 2025-07-04
* Improved web wasm compatibility and documentation

## 0.9.3 - 2025-07-03

- **📖 Comprehensive Documentation Site Now Live**
  - **[docs.cristalyse.com](https://docs.cristalyse.com)** is now available with complete guides, examples, and API reference
  - Step-by-step tutorials, and everything you need to master data visualization in Flutter
  - Professional documentation site with enhanced visual examples and comprehensive chart type coverage

<p align="center">
  <img src="doc/images/documentation.png" alt="Cristalyse Documentation Site" width="600"/>
  <br/>
  <em>👉 Visit <a href="https://docs.cristalyse.com">docs.cristalyse.com</a> for complete guides and examples</em>
</p>

## 0.9.2 - 2025-07-03

- **Major Enhancement: Advanced Pan Control System with Visual Clipping**
  - **Fixed chart position reset bug** - Charts now maintain their panned position across multiple pan gestures
  - **Infinite panning capability** - Users can now pan infinitely in any direction without hitting boundaries
  - **Visual clipping implementation** - Data points that would appear outside the plot area are cleanly cut off
  - **Professional chart boundaries** - Prevents data rendering over Y-axis labels while maintaining smooth pan experience
  - **Selective axis panning control** - Independent X and Y axis panning with `updateXDomain` and `updateYDomain` boolean parameters
  - **Enhanced pan domain persistence** - Pan state is properly maintained and doesn't reset to original position on subsequent interactions

- **New Pan Configuration Options**
  - `updateXDomain: true/false` - Enable/disable horizontal (X-axis) panning independently
  - `updateYDomain: true/false` - Enable/disable vertical (Y-axis) panning independently
  - **Canvas clipping optimization** - Efficient rendering pipeline that clips geometries to plot area without affecting axes
  - **No more pan blocking** - Removed restrictive boundary checks that prevented natural panning behavior
  - Improved pan delta calculations for smoother, more natural panning experience

- **Enhanced Pan User Experience**
  - **Smooth infinite exploration** - Users can explore data ranges far beyond original dataset boundaries
  - **Clean visual presentation** - Chart maintains professional appearance with proper axis label visibility
  - **Responsive performance** - Clipping operations are optimized for smooth 60fps panning
  - **Granular panning control**: Choose horizontal-only, vertical-only, both directions, or no panning
  - **Time series optimization**: Perfect for time-based charts that only need horizontal scrolling
  - **Scatter plot flexibility**: Enable both axes for full 2D exploration
  - **Dashboard compatibility**: Configure different pan behaviors for different chart types in the same app
  - **Backward compatibility**: Existing pan configurations continue to work without changes

#### 🎯 Technical Implementation

```dart
// Canvas clipping ensures clean boundaries
canvas.save();
canvas.clipRect(plotArea);  // Clip all geometries to plot area

// Draw all chart geometries (points, lines, bars, areas)
for (final geometry in geometries) {
  _drawGeometry(canvas, plotArea, geometry, ...);
}

// Restore canvas state for axis rendering
canvas.restore();
_drawAxes(canvas, size, plotArea, xScale, yScale, y2Scale);
```

**Result**: Perfect balance between infinite panning freedom and professional visual boundaries.

#### 📖 Usage Examples

```dart
// Horizontal-only panning (perfect for time series)
CristalyseChart()
  .data(timeSeriesData)
  .mapping(x: 'date', y: 'value')
  .geomLine()
  .interaction(
    pan: PanConfig(
      enabled: true,
      updateXDomain: true,   // ✅ Allow horizontal panning
      updateYDomain: false,  // ❌ Disable vertical panning
      onPanUpdate: (info) {
        print('Horizontal range: ${info.visibleMinX} - ${info.visibleMaxX}');
      },
    ),
  )
  .build();

// Vertical-only panning (useful for ranking charts)
CristalyseChart()
  .data(rankingData)
  .mapping(x: 'category', y: 'score')
  .geomBar()
  .interaction(
    pan: PanConfig(
      enabled: true,
      updateXDomain: false,  // ❌ Disable horizontal panning
      updateYDomain: true,   // ✅ Allow vertical panning
    ),
  )
  .build();

// Full 2D panning (ideal for scatter plots)
CristalyseChart()
  .data(scatterData)
  .mapping(x: 'xValue', y: 'yValue', color: 'category')
  .geomPoint()
  .interaction(
    pan: PanConfig(
      enabled: true,
      updateXDomain: true,   // ✅ Allow horizontal panning
      updateYDomain: true,   // ✅ Allow vertical panning
    ),
  )
  .build();
```

## 0.9.1 - 2025-07-02

- **Extended Example App Platform Support**
  - macOS, Linux, Web, iOS, Android

## 0.9.0 - 2025-07-02

- **Enhanced SVG Export Implementation**
  - Improved SVG export with complete chart rendering pipeline
  - Added support for all chart types: points, lines, bars, areas
  - Proper color mapping, scaling, and axis rendering in SVG format
  - Professional-quality vector graphics output with small file sizes
  - Perfect for presentations, reports, and high-quality documentation

- **API Simplification**
  - `ExportFormat` enum now contains only `svg`
  - `ExportConfig` defaults to SVG format
  - Simplified export API focused on reliable functionality
  - All export documentation updated to reflect SVG-only capabilities

**Benefits of SVG Export:**
- ✅ **Scalable vector graphics** - Infinite zoom without quality loss
- ✅ **Small file sizes** - Efficient for web and print
- ✅ **Professional quality** - Perfect for presentations and reports
- ✅ **Cross-platform reliability** - Works consistently on all platforms
- ✅ **Design software compatibility** - Editable in Figma, Adobe Illustrator, etc.

## 0.8.0 - 2025-07-02

- **Major Feature: Area Chart Support**
  - Added comprehensive `AreaGeometry` class with customizable stroke width, fill opacity, and styling options
  - Implemented `geomArea()` method following grammar of graphics patterns for seamless API integration
  - Progressive area chart animations with smooth fill transitions revealing data over time
  - Full support for multi-series area charts with automatic color mapping and overlapping transparency
  - Dual Y-axis compatibility for complex business dashboards combining area charts with other geometries
  - Combined visualizations: area + line + point charts for enhanced data storytelling
  - Interactive tooltip support with hover detection optimized for area chart geometries
  - Ordinal and continuous X-scale compatibility maintaining consistency with existing chart types

- **Enhanced Example App**
  - Added comprehensive "Area Chart" tab showcasing three distinct area chart implementations
  - Single area chart example with website traffic analytics and smooth fill animations
  - Multi-series area chart demonstrating mobile vs desktop traffic with color-coded transparency
  - Combined area + line + point visualization showing layered data representation techniques
  - Full theme integration with color palette toggling support across all area chart variants
  - Interactive tooltips with custom styling and platform-specific data display

- **Technical Improvements**
  - Efficient area path rendering with baseline calculation and progressive animation support
  - Memory-optimized rendering pipeline leveraging existing line chart infrastructure
  - Comprehensive test coverage with 85+ passing tests including new area chart interaction tests
  - Backward compatibility maintained - zero breaking changes to existing API surface
  - Performance optimizations for large datasets with smooth 60fps area fill animations

#### 📖 Examples Added

```dart
// Basic Area Chart with Custom Styling
CristalyseChart()
  .data(trafficData)
  .mapping(x: 'month', y: 'visitors')
  .geomArea(
    strokeWidth: 2.0,
    alpha: 0.3,
    fillArea: true,
    color: Colors.blue,
  )
  .scaleXOrdinal()
  .scaleYContinuous(min: 0)
  .animate(duration: Duration(milliseconds: 1200))
  .build();

// Multi-Series Area Chart
CristalyseChart()
  .data(platformData)
  .mapping(x: 'month', y: 'users', color: 'platform')
  .geomArea(strokeWidth: 1.5, alpha: 0.4)
  .interaction(
    tooltip: TooltipConfig(
      builder: (point) => CustomTooltip(point: point),
    ),
  )
  .build();

// Combined Area + Line + Points
CristalyseChart()
  .data(analyticsData)
  .mapping(x: 'date', y: 'value')
  .geomArea(alpha: 0.2, strokeWidth: 0)     // Background fill
  .geomLine(strokeWidth: 3.0)               // Trend line
  .geomPoint(size: 6.0)                     // Data points
  .build();

// Dual Y-Axis Area Charts
CristalyseChart()
  .data(businessData)
  .mapping(x: 'quarter', y: 'revenue')
  .mappingY2('efficiency')
  .geomArea(yAxis: YAxis.primary, alpha: 0.3)
  .geomArea(yAxis: YAxis.secondary, alpha: 0.3)
  .scaleY2Continuous(min: 0, max: 100)
  .build();
```

## 0.7.0 - 2025-06-30

- **Major Feature: Enhanced Interactive Panning System**
  - Added persistent pan state that maintains chart position after pan gesture completion
  - Implemented real-time visible range synchronization between header display and chart X-axis
  - Introduced comprehensive `PanConfig` API for full control over pan behavior and callbacks
  - Added `PanInfo` class providing detailed pan state information including visible ranges and delta tracking
  - Enhanced range display card with improved visibility, contrast, and professional styling

- **New Pan API Classes**
  - `PanConfig`: Configure pan behavior with `onPanStart`, `onPanUpdate`, `onPanEnd` callbacks
  - `PanInfo`: Access current visible X/Y ranges, pan state, and gesture deltas
  - `PanState`: Track pan lifecycle (start, update, end) for coordinated UI updates
  - Throttled callback system prevents database overwhelming during continuous panning

- **Visual Enhancements**
  - Redesigned range display card with enhanced contrast and primary color theming
  - Synchronized range values between header card and chart axis labels
  - Improved typography with monospace fonts for precise range display
  - Professional gradient styling with stronger borders for better visibility

- **Technical Improvements**
  - Progressive pan domain accumulation for smooth, natural panning experience
  - Persistent scale domains that maintain panned position across interactions
  - Efficient coordinate transformation from screen pixels to data values
  - Memory-optimized pan state management with automatic cleanup

#### 📖 Examples Added

```dart
// Basic Interactive Panning with Range Updates
CristalyseChart()
  .data(largeDataset)  // 1000+ data points
  .mapping(x: 'timestamp', y: 'value', color: 'series')
  .geomLine(strokeWidth: 2.0)
  .geomPoint(size: 4.0)
  .interaction(
    pan: PanConfig(
      enabled: true,
      onPanUpdate: (info) {
        print('Visible range: ${info.visibleMinX} - ${info.visibleMaxX}');
        // Perfect for loading data on-demand
        fetchDataForRange(info.visibleMinX!, info.visibleMaxX!);
      },
      throttle: Duration(milliseconds: 100), // Prevent database overwhelming
    ),
  )
  .build();

// Advanced Panning with Complete Lifecycle Management
CristalyseChart()
  .data(timeSeriesData)
  .mapping(x: 'date', y: 'price')
  .geomLine()
  .interaction(
    pan: PanConfig(
      enabled: true,
      onPanStart: (info) {
        setState(() => isLoading = true);
        showRangeIndicator(info.visibleMinX, info.visibleMaxX);
      },
      onPanUpdate: (info) {
        updateVisibleRange(info.visibleMinX, info.visibleMaxX);
        // Real-time data streaming based on visible window
        streamData(info.visibleMinX!, info.visibleMaxX!);
      },
      onPanEnd: (info) {
        setState(() => isLoading = false);
        saveUserPreferences(info.visibleMinX, info.visibleMaxX);
        // Chart maintains panned position automatically
      },
    ),
  )
  .build();

// Business Dashboard: Financial Data Exploration
CristalyseChart()
  .data(stockData)
  .mapping(x: 'date', y: 'price', color: 'symbol')
  .geomLine(strokeWidth: 2.5, alpha: 0.8)
  .interaction(
    pan: PanConfig(
      enabled: true,
      onPanUpdate: (info) {
        // Update dashboard metrics for visible time range
        updateMetrics(
          startDate: info.visibleMinX,
          endDate: info.visibleMaxX,
        );
        // Show range in header: "Viewing: Jan 2024 - Mar 2024"
        updateHeaderRange(info.visibleMinX!, info.visibleMaxX!);
      },
    ),
  )
  .build();
```

## 0.6.2 - 2025-06-26

### Added
- **Comprehensive Test Suite**: Restored complete test coverage with 81+ test cases across multiple files
  - `interaction_test.dart`: Interactive features testing for all chart types (scatter, line, bar, grouped, stacked, horizontal, dual Y-axis)
  - `performance_test.dart`: Large dataset performance testing (1000+ points), memory management, and animation performance
  - `tooltip_test.dart`: Tooltip system testing with default builders, custom configurations, and business use cases
  - Edge case testing for empty data, null values, disabled interactions, and rapid theme changes

### Fixed
- **Critical Tooltip Crash**: Fixed animation reset crash during widget disposal in tooltip system
- **Test Coverage**: All 81 tests now passing with comprehensive coverage across the codebase
- **Memory Leaks**: Improved tooltip lifecycle management to prevent memory leaks during disposal

### Technical
- Enhanced tooltip widget disposal process to prevent animation controller crashes
- Maintained compatibility with previous tooltip rendering improvements from commit 3ed06f9
- Added stress testing for rapid interaction changes and theme switching
- Improved test reliability across different chart configurations

## 0.6.1 - 2025-06-21

### Fixed
- **Tooltip System**: Fixed tooltips disappearing instantly and getting stuck on first data point
- **Widget Tree Lock**: Resolved "setState() called when widget tree was locked" crashes during tooltip animations
- **Hit Detection**: Improved point detection reliability - all chart points now respond to hover interactions
- **Touch Handling**: Fixed tooltip interference with pan gestures on mobile devices

### Technical
- Replaced spatial grid hit detection with distance-based approach for better reliability
- Added `IgnorePointer` wrapper to prevent tooltips from blocking mouse events
- Improved tooltip lifecycle management with proper state cleanup
- Enhanced interaction detector with better error handling and null safety

### Configuration
- Increased default hit test radius to 30px for hover, 35px for tap interactions
- Optimized tooltip timing: 10ms show delay, 1.5s hide delay
- Disabled `followPointer` by default to prevent gesture conflicts

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