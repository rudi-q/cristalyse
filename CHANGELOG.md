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