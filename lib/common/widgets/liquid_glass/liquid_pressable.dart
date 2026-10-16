import 'package:flutter/material.dart';

/// Kyant0 风格的果冻弹性流体按压反馈 (Jelly Spring Damped Pressable)
///
/// 特性：
/// 1. 按压时产生流体物理形变（Y 轴微压扁 0.95，X 轴轻微横向扩张 1.015）；
/// 2. 松手时带有弹簧阻尼回弹（Curves.easeOutBack）；
/// 3. 伴随水波微光涟漪扩散；
/// 4. 动时满血，静时休眠（交互停止后立即休眠，零额外能耗）。
class LiquidPressable extends StatefulWidget {
  const LiquidPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.955,
    this.enableJellyDeformation = true,
    this.enableSheen = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool enableJellyDeformation;
  final bool enableSheen;
  final BorderRadiusGeometry borderRadius;
  final HitTestBehavior behavior;

  @override
  State<LiquidPressable> createState() => _LiquidPressableState();
}

class _LiquidPressableState extends State<LiquidPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleYAnimation;
  late final Animation<double> _scaleXAnimation;
  late final Animation<double> _sheenAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 280),
    );

    // 果冻流体物理形变
    _scaleYAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _scaleXAnimation = Tween<double>(
      begin: 1.0,
      end: widget.enableJellyDeformation ? 1.0 + (1.0 - widget.pressedScale) * 0.35 : widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    _sheenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scaleY = _scaleYAnimation.value;
          final scaleX = _scaleXAnimation.value;
          final sheenOpacity = _sheenAnimation.value;

          Widget content = child!;
          if (widget.enableSheen && sheenOpacity > 0.01) {
            content = Stack(
              fit: StackFit.passthrough,
              children: [
                content,
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: widget.borderRadius,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (isDark ? const Color(0x3380D8FF) : const Color(0x4D80E5FF)).withValues(
                                alpha: (isDark ? 0.12 : 0.06) * sheenOpacity,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
            child: content,
          );
        },
        child: widget.child,
      ),
    );
  }
}
