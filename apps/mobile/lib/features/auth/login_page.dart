import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import '../../core/demo/command_demo.dart';
import 'auth_widgets.dart';
import 'recovery_page.dart';
import 'support_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onSignIn, this.authenticate, super.key});
  final Future<void> Function(String email, String password)? authenticate;
  final ValueChanged<String> onSignIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _operator = TextEditingController();
  final _password = TextEditingController();
  bool _visible = false;

  bool _busy = false;
  String? _error;
  void _signIn() async {
    if (_busy) return;
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (widget.authenticate == null) {
      widget.onSignIn(_operator.text.trim());
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.authenticate!(_operator.text.trim(), _password.text);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _offline() {
    FocusScope.of(context).unfocus();
    widget.onSignIn(
      _operator.text.trim().isEmpty
          ? 'Operador de demonstração'
          : _operator.text.trim(),
    );
  }

  void _recover() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RecoveryPage(
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
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthFrame(
    live: widget.authenticate != null,
    children: [
      const AuthBrand(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'AEROGAZE',
              style: CommandType.display(size: 37, spacing: -1.5),
            ),
          ),
          const SizedBox(width: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: CommandColors.high,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'AI',
              style: CommandType.display(
                size: 26,
                color: CommandColors.primary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Inteligência preditiva do solo ao bem-estar animal',
        textAlign: TextAlign.center,
        style: CommandType.body(size: 13, color: CommandColors.muted),
      ),
      const SizedBox(height: 22),
      AuthNotice(
        widget.authenticate == null
            ? 'Acesso de demonstração: entre com qualquer usuário e senha preenchidos. Nenhuma credencial é enviada ou armazenada.'
            : 'Acesso autenticado à API AeroGaze. Use seu e-mail cadastrado. A senha é enviada por HTTPS e não é salva.',
      ),
      if (_error != null) ...[const SizedBox(height: 12), AuthNotice(_error!)],
      const SizedBox(height: 18),
      AuthCard(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.authenticate == null
                    ? 'PROTOCOLO DE ACESSO // DEMONSTRAÇÃO'
                    : 'ACESSO REAL // API AEROGAZE',
                style: CommandType.label(size: 9, color: CommandColors.primary),
              ),
              const SizedBox(height: 22),
              if (widget.authenticate == null) ...[
                Text(
                  'UNIDADE OPERACIONAL / FAZENDA DEMO',
                  style: CommandType.label(size: 11),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: const ValueKey('login-farm'),
                  initialValue: CommandDemo.farmName,
                  isExpanded: true,
                  dropdownColor: CommandColors.lowest,
                  style: CommandType.body(size: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CommandColors.lowest,
                    prefixIcon: const Icon(
                      Icons.domain,
                      color: CommandColors.primary,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: CommandDemo.farmName,
                      child: Text(
                        CommandDemo.farmName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (_) {},
                ),
              ],
              const SizedBox(height: 20),
              AuthAction(
                label: 'ENTRAR COM BIOMETRIA / FACE ID',
                icon: Icons.fingerprint,
                onPressed: () => showDemoDetail(
                  context,
                  'Biometria em construção',
                  'Biometria e Face ID não estão conectados. Use usuário e senha para acessar a demonstração.',
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'OU USE SUA CREDENCIAL',
                textAlign: TextAlign.center,
                style: CommandType.label(size: 10, color: CommandColors.dim),
              ),
              const SizedBox(height: 22),
              AuthInput(
                label: widget.authenticate == null
                    ? 'MATRÍCULA / ID DO OPERADOR'
                    : 'E-MAIL CADASTRADO',
                controller: _operator,
                fieldKey: const ValueKey('login-operator'),
                icon: Icons.badge_outlined,
                hint: widget.authenticate == null
                    ? 'Seu usuário, matrícula ou e-mail'
                    : 'voce@empresa.com',
                keyboardType: widget.authenticate == null
                    ? null
                    : TextInputType.emailAddress,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe seu usuário ou e-mail.'
                    : null,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const ValueKey('login-recover'),
                  onPressed: _recover,
                  child: Text(
                    'Recuperar chave',
                    style: CommandType.body(
                      size: 12,
                      color: CommandColors.primary,
                    ),
                  ),
                ),
              ),
              AuthInput(
                label: 'CHAVE DE ACESSO TÁTICA',
                controller: _password,
                fieldKey: const ValueKey('login-password'),
                icon: Icons.lock_outline,
                obscureText: !_visible,
                hint: 'Sua senha de acesso',
                suffix: IconButton(
                  tooltip: _visible ? 'Ocultar senha' : 'Mostrar senha',
                  onPressed: () => setState(() => _visible = !_visible),
                  icon: Icon(
                    _visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: CommandColors.muted,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe qualquer senha para a demonstração.'
                    : null,
                onSubmitted: (_) => _signIn(),
              ),
              const SizedBox(height: 22),
              AuthAction(
                key: const ValueKey('login-submit'),
                label: _busy ? 'CONECTANDO À API...' : 'AUTENTICAR OPERADOR',
                icon: Icons.key,
                onPressed: _busy ? null : _signIn,
              ),
              const SizedBox(height: 22),
              AuthAction(
                key: const ValueKey('login-offline'),
                secondary: true,
                label: 'MODO OFFLINE DE CAMPO',
                icon: Icons.cloud_off,
                onPressed: _offline,
              ),
              const SizedBox(height: 8),
              Text(
                'Abre apenas a demonstração local. Captura e fila offline em construção.',
                style: CommandType.body(size: 11, color: CommandColors.dim),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in const [
            ('DRONES', 'EM CONSTRUÇÃO'),
            ('TELEMETRIA', 'SIMULADA'),
            ('REBANHO', 'DEMONSTRAÇÃO'),
          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: CommandColors.lowest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(item.$1, style: CommandType.label(size: 8)),
                      const SizedBox(height: 5),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: CommandType.label(
                          size: 8,
                          color: CommandColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      TextButton.icon(
        key: const ValueKey('login-support'),
        onPressed: _support,
        icon: const Icon(Icons.headset_mic_outlined, size: 18),
        label: const Text('Solicitar apoio ao comando'),
      ),
    ],
  );
}
