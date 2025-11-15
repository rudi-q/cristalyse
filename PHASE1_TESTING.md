# Phase 1 Testing Instructions

## ⚠️ CRITICAL: Golden Tests Required

Phase 1 of the AnimatedChartPainter refactoring is complete, but **MUST BE TESTED** before proceeding.

---

## What Was Changed

**Core geometry calculations** for bars, lines, and points have been extracted from `AnimatedChartPainter` into `GeometryCalculator`:

### Files Modified:
1. **lib/src/core/render_models.dart** (NEW)
   - All RenderData classes (BarRenderData, LineRenderData, PointRenderData, etc.)

2. **lib/src/core/geometry_calculator.dart** (NEW)
   - All calculation methods for bars, lines, points
   - ~540 lines of extracted geometry logic

3. **lib/src/widgets/animated_chart_painter.dart** (MODIFIED)
   - Refactored to use GeometryCalculator
   - Added renderer methods (_renderBar, _renderLine, _renderPoint)
   - Net change: +331 lines, -240 lines

### What Should NOT Have Changed:
- ❌ Visual output (pixels should be identical)
- ❌ Animation behavior
- ❌ Chart rendering for any chart type

---

## Required Testing

### 1. Run All 82 Golden Tests

```bash
flutter test test/golden/
```

**Expected result:** ✅ All 82 tests PASS

If ANY test fails:
- **DO NOT UPDATE GOLDENS** (unless you're certain the change is intentional)
- Compare the failed golden to the expected output
- The failure indicates a bug in the refactoring
- Revert the changes and investigate

### 2. Visual Inspection

Run the example app and manually check:

```bash
cd example
flutter run
```

Check these chart types specifically:
- ✅ Simple bar charts
- ✅ Grouped bar charts
- ✅ Stacked bar charts
- ✅ Scatter plots (points)
- ✅ Line charts (single and multi-series)
- ✅ Charts with gradients
- ✅ Charts with custom colors
- ✅ Charts with borders and rounded corners

### 3. Animation Verification

Verify animations still work correctly:
- Bars should animate from bottom-up (or left-right if flipped)
- Lines should draw segment-by-segment
- Points should grow from small to full size
- Stacked bars should build up progressively

---

## If Tests Pass ✅

Proceed to Phase 2:
- Extract pie chart geometry
- Extract heat map geometry
- Extract area chart geometry

See `REFACTORING_GUIDE.md` for Phase 2 details.

---

## If Tests Fail ❌

### Debugging Steps:

1. **Check which chart types failed:**
   - Bar tests? → Bug in `calculateSingleBar()` or bar rendering
   - Line tests? → Bug in `calculateLine()` or line rendering
   - Point tests? → Bug in `calculatePoints()` or point rendering

2. **Compare the logic:**
   - Open `lib/src/core/geometry_calculator.dart`
   - Open `lib/src/widgets/animated_chart_painter.dart` (old version in git)
   - Verify the extracted logic matches exactly

3. **Common issues:**
   - Coordinate offsets (plotArea.left/top) - should be included in calculator
   - Animation progress - should be applied AFTER calculation
   - Color resolution priority - geometry.color > colorScale > theme
   - Grouped bar positioning - customX and customWidth handling

4. **Revert if needed:**
   ```bash
   git reset --hard HEAD~3  # Revert last 3 commits
   ```

---

## Test Coverage

Phase 1 affects these test files:
- ✅ `test/golden/chart_types_test.dart` - Bar, scatter, line charts
- ✅ `test/golden/features_test.dart` - Stacked and grouped bars
- ✅ `test/golden/gradients_test.dart` - Bars and points with gradients
- ✅ `test/golden/custom_palettes_test.dart` - Custom colors
- ✅ `test/golden/advanced_styling_test.dart` - Borders, corners

**Total tests affected:** ~50 out of 82

---

## What's NOT Affected

Phase 1 does NOT change:
- ❌ Pie charts (Phase 2)
- ❌ Heat maps (Phase 2)
- ❌ Area charts (Phase 2)
- ❌ Bubble charts (Phase 2)
- ❌ Progress bars (Phase 5, optional)
- ❌ Axes, legends, titles (never)
- ❌ SVG export (Phase 4)

---

## Success Criteria

Phase 1 is successful when:
1. ✅ All 82 golden tests pass
2. ✅ Example app renders identically
3. ✅ Animations work correctly
4. ✅ No performance regression

**Only then** should you proceed to Phase 2.

---

## Performance Note

The refactoring may introduce a **small performance overhead** due to:
- Creating RenderData objects
- Extra method calls

This is expected and acceptable. The benefits (testability, SVG export) outweigh the negligible cost.

If you notice significant performance issues (>10% slower), investigate the calculator instantiation - it's currently created per draw method, could be cached.
