import 'package:PiliPlus/common/widgets/liquid_glass/liquid_glass.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:material_ui/material_ui.dart';

class CustomToast extends StatelessWidget {
  const CustomToast(this.msg, {super.key});

  final String msg;

  static double toastOpacity = Pref.defaultToastOp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + 36,
      ),
      child: LiquidGlassContainer(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        blur: 26.0,
        borderWidth: 0.8,
        glassOpacity: isDark ? 0.72 : 0.78,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : colorScheme.onSurface,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget(this.msg, {super.key});

  ///loading msg
  final String msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return LiquidGlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(26)),
      blur: 28.0,
      borderWidth: 0.8,
      glassOpacity: isDark ? 0.75 : 0.82,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.15),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ],
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 优雅精细的加载圆环
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation(
                isDark ? Colors.white : colorScheme.primary,
              ),
            ),
          ),
          // 提示文字
          Text(
            msg,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class NotifyWarning extends StatelessWidget {
  const NotifyWarning(this.msg, {super.key});

  final String msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return LiquidGlassContainer(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      blur: 24.0,
      borderWidth: 0.75,
      glassOpacity: isDark ? 0.75 : 0.80,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 24,
            color: Colors.amber[700] ?? onSurfaceVariant,
          ),
          Text(
            msg,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
