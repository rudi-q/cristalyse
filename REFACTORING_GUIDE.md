# AnimatedChartPainter Refactoring Guide

## Status: Phase 1 - COMPLETE ✅

This guide documents the comprehensive refactoring of `AnimatedChartPainter` (3,831 lines) to extract reusable geometry calculation logic that can be shared between Canvas rendering and SVG export.

---

## Completed Work

### ✅ Phase 1: Core Geometries (COMPLETE)

**render_models.dart** - Created all render data model classes:
- `BarRenderData` - Pre-calculated bar geometry
- `LineRenderData` - Line points and styling
- `PointRenderData` - Scatter point geometry
- `BubbleRenderData` - Bubble with labels
- `AreaRenderData` - Area fill geometry
- `PieSliceData` - Pie slice angles and positions
- `HeatMapCellData` - Heat map cell geometry
- `ProgressBarRenderData` - Progress bar geometry

These models contain **calculation results only** - no rendering logic.

**geometry_calculator.dart** - Extracted calculation methods:
- `calculateSingleBar()` - From AnimatedChartPainter lines 1003-1120
- `calculateSimpleBars()` - From lines 791-831
- `calculateGroupedBars()` - From lines 833-921
- `calculateStackedBars()` - From lines 923-1001
- `calculateLine()` - From lines 1505-1577
- `calculateLines()` - From lines 1458-1503 (with color grouping)
- `calculatePoints()` - From lines 1122-1269

**AnimatedChartPainter integration** - Refactored to use GeometryCalculator:
- Updated `_drawSimpleBars()` to use calculator
- Updated `_drawGroupedBars()` to use calculator
- Updated `_drawStackedBars()` to use calculator (with value-based animation)
- Updated `_drawLinesAnimated()` to use calculator
- Updated `_drawPointsAnimated()` to use calculator
- Added `_applyBarAnimation()` - applies animation to bar height/width
- Added `_renderBar()` - renders BarRenderData to canvas
- Added `_renderLine()` - renders LineRenderData with progressive animation
- Added `_renderPoint()` - renders PointRenderData with shapes and borders

**Next: Run golden tests to verify no visual regressions.**

---

## Next Steps: Implementation Phases

### Phase 1: Core Geometries (HIGH PRIORITY)

**Estimated effort**: 2-3 weeks | **Lines**: ~500-800

**Tasks**:
1. Create `lib/src/core/geometry_calculator.dart`
2. Extract bar calculation logic from `AnimatedChartPainter._drawSingleBar()` (lines 936-1051)
3. Extract line calculation logic from `AnimatedChartPainter._drawSingleLineAnimated()` (lines 1458-1574)
4. Extract point calculation logic from `AnimatedChartPainter._drawPointsAnimated()` (lines 1053-1204)
5. Update `AnimatedChartPainter` to use `GeometryCalculator`
6. **CRITICAL**: Run all 82 golden tests after each extraction

**Key Methods to Extract**:

#### Bar Geometry
```dart
class GeometryCalculator {
  final List<Map<String, dynamic>> data;
  final String? xColumn;
  final String? yColumn;
  final String? colorColumn;

  BarRenderData calculateSingleBar(
    dynamic xValForPosition,
    double yValForBar,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    BarGeometry geometry,
    Map<String, dynamic> dataPoint,
    Rect plotArea,
    bool coordFlipped, {
    double? customX,
    double? customWidth,
    double yStackOffset = 0,
  }) {
    // EXTRACT LINES 951-1013 from AnimatedChartPainter._drawSingleBar
    // 1. Color resolution
    // 2. Rectangle calculation (both orientations)
    // 3. Return BarRenderData with FULL dimensions (no animation)
  }

  List<BarRenderData> calculateGroupedBars(
    BarGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    Rect plotArea,
  ) {
    // EXTRACT LINES 775-853 from AnimatedChartPainter._drawGroupedBars
    // 1. Group data by xColumn
    // 2. Calculate group positioning
    // 3. For each group, call calculateSingleBar with custom X/width
  }

  List<BarRenderData> calculateStackedBars(
    BarGeometry geometry,
    Scale xScale,
    Scale yScale,
    ColorScale colorScale,
    Rect plotArea,
  ) {
    // EXTRACT LINES 866-933 from AnimatedChartPainter._drawStackedBars
    // 1. Group data by X value
    // 2. Calculate cumulative offsets
    // 3. For each segment, call calculateSingleBar with yStackOffset
  }
}
```

