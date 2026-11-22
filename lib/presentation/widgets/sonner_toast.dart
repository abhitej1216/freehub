import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_motion.dart';

/// Sonner-inspired elegant floating toast notification system.
///
/// Designed with Emil Kowalski's Sonner principles:
/// - Floating acrylic pill anchored at the bottom-center.
/// - Fluid entry animation (subtle upward translate + scale(0.96) + opacity fade).
/// - Instant swipe-to-dismiss gesture.
/// - Tactile haptic feedback on launch.
/// - Minimalist aesthetic with crisp border illumination and high legibility.
class SonnerToast {
  static void show(
    BuildContext context, {
    required String message,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(milliseconds: 2800),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    HapticFeedback.lightImpact();

    final overlayState = Overlay.of(context, rootOverlay: true);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (ctx) => _SonnerToastWidget(
        message: message,
        subtitle: subtitle,
        icon: icon ?? Icons.info_outline_rounded,
        iconColor: iconColor,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  static void success(BuildContext context, String message, {String? subtitle}) {
    show(
      context,
      message: message,
      subtitle: subtitle,
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF10B981),
    );
  }

  static void error(BuildContext context, String message, {String? subtitle}) {
    HapticFeedback.mediumImpact();
    show(
      context,
      message: message,
      subtitle: subtitle,
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFEF4444),
    );
  }

  static void copy(BuildContext context, String message) {
    show(
      context,
      message: message,
      icon: Icons.copy_rounded,
      iconColor: const Color(0xFF6366F1),
    );
  }
}

class _SonnerToastWidget extends StatefulWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  const _SonnerToastWidget({
    required this.message,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.onDismissed,
  });

  @override
  State<_SonnerToastWidget> createState() => _SonnerToastWidgetState();
}

class _SonnerToastWidgetState extends State<_SonnerToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  double _dragOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.durationStandard,
      reverseDuration: AppMotion.durationFast,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.easeOut),
    );

    _scale = Tween<double>(begin: AppMotion.scaleEnterFrom, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.easeOut),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final effectiveIconColor = widget.iconColor ?? colorScheme.primary;

    return Positioned(
      bottom: 28 + MediaQuery.paddingOf(context).bottom,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.translate(
                offset: Offset(0, (_slide.value.dy * 40) + _dragOffsetY),
                child: Transform.scale(
                  scale: _scale.value,
                  child: child,
                ),
              ),
            );
          },
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! > 0) {
                setState(() {
                  _dragOffsetY += details.primaryDelta!;
                });
              }
            },
            onVerticalDragEnd: (details) {
              if (_dragOffsetY > 20 ||
                  (details.primaryVelocity != null &&
                      details.primaryVelocity! > 200)) {
                _dismiss();
              } else {
                setState(() => _dragOffsetY = 0.0);
              }
            },
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF181B22)
                      : const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C3240)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: effectiveIconColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 18,
                        color: effectiveIconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.actionLabel != null && widget.onAction != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          widget.onAction!();
                          _dismiss();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: effectiveIconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
