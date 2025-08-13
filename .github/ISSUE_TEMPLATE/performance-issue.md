---
name: Performance issue
about: Report slow rendering, memory leaks, or performance degradation
title: "[PERFORMANCE_ISSUE]"
labels: "Performance \U0001F685"
assignees: ''

---

**Describe the performance issue**
A clear and concise description of what performance problem you're experiencing.

**To Reproduce**
Steps to reproduce the performance issue:
1. Create chart with '...' data points
2. Add geometry '....'
3. Perform action '....'
4. Observe slow performance/high memory usage

**Code Example**
```dart
// Minimal code that demonstrates the performance issue
CristalyseChart()
  .data(largeDataset) // specify approximate size
  .mapping(x: 'timestamp', y: 'value')
  .geomLine()
  .build()
```

**Expected performance**
A clear and concise description of what performance you expected (e.g., smooth 60fps, low memory usage).

**Actual performance**
What you're experiencing instead (e.g., choppy animations, high memory usage, slow rendering).

**Performance measurements**
If you have specific measurements:
- Render time: [e.g. 2-3 seconds]
- Memory usage: [e.g. 500MB+]
- Frame rate: [e.g. 15fps during animations]
- Flutter DevTools insights: [attach screenshots if available]

**Flutter Environment (please complete the following information):**
 - Cristalyse Version: [e.g. 1.1.0]
 - Flutter Version: [e.g. 3.19.0]
 - Dart Version: [e.g. 3.3.0]
 - Build Mode: [Debug/Profile/Release]

**Platform (please complete the following information):**
 - OS: [e.g. iOS, Android, Web, Windows, macOS]
 - Version: [e.g. iOS 17.0, Android 14]
 - Device: [e.g. iPhone 15, Pixel 8, MacBook Pro M3]
 - Device specs: [RAM, CPU if relevant to performance]

**Dataset Information:**
 - Number of data points: [e.g. 50,000 rows]
 - Data types: [e.g. numeric time series, categorical]
 - Update frequency: [e.g. static, real-time updates every 100ms]
 - Chart complexity: [e.g. single line, 20 overlapping series]

**Additional context**
Add any other context about the performance issue here. Include comparisons with other charting libraries if relevant.
