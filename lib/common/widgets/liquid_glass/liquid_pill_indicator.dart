import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 苹果 iOS 26/27 液态流动指示器（Fluid Pill Indicator）
///
/// 特性：
/// 1. 采用带弹性阻尼与物理动量的弹簧曲线；
/// 2. 浅色模式下呈现纯白浮雕晶体胶囊（高对比度，浮于玻璃之上）；
/// 3. 深色模式下呈现高透晶白胶囊；
/// 4. 移动过程中带有流体粘滞拉伸和弹性回弹（Fluid stretch & bounce）。
class LiquidPillIndicator extends StatelessWidget {
  const LiquidPillIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    required this.itemWidth,
    required this.indicatorHeight,
    this.color,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 360),
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

    // 浅色模式采用纯白浮雕卡片（对标 iOS 控制中心/Dock），深色模式采用晶白半透
    final Color effectiveColor = color ??
        (isDark
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white);

    final BorderRadius effectiveRadius = (borderRadius as BorderRadius?) ??
        BorderRadius.circular(indicatorHeight / 2);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: selectedIndex.toDouble(), end: selectedIndex.toDouble()),
      duration: animationDuration,
      curve: curve,
      builder: (context, animValue, child) {
        final double delta = (selectedIndex.toDouble() - animValue).abs();
        final double stretchFactor = 1.0 + math.sin(delta * math.pi) * 0.10;

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
                  alpha: isDark ? 0.15 : 0.04,
                ),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
