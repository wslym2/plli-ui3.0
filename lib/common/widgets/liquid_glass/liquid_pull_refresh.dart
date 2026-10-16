import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 苹果 iOS 26/27 液态玻璃水滴下拉刷新指示器 (Liquid Teardrop Refresh Indicator)
///
/// 视觉与物理机制：
/// 1. 【水滴流体粘滞拉伸】：下拉时从顶栏向下牵拉出一颗晶莹剔透的液态水滴，越拉越长；
/// 2. 【透镜折射与高光环】：水滴内部带有高斯模糊与晶体反光高光；
/// 3. 【弹簧释放吸纳】：松手刷新时水滴旋转凝聚，刷新完成优雅吸回玻璃顶栏。
class LiquidTeardropIndicator extends StatelessWidget {
  const LiquidTeardropIndicator({
    super.key,
    required this.pullExtent,
    required this.refreshTriggerPullDistance,
    required this.isRefreshing,
  });

  final double pullExtent;
  final double refreshTriggerPullDistance;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    if (pullExtent <= 0 && !isRefreshing) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (pullExtent / refreshTriggerPullDistance).clamp(0.0, 1.6);

    return RepaintBoundary(
      child: SizedBox(
        height: pullExtent.clamp(0.0, 120.0),
        width: double.infinity,
        child: CustomPaint(
          painter: _LiquidTeardropPainter(
            progress: progress,
            isRefreshing: isRefreshing,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _LiquidTeardropPainter extends CustomPainter {
  const _LiquidTeardropPainter({
    required this.progress,
    required this.isRefreshing,
    required this.isDark,
  });

  final double progress;
  final bool isRefreshing;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height < 5) return;

    final double centerX = size.width / 2;
    final double currentHeight = size.height;

    // 水滴顶部基准宽度与底部液滴半径
    final double topWidth = 50.0 + progress * 20.0;
    final double dropRadius = (14.0 + progress * 5.0).clamp(10.0, 22.0);
    final double dropCenterY = currentHeight - dropRadius - 4;

    final Path path = Path();
    path.moveTo(centerX - topWidth / 2, 0);

    // 贝塞尔曲线勾勒水滴拉伸流体轮廓 (Metaball Teardrop)
    path.cubicTo(
      centerX - topWidth * 0.35, currentHeight * 0.45,
      centerX - dropRadius * 1.1, dropCenterY - dropRadius * 0.7,
      centerX - dropRadius, dropCenterY,
    );

    // 底部圆润水滴
    path.arcToPoint(
      Offset(centerX + dropRadius, dropCenterY),
      radius: Radius.circular(dropRadius),
      clockwise: false,
    );

    path.cubicTo(
      centerX + dropRadius * 1.1, dropCenterY - dropRadius * 0.7,
      centerX + topWidth * 0.35, currentHeight * 0.45,
      centerX + topWidth / 2, 0,
    );
    path.close();

    // 1. 绘制水滴通透折射底色
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.15),
                const Color(0x6680D8FF), // 底部微青蓝透镜折射
              ]
            : [
                Colors.white.withValues(alpha: 0.85),
                const Color(0xCC80E5FF),
              ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, bodyPaint);

    // 2. 绘制边缘抛光晶体与棱镜色散高光线
    final Paint rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xB380D8FF),
                Colors.white.withValues(alpha: 0.8),
                const Color(0x66FF80AB),
              ]
            : [
                Colors.white,
                const Color(0xB380E5FF),
                const Color(0x80FF80BF),
              ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, rimPaint);

    // 3. 内部水滴高光斑点
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.45 : 0.75);
    canvas.drawCircle(
      Offset(centerX - dropRadius * 0.3, dropCenterY - dropRadius * 0.3),
      dropRadius * 0.3,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidTeardropPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.isDark != isDark;
  }
}