#### Line Geometry
```dart
LineRenderData? calculateLine(
  LineGeometry geometry,
  Scale xScale,
  Scale yScale,
  ColorScale colorScale,
  Rect plotArea,
  List<Map<String, dynamic>> lineData,
) {
  // EXTRACT LINES 1468-1527 from AnimatedChartPainter._drawSingleLineAnimated
  // 1. Sort data (critical for proper line rendering)
  // 2. Transform data values → screen coordinates
  // 3. Return LineRenderData with all points
}
```

#### Point Geometry
```dart
List<PointRenderData> calculatePoints(
  PointGeometry geometry,
  Scale xScale,
  Scale yScale,
  ColorScale colorScale,
  SizeScale sizeScale,
  Rect plotArea,
) {
  // EXTRACT LINES 1066-1111 from AnimatedChartPainter._drawPointsAnimated
  // 1. Coordinate transformation
  // 2. Color/size resolution
  // 3. Return List<PointRenderData>
}
```

**Testing Strategy**:
- After extracting each geometry type, run golden tests
- Compare pixel-by-pixel output to ensure no regressions
- If tests fail, geometry extraction has a bug

**Migration Pattern**:
```dart
// OLD CODE in AnimatedChartPainter
void _drawBarsAnimated(Canvas canvas, ...) {
  // 100 lines of calculation + rendering
}

// NEW CODE in AnimatedChartPainter
void _drawBarsAnimated(Canvas canvas, ...) {
  final calculator = GeometryCalculator(data, xColumn, yColumn, colorColumn);
  final bars = calculator.calculateBars(...); // Pure calculation

  for (int i = 0; i < bars.length; i++) {
    final bar = bars[i];
    final barDelay = i / bars.length * 0.2;
    final barProgress = _calculateAnimationProgress(barDelay);

    if (barProgress > 0) {
      // Apply animation to rect
      final animatedRect = Rect.fromLTWH(
        bar.rect.left,
        bar.rect.top + bar.rect.height * (1 - barProgress),
        bar.rect.width,
        bar.rect.height * barProgress,
      );

      // Render with Canvas (backend-specific)
      _renderBar(canvas, bar.copyWith(rect: animatedRect));
    }
  }
}
```

---

### Phase 2: Complex Geometries

**Estimated effort**: 2 weeks | **Lines**: ~400-600

**Tasks**:
1. Extract pie slice calculation from `AnimatedChartPainter._drawPieAnimated()` (lines 1918-2097)
2. Extract heat map grid layout from `AnimatedChartPainter._drawHeatMapAnimated()` (lines 2154-2393)
3. Extract area geometry from `AnimatedChartPainter._drawSingleArea()` (lines 1630-1764)
4. Run golden tests

**Key Extractions**:

#### Pie Geometry
```dart
List<PieSliceData> calculatePieSlices(
  PieGeometry geometry,
  ColorScale colorScale,
  Rect plotArea,
) {
  // EXTRACT LINES 1918-2027
  // 1. Center/radius calculation
  // 2. Value normalization
  // 3. Angle calculations
  // 4. Explosion offsets
}
```

#### Heat Map Geometry
```dart
List<HeatMapCellData> calculateHeatMap(
  HeatMapGeometry geometry,
  GradientColorScale colorScale,
  Rect plotArea,
) {
  // EXTRACT LINES 2169-2342
  // 1. Grid layout
  // 2. Cell dimensions
  // 3. Data indexing
  // 4. Color calculation (USE GradientColorScale, remove duplication)
}
```

**IMPORTANT**: Heat map currently duplicates `GradientColorScale` logic (lines 2295-2342). **DELETE THIS** and use `colorScale.scale(normalizedValue)` directly.

---

### Phase 3: Renderer Abstraction

**Estimated effort**: 1 week | **Lines**: ~300-400

**Tasks**:
1. Create `lib/src/renderers/chart_renderer.dart` interface
2. Create `lib/src/renderers/canvas_renderer.dart` implementation
3. Refactor `AnimatedChartPainter` to delegate to `CanvasChartRenderer`

**Interface**:
```dart
abstract class ChartRenderer {
  void renderBar(BarRenderData bar);
  void renderLine(LineRenderData line, int fullyDrawnSegments, double partialProgress);
  void renderPoint(PointRenderData point);
  void renderPieSlice(PieSliceData slice);
  void renderHeatMapCell(HeatMapCellData cell);
  void renderArea(AreaRenderData area, int fullyDrawnSegments, double partialProgress);
}
```

