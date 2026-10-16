import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 图片 2 标杆级：彩虹色散凸透镜流体水滴胶囊 (Prism Rainbow Liquid Lens Bubble)
///
/// 视觉与物理核心（100% 对标真机截图标杆）：
/// 1. 【透镜彩虹色散光环 (Chromatic Dispersion Rim)】：
///    顶部是一道晶莹璀璨的青蓝-紫白冷色高光弧（0xFF70E5FF ~ 0xFFE0F7FA），
///    底部是一道柔美透亮的品红-蜜桃暖色焦散折射弧（0xFFFF80BF ~ 0xFFFFD1DC）；
/// 2. 【凸透镜内聚光水质 (Caustic Lens Body)】：
///    内部为双向微凹凸渐变高光，呈现如真实水滴、厚水晶透镜般的立体凸透质感；
/// 3. 【水银水滴流体形变与弹簧动量 (Metaball Stretch & Spring Bounce)】：
///    切换 Tab 时，整颗透镜胶囊沿位移方向拉伸变长，到达目标位置后产生阻尼微颤回弹。
class LiquidLensBubble extends StatelessWidget {
  const LiquidLensBubble({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    required this.itemWidth,
    required this.indicatorHeight,
    this.animationDuration = const Duration(milliseconds: 380),
    this.curve = Curves.easeOutBack,
  });

  final int selectedIndex;
  final int itemCount;
  final double itemWidth;
  final double indicatorHeight;
  final Duration animationDuration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double lensRadius = indicatorHeight / 2;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: selectedIndex.toDouble(), end: selectedIndex.toDouble()),
      duration: animationDuration,
      curve: curve,
      builder: (context, animValue, child) {
        // 计算移动过程中的流体拉伸变形
        final double delta = (selectedIndex.toDouble() - animValue).abs();
        final double stretchFactor = 1.0 + math.sin(delta * math.pi) * 0.15;
        final double currentLeft = animValue * itemWidth;

        final double currentWidth = (itemWidth - 6) * stretchFactor;
        final double leftOffset = currentLeft + 3 - ((currentWidth - (itemWidth - 6)) / 2);

        return Positioned(
          left: leftOffset,
          top: 3,
          bottom: 3,
          width: currentWidth,
          child: CustomPaint(
            painter: _PrismRainbowLensPainter(
              borderRadius: BorderRadius.circular(lensRadius),
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }
}

class _PrismRainbowLensPainter extends CustomPainter {
  const _PrismRainbowLensPainter({
    required this.borderRadius,
    required this.isDark,
  });

  final BorderRadius borderRadius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final RRect rrect = borderRadius.toRRect(rect);

    // 1. 绘制水滴凸透镜体（高透水晶水光）
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.04),
                Colors.black.withValues(alpha: 0.15),
              ]
            : [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.70),
                const Color(0x1A80E5FF),
              ],
        stops: const [0.0, 0.45, 1.0],
      );

    // 水滴阴影
    final Path shadowPath = Path()..addRRect(rrect);
    canvas.drawShadow(
      shadowPath,
      isDark ? Colors.black.withValues(alpha: 0.45) : const Color(0x3380D8FF),
      8,
      true,
    );

    canvas.drawRRect(rrect, bodyPaint);

    // 2. 绘制标志性【彩虹棱镜色散高光光环】（对标图片 2：顶部青蓝、底部粉红）
    final Paint rainbowRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: isDark
            ? [
                const Color(0xFF80D8FF), // 青蓝高光
                Colors.white,
                const Color(0xFFFF80AB), // 品红焦散
                const Color(0xFFFFD180), // 金色折射
                const Color(0xFF80D8FF),
              ]
            : [
                const Color(0xFF70E5FF), // 晶莹青蓝
                const Color(0xFFB388FF), // 紫晶微晕
                const Color(0xFFFF80BF), // 柔粉品红
                const Color(0xFFFFA07A), // 暖杏微光
                const Color(0xFF70E5FF),
              ],
        stops: const [0.0, 0.30, 0.65, 0.85, 1.0],
      ).createShader(rect);

    final RRect innerRRect = rrect.deflate(0.8);
    canvas.drawRRect(innerRRect, rainbowRimPaint);

    // 3. 顶部抛光高光弧斑（模拟凸透镜镜面高光反射）
    final RRect highlightRRect = BorderRadius.only(
      topLeft: rrect.tlRadius,
      topRight: rrect.trRadius,
    ).toRRect(Rect.fromLTWH(2, 1, size.width - 4, size.height * 0.45));

    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.35 : 0.85),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    canvas.drawRRect(highlightRRect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _PrismRainbowLensPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius || oldDelegate.isDark != isDark;
  }
}
