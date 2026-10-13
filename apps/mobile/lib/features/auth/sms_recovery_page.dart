import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/design_system.dart';
import 'auth_widgets.dart';
import 'support_page.dart';

class SmsRecoveryPage extends StatefulWidget {
  const SmsRecoveryPage({
    required this.onSignIn,
    this.initialOperator = '',
    super.key,
  });
  final ValueChanged<String> onSignIn;
  final String initialOperator;
  static const demoCode = '123456';
  @override
  State<SmsRecoveryPage> createState() => _SmsRecoveryPageState();
}

class _SmsRecoveryPageState extends State<SmsRecoveryPage> {
  final _form = GlobalKey<FormState>();
  late final _operator = TextEditingController(text: widget.initialOperator);
  final _phone = TextEditingController();
  final _terminal = TextEditingController();
  final _digits = List.generate(6, (_) => TextEditingController());
  final _focus = List.generate(6, (_) => FocusNode());
  bool _satellite = false;
  bool _sent = false;
  String? _error;

  void _send() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    for (final controller in _digits) {
      controller.clear();
    }
    setState(() {
      _sent = true;
      _error = null;
    });
  }

  void _selectChannel(bool satellite) {
    if (_satellite == satellite) return;
    for (final controller in _digits) {
      controller.clear();
    }
    setState(() {
      _satellite = satellite;
      _sent = false;
      _error = null;
    });
  }

  void _digitChanged(int index, String value) {
    if (value.length > 1) {
      final chars = value.split('');
      for (
        var offset = 0;
        offset < chars.length && index + offset < 6;
        offset++
      ) {
        _digits[index + offset].text = chars[offset];
      }
      _focus[(index + chars.length).clamp(0, 5)].requestFocus();
    } else if (value.isNotEmpty && index < 5) {
      _focus[index + 1].requestFocus();
    }
    if (_error != null) setState(() => _error = null);
  }

  void _validate() {
    if (!_sent) {
      setState(() => _error = 'Primeiro simule o envio do código.');
      return;
    }
    if (!_form.currentState!.validate()) return;
    if (_digits.map((controller) => controller.text).join() !=
        SmsRecoveryPage.demoCode) {
      setState(
        () => _error = 'Código incorreto. Use 123456 nesta demonstração.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onSignIn(_operator.text.trim());
  }

  @override
  void dispose() {
    _operator.dispose();
    _phone.dispose();
    _terminal.dispose();
    for (final controller in _digits) {
      controller.dispose();
    }
    for (final focus in _focus) {
      focus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthFrame(
    onBack: () => Navigator.of(context).pop(),
    children: [
      const SizedBox(height: 20),
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CommandColors.high,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.satellite_alt,
            size: 36,
            color: CommandColors.primary,
          ),
        ),
      ),
      const SizedBox(height: 20),
      const AuthHeading(
        'RECUPERAÇÃO VIA SMS / SATÉLITE',
        subtitle:
            'Demonstração do fluxo de recuperação por código de seis dígitos.',
      ),
      Row(
        children: [
          Expanded(
            child: _channel(false, Icons.cell_tower, 'CHIP CELULAR\n(4G/5G)'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _channel(true, Icons.satellite_alt, 'SATÉLITE / LORA'),
          ),
        ],
      ),
      const SizedBox(height: 18),
      AuthCard(
        corners: true,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthInput(
                label: 'MATRÍCULA / ID DO OPERADOR',
                controller: _operator,
                fieldKey: const ValueKey('sms-operator'),
                icon: Icons.badge_outlined,
                hint: 'Matrícula ou usuário',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o usuário da demonstração.'
                    : null,
              ),
              const SizedBox(height: 22),
              AuthInput(
                label: 'TELEFONE / SAT-PHONE',
                controller: _phone,
                fieldKey: const ValueKey('sms-phone'),
                icon: Icons.phone_outlined,
                hint: '+55 (00) 00000-0000',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null ||
                        value.replaceAll(RegExp(r'\D'), '').length < 10
                    ? 'Informe um telefone com DDD para a simulação.'
                    : null,
              ),
              if (_satellite) ...[
                const SizedBox(height: 22),
                AuthInput(
                  label: 'IDENTIFICAÇÃO DO TERMINAL SATÉLITE',
                  controller: _terminal,
                  fieldKey: const ValueKey('sms-terminal'),
                  icon: Icons.router_outlined,
                  hint: 'Terminal de demonstração',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o terminal para a simulação.'
                      : null,
                ),
              ],
              const SizedBox(height: 22),
              const AuthNotice(
                'SMS, satélite e LoRa estão em construção. Este fluxo não transmite mensagens ou detecta equipamentos.',
              ),
              const SizedBox(height: 22),
              AuthAction(
                key: const ValueKey('sms-send'),
                label: 'TRANSMITIR CÓDIGO VIA SMS / SATÉLITE',
                icon: Icons.mark_email_unread_outlined,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      AuthCard(
        corners: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CÓDIGO DE ACESSO • DEMONSTRAÇÃO',
              style: CommandType.label(size: 10, color: CommandColors.primary),
            ),
            const SizedBox(height: 16),
            if (_sent) ...[
              const AuthNotice(
                'Envio simulado. Nenhum SMS foi enviado. Código de demonstração: 123456.',
                success: true,
              ),
              const SizedBox(height: 18),
            ],
            Row(
              children: [
                for (var i = 0; i < 6; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      key: ValueKey('otp-$i'),
                      controller: _digits[i],
                      focusNode: _focus[i],
                      enabled: _sent,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textInputAction: i == 5
                          ? TextInputAction.done
                          : TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onChanged: (value) => _digitChanged(i, value),
                      onSubmitted: (_) {
                        if (i == 5) _validate();
                      },
                      style: CommandType.display(
                        size: 22,
                        color: CommandColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '-',
                        filled: true,
                        fillColor: CommandColors.lowest,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: CommandColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                key: const ValueKey('otp-error'),
                style: CommandType.body(size: 12, color: CommandColors.error),
              ),
            ],
            const SizedBox(height: 18),
            AuthAction(
              key: const ValueKey('sms-validate'),
              secondary: true,
              label: 'VALIDAR CÓDIGO E ACESSAR',
              icon: Icons.verified_outlined,
              onPressed: _validate,
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('sms-resend'),
              onPressed: _sent ? _send : null,
              child: const Text('Reenviar código de demonstração'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SupportPage(
                    onSignIn: widget.onSignIn,
                    operatorName: _operator.text.trim(),
                  ),
                ),
              ),
              child: const Text('Solicitar apoio ao centro de comando'),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _channel(bool satellite, IconData icon, String title) => Semantics(
    selected: _satellite == satellite,
    button: true,
    child: Material(
      color: _satellite == satellite
          ? CommandColors.high
          : CommandColors.lowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _satellite == satellite
              ? CommandColors.primary
              : Colors.transparent,
        ),
      ),
      child: InkWell(
        key: ValueKey(satellite ? 'channel-satellite' : 'channel-cellular'),
        onTap: () => _selectChannel(satellite),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(
                icon,
                color: _satellite == satellite
                    ? CommandColors.primary
                    : CommandColors.muted,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: CommandType.label(
                  size: 10,
                  color: _satellite == satellite
                      ? CommandColors.primary
                      : CommandColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
