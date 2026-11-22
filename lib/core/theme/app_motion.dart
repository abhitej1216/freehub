import 'package:flutter/material.dart';

/// Emil Kowalski's motion tokens and animation guidelines translated to Flutter.
///
/// Principles:
/// - Custom strong easing curves (never weak default curves, never ease-in for UI).
/// - UI animations stay under 260ms (modals/sheets up to 350ms).
/// - Micro-scale on active press (scale down to 0.97 for tactile feedback).
/// - Never animate from scale(0); start from scale(0.95) with opacity 0.
/// - Non-uniform stagger cascade for group entrances (30-40ms delta).
class AppMotion {
  AppMotion._();

  // ---------------------------------------------------------------------------
  // Easing Curves (Emil Kowalski's CSS Tokens)
  // ---------------------------------------------------------------------------

  /// --ease-out: cubic-bezier(0.23, 1, 0.32, 1)
  /// Strong ease-out for all UI interactions, entrances, and button releases.
  static const Curve easeOut = Cubic(0.23, 1.0, 0.32, 1.0);

  /// --ease-in-out: cubic-bezier(0.77, 0, 0.175, 1)
  /// Strong ease-in-out for moving / morphing elements already on screen.
  static const Curve easeInOut = Cubic(0.77, 0.0, 0.175, 1.0);

  /// --ease-drawer: cubic-bezier(0.32, 0.72, 0, 1)
  /// iOS-like drawer and bottom sheet curve (from Ionic Framework / Vaul).
  static const Curve easeDrawer = Cubic(0.32, 0.72, 0.0, 1.0);

  /// Subtle spring simulation for interactive micro-scales and bounces.
  static const Curve springSubtle = Cubic(0.175, 0.885, 0.32, 1.15);

  // ---------------------------------------------------------------------------
  // Durations (Strictly budgeted for perceived performance)
  // ---------------------------------------------------------------------------

  /// Button & card press feedback (120-160ms).
  static const Duration durationPress = Duration(milliseconds: 140);

  /// Small popovers, tooltips, filter chips, and icon switches (150-200ms).
  static const Duration durationFast = Duration(milliseconds: 180);

  /// Standard UI transitions, menus, and card reveals (200-260ms).
  static const Duration durationStandard = Duration(milliseconds: 240);

  /// Modals, bottom sheets, and route transitions (280-350ms).
  static const Duration durationSheet = Duration(milliseconds: 320);

  /// Stagger interval between list/grid elements (30-40ms non-uniform).
  static const Duration durationStagger = Duration(milliseconds: 35);

  // ---------------------------------------------------------------------------
  // Scale Factors
  // ---------------------------------------------------------------------------

  /// Emil's scale on active press: subtle 0.97 scale gives physical confirmation.
  static const double scalePressed = 0.97;

  /// Emil's rule: never scale from 0. Start from 0.95 with opacity 0.
  static const double scaleEnterFrom = 0.95;

  /// Full size when settled.
  static const double scaleSettled = 1.0;
}
