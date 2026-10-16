import 'dart:ui';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:material_ui/material_ui.dart';

class PBadge extends StatelessWidget {
  final String? text;

  final bool isStack;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final EdgeInsets? padding;

  final PBadgeType type;
  final PBadgeSize size;

  final double fontSize;
  final bool isBold;
  final double? textScaleFactor;

  const PBadge({
    super.key,
    required this.text,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.type = PBadgeType.primary,
    this.size = PBadgeSize.medium,
    this.isStack = true,
    this.fontSize = 11,
    this.isBold = true,
    this.textScaleFactor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isNullOrEmpty) {
      return const SizedBox.shrink();
    }

    ColorScheme theme = Theme.of(context).colorScheme;

    Color bgColor;
    Color color;
    Color borderColor = Colors.transparent;
    bool isGlass = false;

    switch (type) {
      case PBadgeType.primary:
        bgColor = theme.primary;
        color = theme.onPrimary;
      case PBadgeType.secondary:
        bgColor = theme.secondaryContainer.withValues(alpha: 0.85);
        color = theme.onSecondaryContainer;
      case PBadgeType.gray:
        // 苹果 iOS / visionOS 风格微晶液态玻璃胶囊
        isGlass = true;
        bgColor = const Color(0x99000000);
        color = Colors.white;
        borderColor = Colors.white.withValues(alpha: 0.22);
      case PBadgeType.error:
        if (theme.isDark) {
          bgColor = theme.errorContainer;
          color = theme.onErrorContainer;
        } else {
          bgColor = theme.error;
          color = theme.onError;
        }
      case PBadgeType.line_primary:
        color = theme.primary;
        bgColor = Colors.transparent;
        borderColor = theme.primary;
      case PBadgeType.line_secondary:
        color = theme.secondary;
        bgColor = Colors.transparent;
        borderColor = theme.secondary;
      case PBadgeType.free:
        bgColor = theme.freeColor;
        color = Colors.white;
      case PBadgeType.shop:
        bgColor = theme.secondaryContainer.withValues(alpha: 0.5);
        color = theme.onSurfaceVariant;
    }

    late EdgeInsets paddingStyle = const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5.5);
    final BorderRadius br = size == .small
        ? const BorderRadius.all(Radius.circular(6))
        : const BorderRadius.all(Radius.circular(8));

    Widget content = Container(
      padding: padding ?? paddingStyle,
      decoration: BoxDecoration(
        borderRadius: br,
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.55),
        boxShadow: isGlass
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        text!,
        textScaler: textScaleFactor != null ? .linear(textScaleFactor!) : null,
        style: TextStyle(
          height: 1,
          fontSize: fontSize,
          color: color,
          fontWeight: isBold ? FontWeight.w600 : null,
          letterSpacing: 0.2,
        ),
        strutStyle: StrutStyle(
          leading: 0,
          height: 1,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w600 : null,
        ),
      ),
    );

    if (isGlass) {
      content = ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: content,
        ),
      );
    }

    if (isStack) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: content,
      );
    } else {
      return content;
    }
  }
}
