import 'dart:ui';
import 'package:PiliPlus/common/widgets/view_safe_area.dart';
import 'package:material_ui/material_ui.dart';

class AppBarAni extends StatelessWidget {
  const AppBarAni({
    super.key,
    required this.child,
    required this.controller,
    required this.isTop,
    required this.isFullScreen,
    required this.removeSafeArea,
  });

  final Widget child;
  final AnimationController controller;
  final bool isTop;
  final bool isFullScreen;
  final bool removeSafeArea;

  static final _topPos = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: Offset.zero,
  );

  static final _bottomPos = Tween<Offset>(
    begin: const Offset(0.0, 1.2),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    // 采用苹果弹性物理阻尼曲线替换生硬线性过渡
    final Animation<Offset> curvedPosition = (isTop ? _topPos : _bottomPos).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    final Widget innerContent = removeSafeArea
        ? child
        : ViewSafeArea(
            left: isFullScreen,
            right: isFullScreen,
            child: child,
          );

    return SlideTransition(
      position: curvedPosition,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // “动时满血，静时休眠”：控制器完全不可见时无需任何模糊运算
            if (controller.value < 0.01) {
              return const SizedBox.shrink();
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
                  end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
                  colors: [
                    const Color(0xCC000000),
                    const Color(0x73000000),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
                border: Border(
                  top: !isTop
                      ? BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 0.5,
                        )
                      : BorderSide.none,
                  bottom: isTop
                      ? BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 0.5,
                        )
                      : BorderSide.none,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 18.0 * controller.value,
                  sigmaY: 18.0 * controller.value,
                ),
                child: innerContent,
              ),
            );
          },
        ),
      ),
    );
  }
}
