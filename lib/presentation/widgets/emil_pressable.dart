import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_motion.dart';

/// An interactive wrapper implementing Emil Kowalski's tactile scale-on-press principle.
///
/// Principle:
/// - "Add `transform: scale(0.97)` on `:active`. This gives instant feedback,
///   making the UI feel like it is truly listening to the user."
/// - Immediate tactile response with subtle haptics.
/// - Snappy release with strong ease-out (`Cubic(0.23, 1, 0.32, 1)`).
class EmilPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleOnPress;
  final Duration duration;
  final Curve curve;
  final BorderRadius? borderRadius;
  final bool enableHaptics;
  final HitTestBehavior behavior;

  const EmilPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleOnPress = AppMotion.scalePressed,
    this.duration = AppMotion.durationPress,
    this.curve = AppMotion.easeOut,
    this.borderRadius,
    this.enableHaptics = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<EmilPressable> createState() => _EmilPressableState();
}

class _EmilPressableState extends State<EmilPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: AppMotion.scaleSettled,
      end: widget.scaleOnPress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.curve,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant EmilPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.reverseDuration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    _controller.forward();
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null || widget.onLongPress != null;
    if (!isInteractive) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
