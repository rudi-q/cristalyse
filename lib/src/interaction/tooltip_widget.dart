import 'dart:async';

import 'package:flutter/material.dart';

import 'chart_interactions.dart';

/// Abstract controller for managing the tooltip visibility.
abstract class TooltipController {
  /// Hides the tooltip.
  void hideTooltip();

  /// Shows the tooltip for a given data point at a specific position.
  void showTooltip(DataPointInfo point, Offset position);

  /// Shows the tooltip for multiple data points (axis mode)
  void showMultiPointTooltip(List<DataPointInfo> points, Offset position);
}

/// Tooltip overlay widget for chart interactions
class ChartTooltipOverlay extends StatefulWidget {
  final Widget child;
  final TooltipConfig config;
  final TooltipBuilder? tooltipBuilder;

  const ChartTooltipOverlay({
    super.key,
    required this.child,
    required this.config,
    this.tooltipBuilder,
  });

  @override
  State<ChartTooltipOverlay> createState() => _ChartTooltipOverlayState();
}

class _ChartTooltipOverlayState extends State<ChartTooltipOverlay>
    with SingleTickerProviderStateMixin
    implements TooltipController {
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  DataPointInfo? _currentPoint;
  List<DataPointInfo>? _currentPoints; // For multi-point tooltips
  Offset? _currentPosition;
  bool _isVisible = false;
  bool _shouldShow = false; // Track intended state
  bool _isMultiPoint = false; // Track if showing multi-point tooltip

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    // Cancel timers first
    _showTimer?.cancel();
    _hideTimer?.cancel();

    // Remove overlay without animation reset to avoid widget tree lock
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isVisible = false;

    // Dispose animation controller last
    _animationController.dispose();
    super.dispose();
  }

  /// Show tooltip for a data point
  @override
  void showTooltip(DataPointInfo point, Offset position) {
    _showTooltipInternal(
      singlePoint: point,
      position: position,
      isMultiPoint: false,
    );
  }

  /// Show tooltip for multiple data points (axis mode)
  @override
  void showMultiPointTooltip(List<DataPointInfo> points, Offset position) {
    _showTooltipInternal(
      multiPoints: points,
      position: position,
      isMultiPoint: true,
    );
  }

  /// Internal method to handle tooltip display logic
  void _showTooltipInternal({
    DataPointInfo? singlePoint,
    List<DataPointInfo>? multiPoints,
    required Offset position,
    required bool isMultiPoint,
  }) {
    // Update current state
    _currentPoint = singlePoint;
    _currentPoints = multiPoints;
    _currentPosition = position;
    _shouldShow = true;
    _isMultiPoint = isMultiPoint;

    // Check if we have a builder
    final hasBuilder = isMultiPoint
        ? widget.config.multiPointBuilder != null
        : widget.config.builder != null;

    if (!hasBuilder) {
      return;
    }

    // Cancel any pending hide operation
    _hideTimer?.cancel();
    _hideTimer = null;

    // If already showing a tooltip, check if we need to update
    if (_isVisible && _overlayEntry != null) {
      final shouldRecreate = isMultiPoint
          ? !_hasSameDataMulti(_currentPoints, multiPoints)
          : !_hasSameData(_currentPoint, singlePoint);

      if (shouldRecreate) {
        // Data changed - recreate tooltip with smooth transition
        _removeTooltip();
        _createTooltip();
      } else {
        // Same data, just update position smoothly
        _updateTooltipPosition(position);
      }
      return;
    }

    // Cancel any existing show timer and start a new one
    _showTimer?.cancel();
    _showTimer = Timer(widget.config.showDelay, () {
      if (_shouldShow && mounted) {
        if (isMultiPoint && _currentPoints != null && _currentPoints!.isNotEmpty) {
          _createTooltip();
        } else if (!isMultiPoint && _currentPoint != null) {
          _createTooltip();
        }
      }
    });
  }

  /// Hide tooltip
  @override
  void hideTooltip() {
    _shouldShow = false;

    // Cancel any pending show operation
    _showTimer?.cancel();
    _showTimer = null;

    // Only start hide timer if we're actually visible
    if (_overlayEntry != null && _isVisible) {
      _hideTimer?.cancel();
      _hideTimer = Timer(widget.config.hideDelay, () {
        if (!_shouldShow && mounted) {
          _animationController.reverse().whenComplete(() {
            // Only defer the cleanup, not the animation
            if (!_shouldShow) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_shouldShow && mounted) {
                  _removeTooltip();
                }
              });
            }
          });
        }
      });
    }
  }

  /// Check if two DataPointInfo have the same data
  bool _hasSameData(DataPointInfo? oldPoint, DataPointInfo? newPoint) {
    if (oldPoint == null || newPoint == null) return false;
    // Compare based on data index - same data point
    return oldPoint.dataIndex == newPoint.dataIndex &&
        oldPoint.seriesName == newPoint.seriesName;
  }

  /// Check if two lists of DataPointInfo have the same data
  bool _hasSameDataMulti(List<DataPointInfo>? oldPoints, List<DataPointInfo>? newPoints) {
    if (oldPoints == null || newPoints == null) return false;
    if (oldPoints.length != newPoints.length) return false;
    
    // Compare each point in the list
    for (int i = 0; i < oldPoints.length; i++) {
      if (!_hasSameData(oldPoints[i], newPoints[i])) {
        return false;
      }
    }
    return true;
  }

  /// Update tooltip position without recreating
  void _updateTooltipPosition(Offset newPosition) {
    if (_overlayEntry != null && mounted) {
      _currentPosition = newPosition;
      // Force overlay to rebuild with new position
      _overlayEntry!.markNeedsBuild();
    }
  }

  /// Create and show tooltip overlay
  void _createTooltip() {
    // Check if we should show based on current state
    if (!_shouldShow || _currentPosition == null) {
      return;
    }

    // Validate we have data
    if (_isMultiPoint) {
      if (_currentPoints == null || _currentPoints!.isEmpty) return;
    } else {
      if (_currentPoint == null) return;
    }

    // Remove existing tooltip
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    final Offset capturedPosition = _currentPosition!;
    final TooltipConfig capturedConfig = widget.config;

    // Build tooltip content based on mode
    Widget tooltipContent;
    if (_isMultiPoint && capturedConfig.multiPointBuilder != null) {
      final List<DataPointInfo> capturedPoints = List.from(_currentPoints!);
      tooltipContent = capturedConfig.multiPointBuilder!(capturedPoints);
    } else if (!_isMultiPoint && capturedConfig.builder != null) {
      final DataPointInfo capturedPoint = _currentPoint!;
      tooltipContent = capturedConfig.builder!(capturedPoint);
    } else {
      return; // No appropriate builder
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _TooltipPositioned(
          position: capturedPosition,
          config: capturedConfig,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
          child: tooltipContent,
        );
      },
    );

    try {
      final overlay = Overlay.of(context);
      overlay.insert(_overlayEntry!);
      _isVisible = true;
      _animationController.forward();
    } catch (e) {
      debugPrint("Error creating tooltip: $e");
      _removeTooltip();
    }
  }

  /// Remove tooltip overlay
  void _removeTooltip() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isVisible = false;
    _animationController.reset();

    // Clear current point/points reference when removing
    if (!_shouldShow) {
      _currentPoint = null;
      _currentPoints = null;
      _currentPosition = null;
      _isMultiPoint = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChartTooltipProvider(state: this, child: widget.child);
  }
}

