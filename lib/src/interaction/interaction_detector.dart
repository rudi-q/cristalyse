import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/scale.dart';
import 'chart_interactions.dart';

/// Efficient spatial indexing for chart interaction detection
class InteractionDetector {
  final List<Map<String, dynamic>> data;
  final List<Geometry> geometries;
  final Scale xScale;
  final Scale yScale;
  final Scale? y2Scale;
  final Rect plotArea;
  final String? xColumn;
  final String? yColumn;
  final String? y2Column;
  final String? colorColumn;
  final bool coordFlipped;

  // Simple list of all indexed points for reliable detection
  final List<_IndexedDataPoint> _allPoints = [];
  bool _indexBuilt = false;

  InteractionDetector({
    required this.data,
    required this.geometries,
    required this.xScale,
    required this.yScale,
    this.y2Scale,
    required this.plotArea,
    this.xColumn,
    this.yColumn,
    this.y2Column,
    this.colorColumn,
    this.coordFlipped = false,
  });

  /// Find the closest data point to the given screen coordinates
  DataPointInfo? detectPoint(
    Offset screenPosition, {
    double maxDistance = 20.0,
  }) {
    if (!_indexBuilt) {
      _buildIndex();
    }

    _IndexedDataPoint? closest;
    double closestDistance = maxDistance;

    // Simple brute force approach - more reliable than spatial grid
    for (final point in _allPoints) {
      final distance = _calculateDistance(screenPosition, point);
      if (distance < closestDistance) {
        closest = point;
        closestDistance = distance;
      }
    }

    if (closest == null) return null;

    return DataPointInfo(
      data: closest.data,
      screenPosition: closest.screenPosition,
      dataIndex: closest.dataIndex,
      seriesName: closest.seriesName,
      xValue: closest.xValue,
      yValue: closest.yValue,
      color: closest.color,
    );
  }

  /// Find all data points at a given X position (for axis-based tooltips)
  /// 
  /// This is perfect for line and bar charts where you want to show all
  /// series values at a particular X coordinate.
  /// 
  /// Returns a list of [DataPointInfo] sorted by Y value (top to bottom).
  List<DataPointInfo> detectPointsByXPosition(
    Offset screenPosition, {
    double xTolerance = 15.0,
  }) {
    if (!_indexBuilt) {
      _buildIndex();
    }

    final List<_IndexedDataPoint> pointsAtX = [];

    // Find all points within X tolerance
    for (final point in _allPoints) {
      final xDistance = (screenPosition.dx - point.screenPosition.dx).abs();
      
      if (xDistance <= xTolerance) {
        // Within X tolerance - include this point
        pointsAtX.add(point);
      }
    }

    // If no points found, return empty list
    if (pointsAtX.isEmpty) return [];

    // Sort by Y position (top to bottom) for consistent ordering
    pointsAtX.sort((a, b) => a.screenPosition.dy.compareTo(b.screenPosition.dy));

    // Convert to DataPointInfo list
    return pointsAtX.map((point) => DataPointInfo(
      data: point.data,
      screenPosition: point.screenPosition,
      dataIndex: point.dataIndex,
      seriesName: point.seriesName,
      xValue: point.xValue,
      yValue: point.yValue,
      color: point.color,
    )).toList();
  }

  /// Build index of all interactive points
  void _buildIndex() {
    _allPoints.clear();

    for (int i = 0; i < data.length; i++) {
      final point = data[i];

      for (final geometry in geometries) {
        if (!geometry.interactive) continue;

        final indexedPoint = _createIndexedPoint(point, i, geometry);
        if (indexedPoint != null) {
          _allPoints.add(indexedPoint);
        }
      }
    }

    debugPrint("Built interaction index with ${_allPoints.length} points");
    _indexBuilt = true;
  }

  /// Create indexed point for a given data point and geometry
  _IndexedDataPoint? _createIndexedPoint(
    Map<String, dynamic> point,
    int index,
    Geometry geometry,
  ) {
    final useY2 = geometry.yAxis == YAxis.secondary;
    final yCol = useY2 ? y2Column : yColumn;
    final activeYScale = useY2 ? (y2Scale ?? yScale) : yScale;

    dynamic xValue = point[xColumn];
    dynamic yValue = point[yCol];

    if (xValue == null || yValue == null) return null;

    // Calculate screen position based on coordinate system
    Offset? screenPosition = _calculateScreenPosition(
      xValue,
      yValue,
      xScale,
      activeYScale,
    );

    if (screenPosition == null) return null;

    // Skip points outside plot area (with some tolerance)
    final tolerance = 10.0;
    final expandedPlotArea = plotArea.inflate(tolerance);
    if (!expandedPlotArea.contains(screenPosition)) {
      return null;
    }

    return _IndexedDataPoint(
      data: point,
      dataIndex: index,
      screenPosition: screenPosition,
      geometry: geometry,
      xValue: xValue,
      yValue: yValue,
      seriesName: colorColumn != null ? point[colorColumn]?.toString() : null,
      color: _getPointColor(point, geometry),
    );
  }

