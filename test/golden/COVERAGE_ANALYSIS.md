# Visual Regression Test Coverage Analysis

This document analyzes the current test coverage against the cristalyse API documentation and example app to identify gaps and areas for improvement.

## Summary

**Current Status:** 39 tests covering core chart types and basic features
**Coverage Level:** ~70% of visually-testable features
**Major Gaps:** Gradients, custom formatters, advanced styling options

---

## ✅ Fully Covered Features

### Chart Types
- ✅ **Scatter plots** - All point shapes (circle, square, triangle), sizes, borders
- ✅ **Line charts** - All line styles (solid, dashed, dotted), stroke widths, multi-series
- ✅ **Bar charts** - Vertical/horizontal, grouped/stacked, rounded corners, borders
- ✅ **Area charts** - Filled/outline, transparency, multi-series
- ✅ **Pie charts** - Basic pie, donut, labels, percentages, exploded slices
- ✅ **Heat maps** - 4 color gradients, rounded cells, value display
- ✅ **Bubble charts** - Size encoding, labels
- ✅ **Progress bars** - All 7 styles (filled, striped, gradient, stacked, grouped, gauge, concentric)
- ✅ **Dual Y-axis charts** - Combined bar + line visualizations

### Themes
- ✅ **All 4 built-in themes** - Default, Dark, Solarized Light, Solarized Dark
- ✅ **Theme application** - Tested across all chart types

### Legends
- ✅ **All 8 positions** - Corner and edge positions
- ✅ **3 orientations** - Horizontal, vertical, auto
- ✅ **Multi-chart integration** - Works with themes

### Basic Features
- ✅ **Axis titles** - Custom X and Y axis labels
- ✅ **Custom bounds** - Non-zero baselines, negative ranges
- ✅ **Transparency** - Alpha values on geometries
- ✅ **Coordinate flipping** - `.coordFlip()` transformation
- ✅ **Borders** - Width and styling
- ✅ **Border radius** - Rounded corners on bars and cells
- ✅ **Multi-geometry charts** - Combined visualizations

---

## ⚠️ Partially Covered Features

### Progress Bars
**Covered:**
- Basic style variations (7 styles)
- Orientations (horizontal, vertical, circular)

**Missing:**
- ❌ Custom `segmentColors` parameter for stacked progress
- ❌ `startAngle`, `sweepAngle` customization for gauge style
- ❌ `labelFormatter` customization
- ❌ `showTicks`, `tickCount` variations for gauge

### Heat Maps
**Covered:**
- 4 preset gradient color scales
- Basic cell styling (rounded, spacing)
- Value display

**Missing:**
- ❌ `minValue`, `maxValue` customization
- ❌ `nullValueColor` handling
- ❌ `valueFormatter` customization
- ❌ `cellAspectRatio` variations
- ❌ Custom gradient arrays (beyond presets)

### Pie Charts
**Covered:**
- Basic variations (pie, donut, labels, percentages, exploded)

**Missing:**
- ❌ `labelRadius` customization
- ❌ `labelStyle` customization (fonts, colors)
- ❌ `explodeDistance` variations

### Legends
**Covered:**
- Positions and orientations

**Missing:**
- ❌ Custom `backgroundColor`
- ❌ Custom `textStyle`
- ❌ Custom `padding` and `spacing`
- ❌ `itemSpacing` parameter
- ❌ Symbol shapes (circle, square, line, auto)

---

## ❌ Major Missing Features

### 1. Gradient Features (HIGH PRIORITY)
**Status:** Not tested at all
**Examples exist:** Yes (`gradient_bar_example.dart`, `advanced_gradient_example.dart`)

Missing tests for:
- ❌ Linear gradients on bars (`.customPalette(categoryGradients: {...})`)
- ❌ Radial gradients
- ❌ Sweep gradients
- ❌ Gradient stops customization
- ❌ Mixed gradient types in single chart
- ❌ Gradients on scatter points

**Recommendation:** Add `test/golden/gradients_test.dart` with:
- Linear gradient bars (vertical and horizontal)
- Radial gradient scatter points
- Sweep gradient examples
- Mixed gradients in multi-series charts

### 2. Number Formatting & Custom Label Formatters (MEDIUM PRIORITY)
**Status:** Not tested
**Examples exist:** Yes (README shows `NumberFormat` usage)

Missing tests for:
- ❌ Currency formatting (`.scaleYContinuous(labels: NumberFormat.simpleCurrency().format)`)
- ❌ Compact notation (`.scaleYContinuous(labels: NumberFormat.compact().format)`)
- ❌ Custom formatters with units (e.g., `'${value}°C'`)
- ❌ Percentage formatting
- ❌ Locale-specific formatting

**Recommendation:** Add `test/golden/formatting_test.dart` with:
- Currency-formatted axes
- Compact number notation (1.2M, 5.6K)
- Custom unit labels
- Percentage displays

### 3. Custom Color Palettes (MEDIUM PRIORITY)
**Status:** Not tested
**API:** `.customPalette(categoryColors: {...})`

