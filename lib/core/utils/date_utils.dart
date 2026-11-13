import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _displayFullFormat = DateFormat('MMM d, yyyy • h:mm a');

  static String now() => DateTime.now().toUtc().toIso8601String();

  static String toDisplay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return _displayFormat.format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String toDisplayFull(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return _displayFullFormat.format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String timeAgo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
      if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
      return '${(difference.inDays / 365).floor()}y ago';
    } catch (_) {
      return isoDate;
    }
  }
}
