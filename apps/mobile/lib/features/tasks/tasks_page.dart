import 'package:flutter/material.dart';

import '../../app/design_system.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _query = '';
  static const _titles = [
    'Aplicação de Fungicida Setor B',
    'Manejo de Bovino #TX-012',
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('tasks-scroll'),
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 7,
              child: Text(
                'Central de Tarefas',
                style: CommandType.display(size: 23),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 4,
              child: Text(
                'SINCRONIZADO: AGORA',
                style: CommandType.label(
                  size: 9,
                  color: const Color(0xFF719968),
                  spacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          key: const ValueKey('task-search'),
          onChanged: (value) => setState(() => _query = value.toLowerCase()),
          style: CommandType.body(size: 14),
          decoration: InputDecoration(
            hintText: 'Buscar tarefas ou ordens...',
            hintStyle: CommandType.body(
              size: 14,
              color: const Color(0xFF394037),
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: Color(0xFF4A5744),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            filled: true,
            fillColor: CommandColors.lowest,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: CommandColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'TAREFAS PRIORITÁRIAS',
                style: CommandType.label(
                  size: 13,
                  color: CommandColors.dim,
                  spacing: 1.2,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Informações das tarefas',
              style: IconButton.styleFrom(
                minimumSize: const Size(24, 24),
                maximumSize: const Size(24, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              icon: const Icon(
                Icons.more_horiz,
                size: 20,
                color: CommandColors.dim,
              ),
              onPressed: () => showDemoDetail(
                context,
                'Tarefas prioritárias',
                'Duas ordens ilustrativas ligam a inspeção do campo à ação. '
                    'O estado de sincronização apresentado também é parte da referência visual.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_titles[0].toLowerCase().contains(_query)) ...[
          _PriorityTask(
            title: _titles[0],
            subtitle: 'Ordem AI #DRN-882 • Área Sul 14ha',
            priority: 'CRÍTICA',
            color: CommandColors.error,
            icon: Icons.precision_manufacturing,
            onTap: () => showDemoDetail(
              context,
              _titles[0],
              'Ordem AI #DRN-882. Área Sul: 14ha. '
              'Horário de referência: 07:30 AM. Status: pendente.',
            ),
            state: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 12,
                  color: CommandColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  '07:30 AM',
                  style: CommandType.body(
                    size: 10,
                    color: CommandColors.primary,
                    weight: 700,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.more_horiz,
                  size: 12,
                  color: CommandColors.dim,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Pendente',
                    style: CommandType.body(
                      size: 10,
                      color: CommandColors.dim,
                      weight: 700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_titles[1].toLowerCase().contains(_query))
          _PriorityTask(
            title: _titles[1],
            subtitle: 'Inspeção Sanitária • Curral Central',
            priority: 'ALTA',
            color: CommandColors.primary,
            icon: Icons.pets,
            onTap: () => showDemoDetail(
              context,
              _titles[1],
              'Inspeção sanitária ilustrativa no Curral Central. '
              'Status: em progresso. Nenhuma alteração sanitária é registrada nesta prévia.',
            ),
            state: Row(
              children: [
                const Icon(Icons.sync, size: 13, color: CommandColors.blue),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Em Progresso',
                    style: CommandType.body(
                      size: 10,
                      color: CommandColors.blue,
                      weight: 700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!_titles.any((title) => title.toLowerCase().contains(_query)))
          CommandPanel(
            child: Text(
              'Nenhuma tarefa encontrada.',
              style: CommandType.body(color: CommandColors.muted),
            ),
          ),
        const SizedBox(height: 28),
        Text(
          'CRONOGRAMA DO DIA',
          style: CommandType.label(
            size: 13,
            color: CommandColors.dim,
            spacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        const _TimelineItem(
          time: '09:00 - 10:30',
          title: 'Análise Foliar - Lote G',
          tag: 'Média',
          active: true,
          progress: .34,
          icon: Icons.biotech,
        ),
        const _TimelineItem(
          time: '11:00 - 12:00',
          title: 'Abastecimento Frota Drone',
          tag: 'Rotina',
          icon: Icons.ev_station,
        ),
        const _TimelineItem(
          time: 'FINALIZADA • 06:45',
          title: 'Calibração Sensor Solo',
          completed: true,
        ),
      ],
    ),
  );
}

class _PriorityTask extends StatelessWidget {
  const _PriorityTask({
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.color,
    required this.icon,
    required this.state,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String priority;
  final Color color;
  final IconData icon;
  final Widget state;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: CommandPanel(
      accent: color.withValues(alpha: .65),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 26, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: CommandType.body(size: 13, weight: 700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priority,
                        style: CommandType.display(size: 8, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: CommandType.body(size: 12, color: CommandColors.muted),
                ),
                const SizedBox(height: 14),
                state,
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.title,
    this.tag,
    this.icon,
    this.active = false,
    this.completed = false,
    this.progress,
  });
  final String time;
  final String title;
  final String? tag;
  final IconData? icon;
  final bool active;
  final bool completed;
  final double? progress;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 32,
          child: Stack(
            children: [
              Positioned(
                left: 10,
                top: 8,
                bottom: 0,
                child: Container(width: 2, color: CommandColors.high),
              ),
              Positioned(
                left: 6,
                top: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active || completed
                        ? CommandColors.primary
                        : CommandColors.dim,
                    border: Border.all(
                      color: CommandColors.background,
                      width: 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: CommandColors.primary.withValues(
                                alpha: .3,
                              ),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check,
                          size: 7,
                          color: CommandColors.lowest,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: completed ? 0 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  time,
                  style: CommandType.body(
                    size: 10,
                    color: completed
                        ? const Color(0xFF608756)
                        : const Color(0xFF4B5945),
                    weight: 700,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: active ? 1 : .55,
                  child: CommandPanel(
                    color: completed
                        ? CommandColors.lowest
                        : CommandColors.panel,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: CommandType.body(size: 13, weight: 600)
                                    .copyWith(
                                      decoration: completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                            ),
                            if (icon != null)
                              Icon(
                                icon,
                                size: 15,
                                color: active
                                    ? CommandColors.blue
                                    : CommandColors.dim,
                              ),
                          ],
                        ),
                        if (tag != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: CommandColors.high,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag!,
                                  style: CommandType.body(
                                    size: 10,
                                    color: CommandColors.muted,
                                  ),
                                ),
                              ),
                              if (progress != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      color: CommandColors.blue,
                                      backgroundColor: CommandColors.high,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