Missing tests for:
- ❌ Brand-specific color mapping
- ❌ Semantic colors (status, priority)
- ❌ Category override with custom colors
- ❌ Custom palette with legends

**Recommendation:** Add to `test/golden/themes_test.dart`:
- Custom palette bar charts
- Custom palette multi-series lines
- Custom palette with legend generation

### 4. Advanced Styling Options (LOW-MEDIUM PRIORITY)

#### Legend Styling
- ❌ Background colors and opacity
- ❌ Custom text styles (fonts, weights, sizes)
- ❌ Padding and spacing variations
- ❌ Symbol shape customization

#### Custom Theme Objects
- ❌ Fully custom `ChartTheme` objects (beyond built-ins)
- ❌ `.copyWith()` modifications
- ❌ Custom color palettes in themes
- ❌ Typography customization

### 5. Animation Variations (LOW PRIORITY)
**Note:** Static golden files won't capture animation differences well

Missing tests for:
- ❌ Custom curves (`Curves.elasticOut`, `Curves.easeInOutCubic`, etc.)
- ❌ Custom durations (fast vs slow animations)
- ❌ Staggered animations

**Recommendation:** Consider these lower priority since goldens are static snapshots

---

## 🚫 Non-Testable Features (For Golden Tests)

These features cannot be tested with static golden file comparisons:

### Interactive Features
- ❌ Tooltips (`.interaction(tooltip: TooltipConfig(...))`)
- ❌ Click handlers (`.interaction(click: ClickConfig(...))`)
- ❌ Pan/zoom (`.interaction(pan: PanConfig(...))`)
- ❌ Hover detection
- ❌ Touch interactions

**Why:** These require user interaction and runtime behavior testing.
**Alternative:** Unit tests and widget tests for interaction callbacks.

### Export Features
- ❌ SVG export (`.exportAsSvg()`)
- ❌ Export configuration

**Why:** Export is a separate operation, not a visual rendering feature.
**Alternative:** Integration tests for export functionality.

### Runtime Features
- ❌ Real-time data updates
- ❌ Data streaming
- ❌ Animation timing (only final frame is captured)

---

## 📊 Coverage Metrics

| Category | Features | Tested | Coverage |
|----------|----------|--------|----------|
| Chart Types | 9 types | 9 | 100% ✅ |
| Themes | 4 built-in | 4 | 100% ✅ |
| Geometries | ~15 variations | ~15 | 100% ✅ |
| Legends | 11 positions/orientations | 11 | 100% ✅ |
| **Gradients** | **4 types** | **0** | **0% ❌** |
| **Formatters** | **~5 types** | **0** | **0% ❌** |
| **Custom Palettes** | **1 API** | **0** | **0% ❌** |
| Styling Options | ~20 parameters | ~12 | ~60% ⚠️ |
| **OVERALL** | **~70 testable features** | **~50** | **~70%** |

---

## 🎯 Recommended Next Steps

### High Priority Additions

1. **Add `test/golden/gradients_test.dart`** (Critical gap)
   - Linear gradients on bars
   - Radial gradients on scatter points
   - Sweep gradients
   - Mixed gradient types
   - **Estimated:** 8-10 new tests

2. **Add `test/golden/formatting_test.dart`** (High value)
   - Currency formatting
   - Compact notation
   - Custom unit labels
   - Percentage formatting
   - **Estimated:** 6-8 new tests

3. **Enhance `test/golden/legends_test.dart`** (Easy win)
   - Add legend styling variations
   - Symbol shape tests
   - Custom padding/spacing
   - **Estimated:** 4-6 new tests

### Medium Priority Enhancements

4. **Add custom palette tests to `themes_test.dart`**
   - Brand-specific colors
   - Semantic color mapping
   - **Estimated:** 3-4 new tests

5. **Enhance parameter coverage in existing tests**
   - Progress bar advanced parameters
   - Heat map advanced parameters
   - Pie chart styling parameters
   - **Estimated:** 6-8 additional scenarios

### Total Potential Coverage
With recommended additions: **~90% of visually-testable features** (65-70 tests)

---

## 💡 Testing Best Practices

### What TO Test
✅ Visual rendering variations
✅ Layout and positioning
✅ Color, size, and shape variations
✅ Style and theme applications
✅ Static snapshots of animations (final frame)

### What NOT to Test
❌ Interactive behavior (use widget tests)
❌ Animation timing (use integration tests)
❌ Runtime data updates (use unit tests)
❌ Export functionality (use integration tests)

---

## 📝 Conclusion

The current test suite provides **solid baseline coverage** of core chart types and basic features. The main gaps are:

1. **Gradients** - Zero coverage of a significant visual feature
2. **Formatters** - Missing professional number formatting tests
3. **Advanced styling** - Partial coverage of customization options

**Impact of Gaps:**
- ⚠️ Gradient changes could break undetected (used in example app)
- ⚠️ Number formatting regressions won't be caught
- ℹ️ Advanced styling options have lower usage but should be tested

**Recommendation:** Add gradients and formatting tests before refactoring AnimatedChartPainter to achieve ~90% coverage of critical visual features.
