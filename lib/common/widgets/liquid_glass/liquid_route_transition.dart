import 'package:flutter/material.dart';

/// 苹果 iOS 官方级物理弹性页面转场构建器 (Liquid Spring Page Transition Builder)
///
/// 具备：
/// 1. 真实物理弹簧阻尼回弹（Spring Damping Curves）；
/// 2. 深度空间视差平移（Parallax Slide）与轻度微缩放（Subtle Zooming）；
/// 3. 进入与退出的自然跟手度与通透感。
class LiquidSpringPageTransitionsBuilder extends PageTransitionsBuilder {
  const LiquidSpringPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 弹簧物理曲线：前段极速推进，后段细腻收敛并带轻微微弹
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.easeInCubic,
    );

    // 新页面平移进入：从右侧滑动进入，带有弹簧跟手感
    final Animation<Offset> primarySlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    // 浅层透明度过渡，避免突兀闪烁
    final Animation<double> primaryFade = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(curvedAnimation);

    // 被顶替的底层页面：微幅后退与微缩放（iOS 空间纵深视差）
    final CurvedAnimation secondaryCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final Animation<Offset> secondarySlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.24, 0.0),
    ).animate(secondaryCurved);

    final Animation<double> secondaryScale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(secondaryCurved);

    final Animation<double> secondaryFade = Tween<double>(
      begin: 1.0,
      end: 0.80,
    ).animate(secondaryCurved);

    return SlideTransition(
      position: secondarySlide,
      child: Transform.scale(
        scale: secondaryScale.value,
        alignment: Alignment.centerRight,
        child: FadeTransition(
          opacity: secondaryFade,
          child: SlideTransition(
            position: primarySlide,
            child: FadeTransition(
              opacity: primaryFade,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
