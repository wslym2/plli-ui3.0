import 'dart:ui' as ui;
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:material_ui/material_ui.dart';

// ignore: camel_case_types
class RefreshIndicator_ extends StatefulWidget {
  const RefreshIndicator_({
    super.key,
    required this.isRefreshing,
  });

  final bool isRefreshing;

  @override
  State<RefreshIndicator_> createState() => _RefreshIndicatorState();
}

class _RefreshIndicatorState extends State<RefreshIndicator_>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _progressController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RefreshIndicator_ oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRefreshing != widget.isRefreshing) {
      if (widget.isRefreshing) {
        _scaleController.forward(from: 0.0);
        _progressController
          ..value = 0.0
          ..repeat();
      } else {
        _scaleController.reverse();
        _progressController.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = ColorScheme.of(context);
    _color = colorScheme.isDark
        ? const Color(0xCC1E1E24)
        : const Color(0xE6FFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInBack,
      ),
      child: Center(
        child: SizedBox.square(
          dimension: 42,
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(21)),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _color,
                    border: Border.all(
                      color: isDark
                          ? const Color(0x8080D8FF)
                          : const Color(0xB380E5FF),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: RotationTransition(
                    turns: _progressController,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        isDark ? const Color(0xFF80D8FF) : const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
