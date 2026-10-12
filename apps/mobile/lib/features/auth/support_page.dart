import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import '../../core/demo/command_demo.dart';
import 'auth_widgets.dart';

enum SupportUrgency { low, medium, critical }

enum SupportChannel { satellite, chat, radio }

class SupportPage extends StatefulWidget {
  const SupportPage({
    required this.onSignIn,
    this.operatorName = '',
    super.key,
  });
  final ValueChanged<String> onSignIn;
  final String operatorName;
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _description = TextEditingController();
  SupportUrgency _urgency = SupportUrgency.medium;
  SupportChannel _channel = SupportChannel.chat;
  bool _submitted = false;

  String get _operator => widget.operatorName.isEmpty
      ? 'Operador de demonstração'
      : widget.operatorName;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
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
            Icons.headset_mic_outlined,
            size: 36,
            color: CommandColors.primary,
          ),
        ),
      ),
      const SizedBox(height: 18),
      const AuthHeading(
        'SOLICITAR APOIO AO COMANDO',
        subtitle:
            'Demonstre uma solicitação ao centro de operações e engenharia agronômica.',
      ),
      AuthCard(
        corners: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CONTEXTO DO OPERADOR • SIMULADO',
              style: CommandType.label(size: 10, color: CommandColors.primary),
            ),
            const SizedBox(height: 20),
            _context('OPERADOR EM CAMPO', _operator, Icons.person_outline),
            const SizedBox(height: 16),
            _context(
              'UNIDADE / TALHÃO',
              '${CommandDemo.farmName} • Talhão B-12',
              Icons.agriculture,
            ),
            const SizedBox(height: 16),
            _context(
              'COORDENADAS DE REFERÊNCIA • SIMULADAS',
              'LAT ${CommandDemo.latitude} • LON ${CommandDemo.longitude}',
              Icons.my_location,
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      Text('NÍVEL DE URGÊNCIA OPERACIONAL', style: CommandType.label(size: 12)),
      const SizedBox(height: 12),
      _urgencyCard(
        SupportUrgency.low,
        'BAIXA',
        'Dúvida operacional / procedimento de manejo',
      ),
      const SizedBox(height: 10),
      _urgencyCard(
        SupportUrgency.medium,
        'MÉDIA',
        'Acesso / chave expirada / revalidação',
      ),
      const SizedBox(height: 10),
      _urgencyCard(
        SupportUrgency.critical,
        'CRÍTICA',
        'Incidente de campo / perda de conexão',
      ),
      const SizedBox(height: 24),
      Text(
        'CANAL PREFERENCIAL DE RESPOSTA',
        style: CommandType.label(size: 12),
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _channelCard(
              SupportChannel.satellite,
              Icons.satellite_alt,
              'VOZ /\nSATÉLITE',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _channelCard(
              SupportChannel.chat,
              Icons.chat_outlined,
              'CHAT\nRÁPIDO',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _channelCard(
              SupportChannel.radio,
              Icons.wifi,
              'RÁDIO\nLORA',
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      AuthInput(
        label: 'DESCRIÇÃO DA OCORRÊNCIA (OPCIONAL)',
        controller: _description,
        fieldKey: const ValueKey('support-description'),
        icon: Icons.edit_note,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        hint: 'Descreva sua dúvida ou ocorrência de demonstração.',
      ),
      const SizedBox(height: 20),
      const AuthNotice(
        'Canal de apoio em construção. Esta demonstração não transmite chamados nem aciona atendimento de emergência.',
      ),
      const SizedBox(height: 18),
      AuthAction(
        key: const ValueKey('support-submit'),
        label: 'TRANSMITIR CHAMADO DE APOIO',
        icon: Icons.send_outlined,
        onPressed: _submit,
      ),
      if (_submitted) ...[
        const SizedBox(height: 16),
        AuthNotice(
          'Chamado simulado: urgência ${_urgencyLabel().toLowerCase()} pelo canal ${_channelLabel()}. Nenhum chamado foi enviado ou salvo.',
          success: true,
        ),
      ],
      const SizedBox(height: 28),
      Text('CANAIS DE CONTINGÊNCIA', style: CommandType.label(size: 12)),
      const SizedBox(height: 12),
      AuthAction(
        secondary: true,
        label: 'CONTATO COM A ENGENHARIA DE CAMPO',
        icon: Icons.phone_outlined,
        onPressed: () => showDemoDetail(
          context,
          'Contato em construção',
          'Nenhum número real de plantão foi cadastrado. Não há ligação telefônica neste protótipo.',
        ),
      ),
      const SizedBox(height: 12),
      AuthAction(
        key: const ValueKey('support-offline'),
        secondary: true,
        label: 'ABRIR MODO OFFLINE DE DEMONSTRAÇÃO',
        icon: Icons.offline_bolt_outlined,
        onPressed: () => widget.onSignIn(_operator),
      ),
    ],
  );

  Widget _context(String label, String value, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: CommandType.label(size: 9, color: CommandColors.dim)),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: CommandColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: CommandType.body(size: 12))),
        ],
      ),
    ],
  );

  Widget _urgencyCard(
    SupportUrgency urgency,
    String title,
    String description,
  ) {
    final selected = _urgency == urgency;
    final color = urgency == SupportUrgency.critical
        ? CommandColors.error
        : CommandColors.primary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? CommandColors.high : CommandColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? CommandColors.primary : Colors.transparent,
          ),
        ),
        child: InkWell(
          key: ValueKey('urgency-${urgency.name}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() {
            _urgency = urgency;
            _submitted = false;
          }),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? color : CommandColors.dim,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: CommandType.display(
                          size: 13,
                          color: selected ? color : CommandColors.text,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: CommandType.body(
                          size: 11,
                          color: CommandColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _channelCard(SupportChannel channel, IconData icon, String label) {
    final selected = _channel == channel;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? CommandColors.high : CommandColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? CommandColors.primary : Colors.transparent,
          ),
        ),
        child: InkWell(
          key: ValueKey('support-channel-${channel.name}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() {
            _channel = channel;
            _submitted = false;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: selected ? CommandColors.primary : CommandColors.muted,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: CommandType.label(
                    size: 9,
                    color: selected
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

  String _urgencyLabel() => switch (_urgency) {
    SupportUrgency.low => 'Baixa',
    SupportUrgency.medium => 'Média',
    SupportUrgency.critical => 'Crítica',
  };
  String _channelLabel() => switch (_channel) {
    SupportChannel.satellite => 'voz/satélite',
    SupportChannel.chat => 'chat rápido',
    SupportChannel.radio => 'rádio LoRa',
  };
}
