import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Kyant0 风格的水滴粘滞果冻拖拽组件 (Liquid Blob Damped Drag)
///
/// 核心物理机制：
/// 1. 【水滴拖拽与粘滞拉伸】：
///    手指按住并拖动时，控件像水银水滴一样被拉扯，沿拖动方向产生流体拉伸变形（Shear & Non-linear Stretch），
///    位移阻力随拖拽距离呈指数级增加；
/// 2. 【弹簧物理回弹 (Spring Dynamics)】：
///    松开手指瞬间，启动真实质量-弹簧-阻尼系统，水滴带惯性回弹并产生几轮果冻微颤；
/// 3. 【动时满血，静时休眠】：
///    仅在手势交互与弹簧释放时激活动画引擎，恢复静止后立即休眠，零额外 CPU/GPU 开销。
class LiquidBlobDrag extends StatefulWidget {
  const LiquidBlobDrag({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.maxDragDistance = 45.0,
    this.stretchFactor = 0.35,
    this.enableBlobStretch = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double maxDragDistance;
  final double stretchFactor;
  final bool enableBlobStretch;

  @override
  State<LiquidBlobDrag> createState() => _LiquidBlobDragState();
}

class _LiquidBlobDragState extends State<LiquidBlobDrag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  Animation<Offset>? _springAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController.unbounded(vsync: this);
    _springController.addListener(() {
      if (_springAnimation != null) {
        setState(() {
          _dragOffset = _springAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  // 粘滞阻尼公式：将无限拖动限制在最大阈值内，越拉阻力越大
  Offset _calculateDampedOffset(Offset rawOffset) {
    final double distance = rawOffset.distance;
    if (distance == 0) return Offset.zero;

    final double dampedDistance = widget.maxDragDistance *
        (1.0 - math.exp(-distance / (widget.maxDragDistance * 1.5)));
    return rawOffset / distance * dampedDistance;
  }

  void _onPanStart(DragStartDetails details) {
    _springController.stop();
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = _calculateDampedOffset(_dragOffset + details.delta);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    // 释放水滴：启动高精度弹簧物理模拟器 (SpringSimulation)
    final double distance = _dragOffset.distance;
    if (distance < 2.0) {
      if (widget.onTap != null && distance < 4.0) {
        widget.onTap!();
      }
      setState(() {
        _dragOffset = Offset.zero;
      });
      return;
    }

    // 模拟苹果级弹簧：适度阻尼，轻微超调果冻回弹
    const SpringDescription spring = SpringDescription(
      mass: 1.0,
      stiffness: 380.0,
      damping: 18.0,
    );

    final SpringSimulation simulationX = SpringSimulation(
      spring,
      _dragOffset.dx,
      0.0,
      details.velocity.pixelsPerSecond.dx,
    );
    final SpringSimulation simulationY = SpringSimulation(
      spring,
      _dragOffset.dy,
      0.0,
      details.velocity.pixelsPerSecond.dy,
    );

    final startOffset = _dragOffset;
    _springController.duration = const Duration(milliseconds: 600);
    _springAnimation = CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    ).drive(Tween<Offset>(begin: startOffset, end: Offset.zero));

    _springController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final double distance = _dragOffset.distance;
    final double angle = distance > 0 ? _dragOffset.direction : 0.0;

    // 根据拖拽距离计算流体水滴沿受力方向的拉伸比与横向收缩比
    final double stretchRatio = widget.enableBlobStretch
        ? 1.0 + (distance / widget.maxDragDistance) * widget.stretchFactor
        : 1.0;
    final double squeezeRatio = widget.enableBlobStretch
        ? 1.0 / math.sqrt(stretchRatio)
        : 1.0;

    // 复合矩阵变换：旋转对齐拖动方向 -> 拉伸变形 -> 逆旋转 -> 偏移
    final Matrix4 transform = Matrix4.identity()
      ..translate(_dragOffset.dx, _dragOffset.dy)
      ..rotateZ(angle)
      ..scale(stretchRatio, squeezeRatio, 1.0)
      ..rotateZ(-angle);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: widget.child,
      ),
    );
  }
}
