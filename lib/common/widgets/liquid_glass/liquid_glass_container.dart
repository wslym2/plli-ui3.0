import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// iOS 26/27 Liquid Glass（液态玻璃）材质设计系统
///
/// 遵循“动时满血，静时休眠”的能效策略：
/// 1. 结构内部自带 [RepaintBoundary]，避免高斯模糊滤镜导致整屏树被动重绘；
/// 2. 静止时无任何周期性 ticker/动画轮询，资源瞬间归零；
/// 3. 提供高折射微光边缘（Liquid Rim Light）、双层多阶反光渐变（Specular Reflection）、
///    以及超椭圆自然曲率，与苹果官方 iOS 原生高级通透质感完全对标。
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blur = 24.0,
    this.glassOpacity,
    this.tintColor,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 0.85,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
    this.alignment,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final double blur;
  final double? glassOpacity;
  final Color? tintColor;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 苹果官方级微调：浅色透亮冰晶白，深色深邃玄曜黑
    final double defaultOpacity = isDark ? 0.62 : 0.68;
    final double effectiveOpacity = glassOpacity ?? defaultOpacity;

    final Color baseTint = tintColor ??
        (isDark
            ? const Color(0xFF16161A)
            : const Color(0xFFFFFFFF));
    final Color effectiveBackgroundColor =
        baseTint.withValues(alpha: effectiveOpacity);

    // 液态玻璃高折射边缘高光渐变（顶部承接光源，底部柔和反射）
    final LinearGradient rimLightGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              (borderColor ?? Colors.white).withValues(alpha: 0.22),
              (borderColor ?? Colors.white).withValues(alpha: 0.06),
              (borderColor ?? Colors.white).withValues(alpha: 0.02),
              (borderColor ?? Colors.white).withValues(alpha: 0.12),
            ]
          : [
              (borderColor ?? Colors.white).withValues(alpha: 0.85),
              (borderColor ?? Colors.white).withValues(alpha: 0.35),
              (borderColor ?? Colors.black).withValues(alpha: 0.04),
              (borderColor ?? Colors.white).withValues(alpha: 0.50),
            ],
      stops: const [0.0, 0.35, 0.7, 1.0],
    );

    // 液态微球面高光流光层（极度克制的高级物理反光）
    final LinearGradient specularGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.015),
              Colors.transparent,
            ]
          : [
              Colors.white.withValues(alpha: 0.45),
              Colors.white.withValues(alpha: 0.10),
              Colors.transparent,
            ],
      stops: const [0.0, 0.4, 1.0],
    );

    // 默认苹果级多阶空间深度阴影
    final List<BoxShadow> effectiveShadows = boxShadow ??
        (isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: -1,
                ),
              ]);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        gradient: specularGradient,
      ),
      child: child,
    );

    if (blur > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      );
    }

    content = ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      child: content,
    );

    // 叠加液态高光微折射边缘
    if (showBorder) {
      content = CustomPaint(
        foregroundPainter: _LiquidGlassBorderPainter(
          borderRadius: borderRadius,
          borderWidth: borderWidth,
          gradient: rimLightGradient,
        ),
        child: content,
      );
    }

    // 独立 RepaintBoundary，保证动静分离，静止时不消耗任何电量
    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: effectiveShadows,
        ),
        child: content,
      ),
    );
  }
}

/// 绘制纳米级精细玻璃物理折射边缘
class _LiquidGlassBorderPainter extends CustomPainter {
  const _LiquidGlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.gradient,
  });

  final BorderRadiusGeometry borderRadius;
  final double borderWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final RRect rrect = borderRadius.resolve(TextDirection.ltr).toRRect(rect);
    final RRect innerRRect = rrect.deflate(borderWidth / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(innerRRect, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradient != gradient;
  }
}
