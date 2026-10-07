import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/map/map_page.dart';
import '../features/scouting/scouting_page.dart';
import '../features/herd/herd_page.dart';
import '../features/tasks/tasks_page.dart';
import 'app_environment.dart';
import 'design_system.dart';
import 'startup_screen.dart';

class AeroGazeApp extends StatelessWidget {
  const AeroGazeApp({
    this.environment = AppEnvironment.dev,
    this.initialTab = 0,
    this.showSplash = true,
    super.key,
  });
  final AppEnvironment environment;
  final int initialTab;
  final bool showSplash;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: environment.appName,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: CommandColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CommandColors.primary,
        secondary: CommandColors.blue,
        surface: CommandColors.panel,
        onSurface: CommandColors.text,
        error: CommandColors.error,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: CommandColors.text,
        displayColor: CommandColors.text,
      ),
    ),
    home: showSplash
        ? StartupScreen(
            imagesToPrecache: const [
              AssetImage('assets/reference/aerogaze_dashboard_pt.png'),
              AssetImage('assets/reference/aerogaze_mapa_pt.png'),
              AssetImage('assets/reference/aerogaze_scouting_pt.png'),
              AssetImage('assets/reference/aerogaze_rebanho_pt.png'),
            ],
            child: FieldShell(environment: environment, initialTab: initialTab),
          )
        : FieldShell(environment: environment, initialTab: initialTab),
  );
}

class FieldShell extends StatefulWidget {
  const FieldShell({required this.environment, this.initialTab = 0, super.key});
  final AppEnvironment environment;
  final int initialTab;
  @override
  State<FieldShell> createState() => _FieldShellState();
}

class _FieldShellState extends State<FieldShell> {
  late int _index = widget.initialTab;
  late final Set<int> _visited = {widget.initialTab};

  void _select(int index) => setState(() {
    _visited.add(index);
    _index = index;
  });

  Widget _page(int index) => switch (index) {
    0 => DashboardPage(
      onOpenHerd: () => _select(3),
      onOpenMap: () => _select(1),
    ),
    1 => const MapPage(),
    2 => ScoutingPage(onOpenTasks: () => _select(4)),
    3 => const HerdPage(),
    4 => const TasksPage(),
    _ => throw RangeError.index(index, CommandNavigation.labels),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          CommandHeader(environment: widget.environment),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                for (var i = 0; i < CommandNavigation.labels.length; i++)
                  RepaintBoundary(
                    child: _visited.contains(i)
                        ? _page(i)
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: _index == 0 || _index == 4
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_index == 4 ? 14 : 12),
              boxShadow: [
                BoxShadow(
                  color: CommandColors.primary.withValues(alpha: .18),
                  blurRadius: 24,
                ),
              ],
              gradient: const LinearGradient(
                colors: [CommandColors.primary, CommandColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (_index == 0) {
                    _select(2);
                  } else {
                    showDemoDetail(
                      context,
                      'Nova tarefa',
                      'O cadastro de ordens de serviço será ligado '
                          'à API e à fila offline. A tela atual apresenta as tarefas de referência.',
                    );
                  }
                },
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    _index == 4 ? Icons.add : Icons.add_task,
                    size: _index == 4 ? 36 : 28,
                    color: const Color(0xFF002203),
                  ),
                ),
              ),
            ),
          )
        : null,
    bottomNavigationBar: CommandNavigation(index: _index, onSelect: _select),
  );
}

class CommandHeader extends StatelessWidget {
  const CommandHeader({required this.environment, super.key});
  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 30, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;
          return Row(
            children: [
              const Icon(
                Icons.satellite_alt,
                color: CommandColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AEROGAZE\nCOMMAND',
                  style: CommandType.display(
                    size: compact ? 16 : 19,
                    color: CommandColors.primary,
                    spacing: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Sistema em demonstração. Dados fictícios.',
                button: true,
                child: InkWell(
                  onTap: () => showDemoDetail(
                    context,
                    'AeroGaze Command',
                    'Ambiente ${environment.name}. Painel, mapa, scouting, rebanho e tarefas '
                        'usam dados ilustrativos das referências fornecidas. Sensores e IA não estão conectados.',
                  ),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: compact ? 80 : 88,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF202B21),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3B5639)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 5,
                          height: 8,
                          decoration: BoxDecoration(
                            color: CommandColors.primaryContainer.withValues(
                              alpha: .65,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SISTEMA\nATIVO',
                          style: CommandType.display(
                            size: 10,
                            color: CommandColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final height in [7.0, 11.0, 16.0])
                        Container(
                          width: 3,
                          height: height,
                          margin: const EdgeInsets.only(right: 2),
                          color: CommandColors.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'DEMO',
                    style: CommandType.label(
                      size: 6,
                      color: CommandColors.dim,
                      spacing: .4,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}

class CommandNavigation extends StatelessWidget {
  const CommandNavigation({
    required this.index,
    required this.onSelect,
    super.key,
  });
  final int index;
  final ValueChanged<int> onSelect;
  static const labels = ['PAINEL', 'MAPA', 'SCOUT', 'REBANHO', 'TAREFAS'];
  static const icons = [
    Icons.space_dashboard,
    Icons.map,
    Icons.visibility,
    Icons.pets,
    Icons.assignment,
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF101311),
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 8,
                  ),
                  child: Semantics(
                    selected: index == i,
                    button: true,
                    child: Material(
                      color: index == i
                          ? const Color(0xFF1E2B1C)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      child: InkWell(
                        key: ValueKey('nav-$i'),
                        borderRadius: BorderRadius.circular(7),
                        onTap: () => onSelect(i),
                        child: Container(
                          decoration: BoxDecoration(
                            border: index == i
                                ? const Border(
                                    bottom: BorderSide(
                                      color: CommandColors.primary,
                                      width: 2,
                                    ),
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                icons[i],
                                size: 25,
                                color: index == i
                                    ? CommandColors.primary
                                    : const Color(0xFF676B67),
                              ),
                              FittedBox(
                                child: Text(
                                  labels[i],
                                  style: CommandType.label(
                                    size: 10,
                                    color: index == i
                                        ? CommandColors.primary
                                        : const Color(0xFF676B67),
                                    spacing: .1,
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
              ),
          ],
        ),
      ),
    ),
  );
}