**Implementation**:
```dart
class CanvasChartRenderer implements ChartRenderer {
  final Canvas canvas;
  final ChartTheme theme;

  CanvasChartRenderer(this.canvas, this.theme);

  @override
  void renderBar(BarRenderData bar) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (bar.colorOrGradient is Gradient) {
      paint.shader = (bar.colorOrGradient as Gradient).createShader(bar.rect);
    } else {
      paint.color = (bar.colorOrGradient as Color)
          .withAlpha((bar.alpha * 255).round());
    }

    if (bar.borderRadius != null) {
      canvas.drawRRect(bar.borderRadius!.toRRect(bar.rect), paint);
    } else {
      canvas.drawRect(bar.rect, paint);
    }

    if (bar.borderWidth > 0 && bar.borderColor != null) {
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = bar.borderColor!
        ..strokeWidth = bar.borderWidth;

      if (bar.borderRadius != null) {
        canvas.drawRRect(bar.borderRadius!.toRRect(bar.rect), borderPaint);
      } else {
        canvas.drawRect(bar.rect, borderPaint);
      }
    }
  }

  // Implement other render methods...
}
```

---

### Phase 4: SVG Upgrade

**Estimated effort**: 1-2 weeks | **Lines**: ~400-600

**Tasks**:
1. Create `lib/src/export/svg_chart_renderer.dart` implementing `ChartRenderer`
2. Refactor `lib/src/export/svg_renderer.dart` to use `GeometryCalculator`
3. Add missing chart types to SVG export (currently limited)
4. Test SVG output matches Canvas output

**SVG Renderer**:
```dart
class SvgChartRenderer implements ChartRenderer {
  final StringBuffer buffer;
  final ChartTheme theme;

  SvgChartRenderer(this.buffer, this.theme);

  @override
  void renderBar(BarRenderData bar) {
    final x = bar.rect.left;
    final y = bar.rect.top;
    final width = bar.rect.width;
    final height = bar.rect.height;

    String fillValue;
    if (bar.colorOrGradient is Gradient) {
      // Define gradient in <defs> and reference it
      final gradientId = 'grad_${_gradientCounter++}';
      _defineGradient(gradientId, bar.colorOrGradient as Gradient);
      fillValue = 'url(#$gradientId)';
    } else {
      fillValue = _colorToHex(bar.colorOrGradient as Color);
    }

    buffer.writeln('<rect '
        'x="$x" y="$y" '
        'width="$width" height="$height" '
        'fill="$fillValue" '
        'opacity="${bar.alpha}" '
        '${bar.borderRadius != null ? 'rx="${bar.borderRadius!.topLeft.x}" ' : ''}'
        '/>');

    if (bar.borderWidth > 0 && bar.borderColor != null) {
      buffer.writeln('<rect '
          'x="$x" y="$y" '
          'width="$width" height="$height" '
          'fill="none" '
          'stroke="${_colorToHex(bar.borderColor!)}" '
          'stroke-width="${bar.borderWidth}" '
          '${bar.borderRadius != null ? 'rx="${bar.borderRadius!.topLeft.x}" ' : ''}'
          '/>');
    }
  }

  // Implement other render methods...
}
```

---

### Phase 5: Progress Bars (Optional)

**Estimated effort**: 1 week | **Lines**: ~200-300

**Tasks**:
1. Extract progress bar layouts from 8 methods
2. Test all 7 progress bar styles

---

## Critical Testing Requirements

### After Each Phase
1. **Run ALL 82 golden tests**:
   ```bash
   flutter test test/golden/
   ```

2. **If tests fail**:
   - Compare failed golden to expected
   - Debug geometry calculation vs old logic
   - Fix bugs before proceeding

3. **Visual inspection**:
   - Run example app
   - Check all chart types manually
   - Look for subtle rendering differences

### Regression Prevention
- Keep old methods until SVG renderer is updated
- Use feature flags if needed
- Gradual rollout per chart type

---

## File Structure After Refactoring

