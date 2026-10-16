import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 苹果 iOS 26/27 液态流动指示器（Fluid Pill Indicator）
///
/// 当在不同项之间切换时，指示器呈现如水银、水滴般连贯流动的物理形变效果：
/// 1. 采用带弹性阻尼与物理动量的弹簧曲线；
/// 2. 在移动过程中带有轻微的粘滞拉伸和弹性回弹（Elastic liquid deformation）；
/// 3. 静止时立即休眠，不产生额外计算损耗。
class LiquidPillIndicator extends StatelessWidget {
  const LiquidPillIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    required this.itemWidth,
    required this.indicatorHeight,
    this.color,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 380),
    this.curve = Curves.easeOutBack,
  });

  final int selectedIndex;
  final int itemCount;
  final double itemWidth;
  final double indicatorHeight;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final Duration animationDuration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color effectiveColor = color ??
        (isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.black.withValues(alpha: 0.08));

    final BorderRadius effectiveRadius = (borderRadius as BorderRadius?) ??
        BorderRadius.circular(indicatorHeight / 2);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: selectedIndex.toDouble(), end: selectedIndex.toDouble()),
      duration: animationDuration,
      curve: curve,
      builder: (context, animValue, child) {
        // 计算流动过程中的液态拉伸形变
        final double delta = (selectedIndex.toDouble() - animValue).abs();
        final double stretchFactor = 1.0 + math.sin(delta * math.pi) * 0.12;

        final double currentLeft = animValue * itemWidth;

        return Positioned(
          left: currentLeft + (itemWidth * (1.0 - stretchFactor) / 2),
          top: 0,
          bottom: 0,
          width: itemWidth * stretchFactor,
          child: Container(
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: isDark ? 0.08 : 0.04,
                ),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black12).withValues(
                    alpha: isDark ? 0.25 : 0.05,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
