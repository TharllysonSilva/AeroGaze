import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import 'auth_widgets.dart';
import 'sms_recovery_page.dart';
import 'support_page.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({
    required this.onSignIn,
    this.initialOperator = '',
    super.key,
  });
  final ValueChanged<String> onSignIn;
  final String initialOperator;
  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _form = GlobalKey<FormState>();
  late final _operator = TextEditingController(text: widget.initialOperator);
  final _email = TextEditingController();
  bool _requested = false;

  void _request() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _requested = true);
  }

  void _sms() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SmsRecoveryPage(
        onSignIn: widget.onSignIn,
        initialOperator: _operator.text.trim(),
      ),
    ),
  );

  void _support() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SupportPage(
        onSignIn: widget.onSignIn,
        operatorName: _operator.text.trim(),
      ),
    ),
  );

  @override
  void dispose() {
    _operator.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthFrame(
    onBack: () => Navigator.of(context).pop(),
    children: [
      const AuthBrand(),
      Center(
        child: AuthBadge(label: 'AEROGAZE • ACESSO DE CAMPO', icon: Icons.key),
      ),
      const SizedBox(height: 22),
      const AuthHeading(
        'RECUPERAR CHAVE TÁTICA',
        subtitle:
            'Informe sua matrícula ou e-mail para demonstrar a recuperação da senha de acesso.',
      ),
      AuthCard(
        corners: true,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PROTOCOLO DE RECUPERAÇÃO // DEMO',
                style: CommandType.label(
                  color: CommandColors.primary,
                  size: 10,
                ),
              ),
              const SizedBox(height: 24),
              AuthInput(
                label: 'MATRÍCULA / ID DO OPERADOR (OPCIONAL)',
                controller: _operator,
                icon: Icons.badge_outlined,
                fieldKey: const ValueKey('recovery-operator'),
                hint: 'Matrícula ou usuário',
              ),
              const SizedBox(height: 22),
              AuthInput(
                label: 'E-MAIL CADASTRADO',
                controller: _email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                fieldKey: const ValueKey('recovery-email'),
                hint: 'voce@exemplo.com',
                validator: (value) =>
                    value == null ||
                        !RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value.trim())
                    ? 'Informe um e-mail válido para a simulação.'
                    : null,
                onSubmitted: (_) => _request(),
              ),
              const SizedBox(height: 22),
              const AuthNotice(
                'Serviço de recuperação em construção. Nenhum e-mail ou token real será enviado.',
              ),
              const SizedBox(height: 22),
              AuthAction(
                key: const ValueKey('recovery-submit'),
                label: 'ENVIAR CHAVE PARA E-MAIL',
                icon: Icons.send_outlined,
                onPressed: _request,
              ),
              if (_requested) ...[
                const SizedBox(height: 18),
                const AuthNotice(
                  'Solicitação simulada concluída. Nenhum e-mail foi enviado e nenhuma senha foi alterada.',
                  success: true,
                ),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 28),
      Text(
        'MÉTODOS ALTERNATIVOS DE CONTINGÊNCIA',
        textAlign: TextAlign.center,
        style: CommandType.label(size: 10, color: CommandColors.dim),
      ),
      const SizedBox(height: 16),
      AuthAction(
        key: const ValueKey('recovery-sms'),
        secondary: true,
        label: 'RECEBER VIA SMS / DISPOSITIVO SATÉLITE',
        icon: Icons.cell_tower,
        onPressed: _sms,
      ),
      const SizedBox(height: 14),
      AuthAction(
        key: const ValueKey('recovery-support'),
        secondary: true,
        label: 'SOLICITAR APOIO AO CENTRO DE COMANDO',
        icon: Icons.headset_mic_outlined,
        onPressed: _support,
      ),
      const SizedBox(height: 22),
      TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Voltar para login'),
      ),
    ],
  );
}
