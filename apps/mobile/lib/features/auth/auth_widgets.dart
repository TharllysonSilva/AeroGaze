import 'package:flutter/material.dart';

import '../../app/design_system.dart';

class AuthFrame extends StatelessWidget {
  const AuthFrame({
    required this.children,
    this.onBack,
    this.live = false,
    super.key,
  });
  final List<Widget> children;
  final VoidCallback? onBack;
  final bool live;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _AuthGrid())),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.7),
                radius: .8,
                colors: [
                  CommandColors.primary.withValues(alpha: .065),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AuthBadge(
                            label: live ? 'SESSÃO API' : 'DEMONSTRAÇÃO',
                            icon: Icons.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AuthBadge(
                            label: live
                                ? 'CAPTURA MANUAL'
                                : 'SATÉLITE SIMULADO',
                            icon: Icons.satellite_alt,
                            color: CommandColors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (onBack != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('VOLTAR'),
                          style: TextButton.styleFrom(
                            foregroundColor: CommandColors.primary,
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ),
                    ],
                    ...children,
                    const SizedBox(height: 28),
                    Text(
                      live
                          ? 'AEROGAZE AI • OPERAÇÃO AUTENTICADA'
                          : 'AEROGAZE AI • ACESSO DE DEMONSTRAÇÃO',
                      textAlign: TextAlign.center,
                      style: CommandType.label(
                        size: 10,
                        color: CommandColors.dim,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recuperação, biometria e canais de comunicação em construção.',
                      textAlign: TextAlign.center,
                      style: CommandType.body(
                        size: 11,
                        color: CommandColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class AuthBadge extends StatelessWidget {
  const AuthBadge({
    required this.label,
    required this.icon,
    this.color = CommandColors.primary,
    super.key,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: CommandColors.lowest,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: CommandType.label(size: 10, color: color, spacing: .5),
          ),
        ),
      ],
    ),
  );
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({this.compact = false, super.key});
  final bool compact;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: CustomPaint(
        painter: const _AuthCorners(),
        child: SizedBox(
          width: compact ? 112 : 136,
          height: compact ? 112 : 136,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: CommandColors.primary.withValues(alpha: .10),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/branding/aerogaze-logo.png',
                  width: compact ? 80 : 96,
                  height: compact ? 80 : 96,
                  semanticLabel: 'Logo AeroGaze AI',
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthCard extends StatelessWidget {
  const AuthCard({required this.child, this.corners = false, super.key});
  final Widget child;
  final bool corners;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: corners ? const _AuthCorners() : null,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommandColors.panel.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    ),
  );
}

class AuthNotice extends StatelessWidget {
  const AuthNotice(this.message, {this.success = false, super.key});
  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: CommandColors.lowest,
      borderRadius: BorderRadius.circular(12),
      border: Border(
        left: BorderSide(
          width: 3,
          color: success ? CommandColors.primary : CommandColors.blue,
        ),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          success ? Icons.check_circle_outline : Icons.info_outline,
          size: 20,
          color: success ? CommandColors.primary : CommandColors.blue,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: CommandType.body(size: 12, color: CommandColors.muted),
          ),
        ),
      ],
    ),
  );
}

class AuthAction extends StatelessWidget {
  const AuthAction({
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.secondary = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool secondary;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: secondary
            ? null
            : const LinearGradient(
                colors: [CommandColors.primary, CommandColors.primaryContainer],
              ),
        color: secondary ? CommandColors.high : null,
        boxShadow: secondary
            ? null
            : [
                BoxShadow(
                  color: CommandColors.primary.withValues(alpha: .08),
                  blurRadius: 20,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 23,
                    color: secondary
                        ? CommandColors.blue
                        : const Color(0xFF002203),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: CommandType.display(
                        size: 14,
                        spacing: .5,
                        color: secondary
                            ? CommandColors.text
                            : const Color(0xFF002203),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthInput extends StatelessWidget {
  const AuthInput({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.onSubmitted,
    this.fieldKey,
    super.key,
  });
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: CommandType.label(size: 11)),
      const SizedBox(height: 10),
      TextFormField(
        key: fieldKey,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autocorrect: false,
        enableSuggestions: !obscureText,
        maxLines: maxLines,
        onFieldSubmitted: onSubmitted,
        textInputAction: onSubmitted == null
            ? TextInputAction.next
            : TextInputAction.done,
        validator: validator,
        style: CommandType.body(size: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: CommandType.body(size: 13, color: CommandColors.dim),
          filled: true,
          fillColor: CommandColors.lowest,
          prefixIcon: Icon(icon, color: CommandColors.muted, size: 22),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: CommandColors.high, width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: CommandColors.primary, width: 2),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: CommandColors.error, width: 2),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: CommandColors.error, width: 2),
          ),
          errorMaxLines: 3,
        ),
      ),
    ],
  );
}

class AuthHeading extends StatelessWidget {
  const AuthHeading(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: CommandType.display(size: 25),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 12),
        Text(
          subtitle!,
          textAlign: TextAlign.center,
          style: CommandType.body(size: 13, color: CommandColors.muted),
        ),
      ],
      const SizedBox(height: 24),
    ],
  );
}

class _AuthGrid extends CustomPainter {
  const _AuthGrid();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = CommandColors.muted.withValues(alpha: .035);
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_AuthGrid oldDelegate) => false;
}

class _AuthCorners extends CustomPainter {
  const _AuthCorners();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CommandColors.primary.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const length = 12.0;
    for (final corner in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      final dx = corner.dx == 0 ? length : -length;
      final dy = corner.dy == 0 ? length : -length;
      canvas.drawLine(corner, corner.translate(dx, 0), paint);
      canvas.drawLine(corner, corner.translate(0, dy), paint);
    }
  }

  @override
  bool shouldRepaint(_AuthCorners oldDelegate) => false;
}
