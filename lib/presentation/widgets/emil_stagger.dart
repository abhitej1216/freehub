import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';

/// Staggered entry animation wrapper implementing Emil Kowalski's group entrance recipe.
///
/// Principles:
/// - Stagger delay: short (30-40ms between items, capped at 6 items to prevent sluggishness).
/// - Transform: starts at translateY(10) with opacity 0, settling into translateY(0) with opacity 1.
/// - Never animate from scale(0).
/// - Uses strong custom curve: `Cubic(0.23, 1.0, 0.32, 1.0)`.
/// - Stagger is purely decorative: it never blocks interaction.
class EmilStaggerItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration stepDelay;
  final Duration duration;
  final double translationY;

  const EmilStaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.stepDelay = AppMotion.durationStagger,
    this.duration = AppMotion.durationStandard,
    this.translationY = 10.0,
  });

  @override
  State<EmilStaggerItem> createState() => _EmilStaggerItemState();
}

class _EmilStaggerItemState extends State<EmilStaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.easeOut,
      ),
    );

    _translation = Tween<double>(begin: widget.translationY, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppMotion.easeOut,
      ),
    );

    // Stagger delay capped at index 6 so long lists don't feel delayed
    final effectiveIndex = widget.index > 6 ? 6 : widget.index;
    final totalDelay = widget.baseDelay + (widget.stepDelay * effectiveIndex);

    if (totalDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(totalDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