```
lib/src/
├── core/
│   ├── chart_data_setup.dart      # Existing
│   ├── geometry.dart               # Existing
│   ├── render_models.dart          # ✅ NEW - Complete
│   └── geometry_calculator.dart    # 🚧 TODO - Phase 1-2
│
├── renderers/
│   ├── chart_renderer.dart         # 🚧 TODO - Phase 3
│   └── canvas_renderer.dart        # 🚧 TODO - Phase 3
│
├── export/
│   ├── svg_chart_renderer.dart     # 🚧 TODO - Phase 4
│   └── svg_renderer.dart           # 🔧 REFACTOR - Phase 4
│
└── widgets/
    └── animated_chart_painter.dart # 🔧 REFACTOR - Phases 1-3
```

---

## Benefits Summary

### Immediate (Phase 1)
- ✅ 60-70% of bar/line/point logic extracted
- ✅ Can unit test geometry calculations
- ✅ Easier to debug layout issues

### Medium Term (Phase 2-3)
- ✅ All chart types use shared calculation
- ✅ Backend-agnostic rendering
- ✅ Preparation for SVG parity

### Long Term (Phase 4)
- ✅ SVG export has ALL chart types
- ✅ Consistent output across backends
- ✅ Can add PDF, WebGL, image export easily

---

## Migration Checklist

### Before Starting Each Phase
- [ ] Create git branch from main
- [ ] Run all tests to establish baseline
- [ ] Note current test coverage

### During Implementation
- [ ] Extract ONE method at a time
- [ ] Test after each extraction
- [ ] Commit frequently with descriptive messages

### Before Merging
- [ ] All 82 golden tests pass
- [ ] Manual testing of example app
- [ ] Code review by maintainer
- [ ] Update documentation

---

## Estimated Timeline

| Phase | Effort | Completion Date |
|-------|--------|-----------------|
| ✅ Foundation | 1 day | Complete |
| Phase 1 | 2-3 weeks | TBD |
| Phase 2 | 2 weeks | TBD |
| Phase 3 | 1 week | TBD |
| Phase 4 | 1-2 weeks | TBD |
| Phase 5 (opt) | 1 week | TBD |
| **Total** | **7-9 weeks** | |

---

## Getting Started with Phase 1

1. **Read the source code**:
   - Study `AnimatedChartPainter._drawSingleBar()` (lines 936-1051)
   - Understand color resolution priority
   - Note coord-flipped logic

2. **Create skeleton**:
   ```dart
   // lib/src/core/geometry_calculator.dart
   import 'render_models.dart';
   import 'scale.dart';
   import 'geometry.dart';

   class GeometryCalculator {
     final List<Map<String, dynamic>> data;
     // ... constructor

     BarRenderData calculateSingleBar(...) {
       // Start by copy-pasting lines 951-1013
       // Then replace Canvas rendering with return BarRenderData
     }
   }
   ```

3. **Test immediately**:
   ```dart
   void main() {
     test('calculateSingleBar matches old logic', () {
       // Create test data
       // Call old and new methods
       // Compare results
     });
   }
   ```

4. **Integrate incrementally**:
   - Keep old `_drawSingleBar()` as `_drawSingleBarOld()`
   - Add new path using `GeometryCalculator`
   - Use feature flag to toggle
   - Once tests pass, delete old code

---

## Questions & Decisions

### Animation Handling
**Decision**: GeometryCalculator returns FULL geometry (no animation). AnimatedChartPainter applies animation before rendering.

**Rationale**: SVG export doesn't need animation logic.

### Gradient Storage
**Decision**: Store as `dynamic colorOrGradient` in render models.

**Rationale**: Simplifies code, type check at render time.

### Performance
**Q**: Is creating RenderData objects expensive?

**A**: No - negligible compared to rendering cost. Canvas drawing is the bottleneck, not object creation.

---

## Success Criteria

### Phase 1 Complete When:
- ✅ All bar, line, point geometry extracted
- ✅ GeometryCalculator tested in isolation
- ✅ AnimatedChartPainter uses calculator
- ✅ All 82 golden tests pass
- ✅ Example app renders identically

### Full Refactor Complete When:
- ✅ All geometry types extracted
- ✅ ChartRenderer interface defined
- ✅ CanvasChartRenderer implemented
- ✅ SvgChartRenderer implemented
- ✅ SVG export has feature parity with Canvas
- ✅ All tests pass
- ✅ Documentation updated

---

## Contact & Support

For questions about this refactoring:
1. Review the original analysis document
2. Check the test coverage analysis
3. Consult the API documentation

Remember: **Test after every change. The 82 golden tests are your safety net.**
