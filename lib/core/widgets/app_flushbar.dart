import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

enum AppFlushType { error, success, info }

Future<void> showTopFlushbar(
  BuildContext context,
  String message, {
  Color? color,
  AppFlushType type = AppFlushType.error,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) async {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  Color variant;
  IconData resolvedIcon;
  switch (type) {
    case AppFlushType.success:
      variant = color ?? cs.primary;
      resolvedIcon = icon ?? Icons.check_circle_outline;
      break;
    case AppFlushType.info:
      variant = color ?? (cs.tertiary);
      resolvedIcon = icon ?? Icons.info_outline;
      break;
    case AppFlushType.error:
      variant = color ?? cs.error;
      resolvedIcon = icon ?? Icons.error_outline;
      break;
  }

  final surface = cs.surface;
  final blendAlpha = isDark ? 0.22 : 0.10;
  final bg = Color.alphaBlend(variant.withValues(alpha: blendAlpha), surface);
  final fg = cs.onSurface;

  await Flushbar(
    messageText: Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
    ),
    backgroundColor: bg,
    duration: duration,
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    borderRadius: BorderRadius.circular(12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    icon: Icon(resolvedIcon, color: variant),
    leftBarIndicatorColor: variant,
    shouldIconPulse: false,
    boxShadows: [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.30) : Colors.black.withValues(alpha: 0.10),
        blurRadius: 10,
        offset: const Offset(0, 6),
      ),
    ],
    forwardAnimationCurve: Curves.easeOutCubic,
  ).show(context);
}