  /// Calculate screen position for given data values
  Offset? _calculateScreenPosition(
    dynamic xValue,
    dynamic yValue,
    Scale xScale,
    Scale yScale,
  ) {
    try {
      if (coordFlipped) {
        // Horizontal charts: X becomes Y, Y becomes X
        final numYValue = _getNumericValue(yValue);
        if (numYValue == null) return null;
        final screenX = plotArea.left + yScale.scale(numYValue);

        double screenY;
        if (xScale is OrdinalScale) {
          final ordinalScale = xScale;
          screenY = plotArea.top + ordinalScale.bandCenter(xValue);
        } else {
          final numXValue = _getNumericValue(xValue);
          if (numXValue == null) return null;
          screenY = plotArea.top + xScale.scale(numXValue);
        }
        return Offset(screenX, screenY);
      } else {
        // Normal charts
        double screenX;
        if (xScale is OrdinalScale) {
          final ordinalScale = xScale;
          screenX = plotArea.left + ordinalScale.bandCenter(xValue);
        } else {
          final numXValue = _getNumericValue(xValue);
          if (numXValue == null) return null;
          screenX = plotArea.left + xScale.scale(numXValue);
        }

        final numYValue = _getNumericValue(yValue);
        if (numYValue == null) return null;
        final screenY = plotArea.top + yScale.scale(numYValue);
        return Offset(screenX, screenY);
      }
    } catch (e) {
      debugPrint("Error calculating screen position: $e");
      return null;
    }
  }

  /// Calculate distance between screen position and data point
  double _calculateDistance(Offset screenPos, _IndexedDataPoint point) {
    final geometry = point.geometry;

    if (geometry is PointGeometry) {
      return _distanceToPoint(screenPos, point.screenPosition);
    } else if (geometry is LineGeometry) {
      // For lines, treat each point as a circle with larger radius
      return _distanceToPoint(screenPos, point.screenPosition);
    } else if (geometry is BarGeometry) {
      return _distanceToBar(screenPos, point);
    }

    return double.infinity;
  }

  /// Distance to point (circle)
  double _distanceToPoint(Offset screenPos, Offset pointPos) {
    final dx = screenPos.dx - pointPos.dx;
    final dy = screenPos.dy - pointPos.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Distance to bar rectangle
  double _distanceToBar(Offset screenPos, _IndexedDataPoint point) {
    // Create approximate bar bounds
    Rect barBounds;

    if (coordFlipped) {
      // Horizontal bar
      final height = 30.0; // Generous bar height for hit testing
      barBounds = Rect.fromLTWH(
        plotArea.left,
        point.screenPosition.dy - height / 2,
        point.screenPosition.dx - plotArea.left,
        height,
      );
    } else {
      // Vertical bar
      final width = 30.0; // Generous bar width for hit testing
      barBounds = Rect.fromLTWH(
        point.screenPosition.dx - width / 2,
        point.screenPosition.dy,
        width,
        plotArea.bottom - point.screenPosition.dy,
      );
    }

    if (barBounds.contains(screenPos)) {
      return 0.0; // Inside bar
    }

    // Distance to closest edge
    final dx = math.max(
      0,
      math.max(barBounds.left - screenPos.dx, screenPos.dx - barBounds.right),
    );
    final dy = math.max(
      0,
      math.max(barBounds.top - screenPos.dy, screenPos.dy - barBounds.bottom),
    );
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Get color for a data point
  Color? _getPointColor(Map<String, dynamic> point, Geometry geometry) {
    if (geometry is PointGeometry && geometry.color != null) {
      return geometry.color;
    } else if (geometry is LineGeometry && geometry.color != null) {
      return geometry.color;
    } else if (geometry is BarGeometry && geometry.color != null) {
      return geometry.color;
    }

    return Colors.blue; // Default
  }

  /// Convert numeric value from dynamic
  double? _getNumericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Invalidate index when data changes
  void invalidate() {
    _indexBuilt = false;
    _allPoints.clear();
  }
}

/// Internal class for indexed points
class _IndexedDataPoint {
  final Map<String, dynamic> data;
  final int dataIndex;
  final Offset screenPosition;
  final Geometry geometry;
  final dynamic xValue;
  final dynamic yValue;
  final String? seriesName;
  final Color? color;

  const _IndexedDataPoint({
    required this.data,
    required this.dataIndex,
    required this.screenPosition,
    required this.geometry,
    this.xValue,
    this.yValue,
    this.seriesName,
    this.color,
  });

  @override
  String toString() {
    return '_IndexedDataPoint(data: $data, position: $screenPosition)';
  }
}
