import 'package:flutter/material.dart';

abstract final class CommandColors {
  static const background = Color(0xFF121414);
  static const panel = Color(0xFF1A1D1B);
  static const high = Color(0xFF272B28);
  static const lowest = Color(0xFF0C100E);
  static const primary = Color(0xFFA3F69B);
  static const primaryContainer = Color(0xFF88D982);
  static const blue = Color(0xFFBDF4FF);
  static const cyan = Color(0xFF00E3FD);
  static const error = Color(0xFFFFB4AB);
  static const text = Color(0xFFE2E2E2);
  static const muted = Color(0xFFBAC3B5);
  static const dim = Color(0xFF7E8979);
}

abstract final class CommandType {
  static TextStyle body({
    double size = 14,
    Color color = CommandColors.text,
    double weight = 500,
    double height = 1.35,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    color: color,
    height: height,
    fontWeight: FontWeight.values[(weight / 100 - 1).round().clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight)],
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle display({
    double size = 28,
    Color color = CommandColors.text,
    double weight = 700,
    double spacing = 0,
  }) => body(
    size: size,
    color: color,
    weight: weight,
    height: 1.15,
  ).copyWith(fontFamily: 'SpaceGrotesk', letterSpacing: spacing);

  static TextStyle label({
    double size = 11,
    Color color = CommandColors.muted,
    double spacing = 0.8,
  }) => display(size: size, color: color, weight: 500, spacing: spacing);
}

class CommandPanel extends StatelessWidget {
  const CommandPanel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = CommandColors.panel,
    this.accent,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: accent == null
          ? null
          : Border(left: BorderSide(color: accent!, width: 4)),
    ),
    padding: padding,
    child: child,
  );
}

class CommandButton extends StatelessWidget {
  const CommandButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = CommandColors.primaryContainer,
    this.foreground = const Color(0xFF002203),
    this.fontSize = 13,
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;
  final Color foreground;
  final double fontSize;
  final double height;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: height < 40 ? 8 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 22),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: CommandType.display(
                    size: fontSize,
                    color: foreground,
                    weight: 700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showDemoDetail(BuildContext context, String title, String message) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: CommandColors.panel,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DEMONSTRAÇÃO',
                style: CommandType.label(color: CommandColors.primary),
              ),
              const SizedBox(height: 12),
              Text(title, style: CommandType.display(size: 24)),
              const SizedBox(height: 16),
              Text(
                message,
                style: CommandType.body(color: CommandColors.muted),
              ),
              const SizedBox(height: 12),
              Text(
                'Dados ilustrativos. Esta ação não envia comandos, não altera '
                'equipamentos e não salva registros operacionais.',
                style: CommandType.body(size: 12, color: CommandColors.dim),
              ),
              const SizedBox(height: 24),
              CommandButton(
                label: 'ENTENDI',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