/// Positioned tooltip widget
class _TooltipPositioned extends AnimatedWidget {
  final Offset position;
  final TooltipConfig config;
  final Widget child;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _TooltipPositioned({
    required this.position,
    required this.config,
    required this.child,
    required this.fadeAnimation,
    required this.scaleAnimation,
  }) : super(listenable: fadeAnimation);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Smart positioning to avoid screen edges
    double left = position.dx - 75; // Center tooltip horizontally
    double top = position.dy - 80; // Position above touch point

    // Adjust if too close to edges
    if (left < 10) left = 10;
    if (left + 150 > screenSize.width) left = screenSize.width - 160;
    if (top < 10) top = position.dy + 20; // Show below if too close to top

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        // THIS IS THE KEY FIX!
        child: AnimatedBuilder(
          animation: Listenable.merge([fadeAnimation, scaleAnimation]),
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: _TooltipContainer(config: config, child: this.child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Styled tooltip container
class _TooltipContainer extends StatelessWidget {
  final TooltipConfig config;
  final Widget child;

  const _TooltipContainer({required this.config, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        boxShadow: config.shadow != null
            ? [config.shadow!]
            : [
                const BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
        border: Border.all(color: Colors.white24, width: 1),
      ),
      constraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 30,
        maxWidth: 200,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}

/// Provider for tooltip functionality
class ChartTooltipProvider extends InheritedWidget {
  final TooltipController state;

  const ChartTooltipProvider({
    super.key,
    required this.state,
    required super.child,
  });

  static TooltipController? of(BuildContext context, {bool listen = true}) {
    return listen
        ? context
            .dependOnInheritedWidgetOfExactType<ChartTooltipProvider>()
            ?.state
        : (context
                .getElementForInheritedWidgetOfExactType<ChartTooltipProvider>()
                ?.widget as ChartTooltipProvider?)
            ?.state;
  }

  @override
  bool updateShouldNotify(ChartTooltipProvider oldWidget) {
    return oldWidget.state != state;
  }
}

/// Mixin for widgets that want to show tooltips
mixin TooltipMixin {
  /// Show tooltip for a data point
  void showTooltip(BuildContext context, DataPointInfo point, Offset position) {
    final provider = ChartTooltipProvider.of(context);
    provider?.showTooltip(point, position);
  }

  /// Show tooltip for multiple data points (axis mode)
  void showMultiPointTooltip(BuildContext context, List<DataPointInfo> points, Offset position) {
    final provider = ChartTooltipProvider.of(context);
    provider?.showMultiPointTooltip(points, position);
  }

  /// Hide tooltip
  void hideTooltip(BuildContext context) {
    final provider = ChartTooltipProvider.of(context);
    provider?.hideTooltip();
  }
}

/// Helper functions for tooltip positioning
class TooltipPositioning {
  /// Calculate optimal tooltip position to avoid screen edges
  static Offset calculatePosition(
    Offset touchPosition,
    Size tooltipSize,
    Size screenSize, {
    double margin = 16.0,
  }) {
    double x = touchPosition.dx;
    double y = touchPosition.dy - tooltipSize.height - 10;

    // Adjust horizontal position to stay on screen
    if (x + tooltipSize.width + margin > screenSize.width) {
      x = screenSize.width - tooltipSize.width - margin;
    }
    if (x < margin) {
      x = margin;
    }

    // Adjust vertical position to stay on screen
    if (y < margin) {
      y = touchPosition.dy + 10; // Show below touch point
    }

    return Offset(x, y);
  }
}
