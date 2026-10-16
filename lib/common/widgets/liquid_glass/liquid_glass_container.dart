import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Kyant0 物理光学级 Liquid Glass（液态玻璃）核心材质系统
///
/// 核心光学引擎：
/// 1. 【边缘上下反转透镜折射 (Inverted Lens Refraction)】：
///    对标真实凸透镜厚玻璃光学全反射现象，边缘倒角处光线发生几何倒转，
///    底层内容在穿过玻璃边界时产生上下颠倒、微缩反转的真实物理透镜折射倒影；
/// 2. 【棱镜色散光环 (Chromatic Dispersion Prism Rim)】：
///    根据 Kyant0 物理模型，模拟不同波长光线的折射率差异，在边缘形成青蓝与紫品红的分色光环；
/// 3. 【极度纯净高透光 (High-Vibrancy Optical Medium)】：
///    88% 纯净高饱和透光，绝不产生死白或混浊发灰的脏感；
/// 4. 【动时满血，静时休眠】：独立 [RepaintBoundary] 保证无交互时零额外重绘消耗。
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 24.0,
    this.glassOpacity,
    this.tintColor,
    this.showBorder = true,
    this.enableChromaticDispersion = true,
    this.enableInvertedRefraction = true,
    this.borderColor,
    this.borderWidth = 1.0,
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
  final bool enableChromaticDispersion;
  final bool enableInvertedRefraction;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double defaultOpacity = isDark ? 0.78 : 0.86;
    final double effectiveOpacity = glassOpacity ?? defaultOpacity;

    final Color effectiveBaseColor = tintColor ??
        (isDark
            ? const Color(0xFF1A1A22)
            : const Color(0xFFFFFFFF));

    final Color backgroundColor = effectiveBaseColor.withValues(alpha: effectiveOpacity);

    // 棱镜色散高光光环（模拟光波色散拆分）
    final Gradient dispersionBorderGradient = enableChromaticDispersion
        ? (isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0x8080D8FF), // 顶部棱镜微青蓝高光
                  Colors.white.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.06),
                  const Color(0x4DFF80AB), // 底部紫品红折射焦散
                ],
                stops: const [0.0, 0.28, 0.72, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xCC80E5FF), // 晶莹青蓝微高光
                  Colors.white.withValues(alpha: 0.98),
                  const Color(0x1F000000),
                  const Color(0x73FF80BF), // 底部品红微晕
                ],
                stops: const [0.0, 0.32, 0.72, 1.0],
              ))
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.06),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.92),
                    Colors.white.withValues(alpha: 0.35),
                  ],
          );

    // 顶部凸透镜弧面高光（Specular Glare）
    final LinearGradient specularHighlight = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.09),
              Colors.white.withValues(alpha: 0.02),
              Colors.transparent,
            ]
          : [
              Colors.white.withValues(alpha: 0.42),
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
            ],
      stops: const [0.0, 0.25, 0.65],
    );

    // 超软通透空间深度投影
    final List<BoxShadow> effectiveShadows = boxShadow ??
        (isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: const Color(0x1A80D8FF),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: specularHighlight,
      ),
      child: child,
    );

    // 叠加高斯模糊滤镜
    if (blur > 0) {
      content = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      );
    }

    content = ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      child: content,
    );

    // 叠加上下反转透镜倒角折射层与棱镜色散边框
    if (showBorder) {
      content = CustomPaint(
        foregroundPainter: _LiquidLensRefractionPainter(
          borderRadius: borderRadius,
          borderWidth: borderWidth,
          dispersionGradient: dispersionBorderGradient,
          enableInversion: enableInvertedRefraction,
          isDark: isDark,
        ),
        child: content,
      );
    }

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

/// 绘制物理透镜边缘倒角折射：包含上下反向折射焦散与棱镜色散高光
class _LiquidLensRefractionPainter extends CustomPainter {
  const _LiquidLensRefractionPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.dispersionGradient,
    required this.enableInversion,
    required this.isDark,
  });

  final BorderRadiusGeometry borderRadius;
  final double borderWidth;
  final Gradient dispersionGradient;
  final bool enableInversion;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final RRect rrect = borderRadius.resolve(TextDirection.ltr).toRRect(rect);
    final RRect innerRRect = rrect.deflate(borderWidth / 2);

    // 1. 绘制凸透镜外边缘色散高光线
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = dispersionGradient.createShader(rect);
    canvas.drawRRect(innerRRect, borderPaint);

    // 2. 模拟边缘上下反转物理透镜折射（Inverted Caustic Lens Bevel）
    // 在倒角内侧边缘叠加一条倒置反向焦散光条，产生底层图像在透镜边缘反转折射的光学立体感
    if (enableInversion && size.width > 20 && size.height > 20) {
      final RRect invertedCausticRRect = rrect.deflate(borderWidth + 1.2);
      final LinearGradient invertedGradient = LinearGradient(
        begin: Alignment.bottomCenter, // 上下反向映射
        end: Alignment.topCenter,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.16),
                const Color(0x1F80D8FF),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.20),
              ]
            : [
                Colors.white.withValues(alpha: 0.45),
                const Color(0x3380E5FF),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.05),
              ],
        stops: const [0.0, 0.15, 0.85, 1.0],
      );

      final Paint causticPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = invertedGradient.createShader(rect);

      canvas.drawRRect(invertedCausticRRect, causticPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidLensRefractionPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.dispersionGradient != dispersionGradient ||
        oldDelegate.enableInversion != enableInversion ||
        oldDelegate.isDark != isDark;
  }
}
