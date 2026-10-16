import 'package:flutter/material.dart';

/// 苹果 iOS 26/27 液态物理按压反馈组件
///
/// 特性：
/// 1. 采用带弹簧阻尼（Spring-damping）的高精度物理动画曲线；
/// 2. 按压时产生微妙的流体压缩形变（0.96 缩放）与液体微光高光扩散；
/// 3. 松手时瞬间弹性复原，丝滑跟手；
/// 4. “动时满血，静时休眠”：动画结束后立即停用动画引擎，功耗极低。
class LiquidPressable extends StatefulWidget {
  const LiquidPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.955,
    this.enableSheen = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool enableSheen;
  final BorderRadiusGeometry borderRadius;
  final HitTestBehavior behavior;

  @override
  State<LiquidPressable> createState() => _LiquidPressableState();
}

class _LiquidPressableState extends State<LiquidPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _sheenAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 260),
    );

    // 按下时快速阻尼压缩，回弹时带有苹果特有的微弹回弹（Curves.easeOutBack）
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
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
          final scale = _scaleAnimation.value;
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
                              (isDark ? Colors.white : Colors.black).withValues(
                                alpha: (isDark ? 0.10 : 0.04) * sheenOpacity,
                              ),
                              (isDark ? Colors.white : Colors.black).withValues(
                                alpha: (isDark ? 0.03 : 0.01) * sheenOpacity,
                              ),
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

          return Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: content,
          );
        },
        child: widget.child,
      ),
    );
  }
}
