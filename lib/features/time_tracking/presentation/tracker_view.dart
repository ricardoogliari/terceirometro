import 'package:flutter/material.dart';

import '../../shared/presentation/chrono_shell.dart';
import '../domain/time_entry.dart';
import 'time_tracking_view_model.dart';

class TrackerView extends StatelessWidget {
  const TrackerView({required this.viewModel, super.key});

  final TimeTrackingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => ChronoShell(
        page: ChronoPage.tracker,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Overview(viewModel: viewModel),
                  const SizedBox(height: 24),
                  _CurrentSession(viewModel: viewModel),
                  const SizedBox(height: 28),
                  _CompletedTasks(entries: viewModel.recentEntries),
                  const SizedBox(height: 24),
                  const Text(
                    'Estado gerenciado pelo ViewModel  •  Persistência via repositório',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF737B93), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.viewModel});

  final TimeTrackingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 860;
    final focusCard = _LimitCard(viewModel: viewModel);
    final alertCard = _OvertimeCard(viewModel: viewModel);
    return narrow
        ? Column(children: [focusCard, const SizedBox(height: 16), alertCard])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: focusCard),
              const SizedBox(width: 18),
              Expanded(flex: 3, child: alertCard),
            ],
          );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.viewModel});

  final TimeTrackingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final progress = viewModel.completion;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF42D6A3)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carga Horária Diária',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Meta fixa: 08:00:00  •  Limite CLT / Contrato',
                        style: TextStyle(
                          color: Color(0xFF9298AD),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _Pill(
                  label: '${(progress * 100).toStringAsFixed(1)}% concluído',
                  color: const Color(0xFF42D6A3),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Text(
                  _formatHours(viewModel.totalWorked),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const Text(
                  '/ 08h 00m',
                  style: TextStyle(
                    color: Color(0xFF9298AD),
                    fontFamily: 'monospace',
                  ),
                ),
                _Pill(
                  label:
                      '${_formatHours(viewModel.remainingTime)} restantes para atingir o teto',
                  color: const Color(0xFFF5AE4E),
                  icon: Icons.hourglass_bottom,
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: const Color(0xFF303950),
                color: const Color(0xFF42D6A3),
              ),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                _Milestone(label: '00:00 (Início)', color: Color(0xFF9298AD)),
                _Milestone(
                  label: '04:00 (Intervalo)',
                  color: Color(0xFF9298AD),
                ),
                _Milestone(label: '05:18 (Atual)', color: Color(0xFF42D6A3)),
                _Milestone(label: '07:30 (Aviso)', color: Color(0xFFF5AE4E)),
                _Milestone(
                  label: '08:00 (Teto Máx.)',
                  color: Color(0xFF9298AD),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OvertimeCard extends StatelessWidget {
  const _OvertimeCard({required this.viewModel});

  final TimeTrackingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notification_important_outlined,
                  color: Color(0xFFF5AE4E),
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proteção Contra Hora Extra',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Alertas ao atingir 7h 45m para evitar passivo de horas excedentes.',
                        style: TextStyle(
                          color: Color(0xFFB7BDD2),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: const Text('Bloqueio Automático'),
              subtitle: const Text(
                'Notificar ao atingir 8h',
                style: TextStyle(color: Color(0xFF9298AD)),
              ),
              value: viewModel.automaticLockEnabled,
              onChanged: (_) => viewModel.toggleAutomaticLock(),
              activeTrackColor: const Color(0xFF00A982),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentSession extends StatefulWidget {
  const _CurrentSession({required this.viewModel});

  final TimeTrackingViewModel viewModel;

  @override
  State<_CurrentSession> createState() => _CurrentSessionState();
}

class _CurrentSessionState extends State<_CurrentSession> {
  late final TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.viewModel.currentTask);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Pill(
                  label: viewModel.isRunning ? 'GRAVANDO TEMPO' : 'PAUSADO',
                  color: viewModel.isRunning
                      ? const Color(0xFF42D6A3)
                      : const Color(0xFFF5AE4E),
                  icon: Icons.circle,
                ),
                const Text(
                  'Sessão iniciada às 14:32',
                  style: TextStyle(
                    color: Color(0xFF9298AD),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Projeto:',
                  style: TextStyle(color: Color(0xFF9298AD)),
                ),
                for (final category in [
                  'Desenvolvimento',
                  'Reunião',
                  'Code Review',
                  'Design',
                ])
                  _CategoryChip(
                    category: category,
                    selected: viewModel.selectedCategory == category,
                    onTap: () => viewModel.selectCategory(category),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF10182B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 640;
                  final task = TextField(
                    controller: _taskController,
                    onChanged: viewModel.updateCurrentTask,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Em que você está trabalhando agora?',
                      labelStyle: TextStyle(
                        color: Color(0xFF9298AD),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  );
                  final timer = Column(
                    crossAxisAlignment: compact
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatClock(viewModel.sessionDuration),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        'Tempo desta sessão',
                        style: TextStyle(
                          color: Color(0xFF9298AD),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  );
                  return compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [task, const SizedBox(height: 12), timer],
                        )
                      : Row(
                          children: [
                            Expanded(child: task),
                            const SizedBox(width: 18),
                            timer,
                          ],
                        );
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: viewModel.toggleTimer,
                      icon: Icon(
                        viewModel.isRunning ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(viewModel.isRunning ? 'Pausar' : 'Retomar'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _taskController.clear();
                        viewModel.updateCurrentTask('');
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Descartar'),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {
                    viewModel.toggleTimer();
                    _taskController.text = 'Nova tarefa';
                    viewModel.updateCurrentTask('Nova tarefa');
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Concluir e Iniciar Nova Tarefa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedTasks extends StatelessWidget {
  const _CompletedTasks({required this.entries});

  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tarefas Concluídas Hoje',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                _Pill(
                  label: '${entries.length} finalizadas',
                  color: const Color(0xFFB7BDD2),
                ),
              ],
            ),
            const Text(
              'Soma Registrada: 03h 36m',
              style: TextStyle(
                color: Color(0xFF42D6A3),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const _EntryRow(header: true),
              for (final entry in entries) _EntryRow(entry: entry),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/report'),
            icon: const Icon(Icons.open_in_new, size: 17),
            label: const Text('Ver diário completo'),
          ),
        ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({this.entry, this.header = false});

  final TimeEntry? entry;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: header ? const Color(0xFF9298AD) : const Color(0xFFE4E9FF),
      fontSize: 12,
      fontWeight: header ? FontWeight.w600 : FontWeight.normal,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF252E43))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              header ? 'TAREFA / DESCRIÇÃO' : entry!.title,
              style: style,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(header ? 'CATEGORIA' : entry!.category, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(
              header ? 'HORÁRIO' : '${entry!.start} - ${entry!.end}',
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              header ? 'DURAÇÃO' : _formatHours(entry!.duration),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final String category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Material(
      color: selected ? const Color(0xFF5142DE) : const Color(0xFF232C40),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 6),
              Text(category, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(color: color, fontSize: 11, fontFamily: 'monospace'),
  );
}

String _formatHours(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '${hours}h ${minutes}m';
}

String _formatClock(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

Color _categoryColor(String category) => switch (category) {
  'Reunião' || 'Reuniões' => const Color(0xFFF5AE4E),
  'Code Review' => const Color(0xFF42D6A3),
  'Design' || 'Design System' => const Color(0xFFB6A7FF),
  _ => const Color(0xFFE4E9FF),
};
