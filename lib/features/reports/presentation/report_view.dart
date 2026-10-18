import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/presentation/chrono_shell.dart';
import '../../time_tracking/domain/time_entry.dart';
import '../../time_tracking/presentation/time_tracking_view_model.dart';

class ReportView extends StatelessWidget {
  const ReportView({required this.viewModel, super.key});

  final TimeTrackingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => ChronoShell(
        page: ChronoPage.report,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportHeading(
                    completedCount: viewModel.entries.length,
                    onExport: () => _showExportDialog(context),
                    onAdd: () => _showAddEntryDialog(context),
                  ),
                  const SizedBox(height: 20),
                  _Metrics(viewModel: viewModel),
                  const SizedBox(height: 20),
                  _Timeline(entries: viewModel.chronologicalEntries),
                  const SizedBox(height: 20),
                  _ReportEntries(entries: viewModel.chronologicalEntries),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final summary = viewModel.buildSummary();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description_outlined, color: Color(0xFF42D6A3)),
            SizedBox(width: 12),
            Expanded(child: Text('Resumo em Texto Corrido')),
          ],
        ),
        content: SizedBox(
          width: 680,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Compatível com Google Sheets, Notion, Jira e Excel',
                  style: TextStyle(color: Color(0xFF9298AD)),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  summary,
                  style: const TextStyle(fontFamily: 'monospace', height: 1.6),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Formatado para transferência com delimitadores e horários.',
                  style: TextStyle(color: Color(0xFF9298AD)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: summary));
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resumo copiado para a área de transferência'),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar para Área de Transferência'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddEntryDialog(BuildContext context) async {
    final titleController = TextEditingController();
    var category = 'Desenvolvimento';
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Registro Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Tarefa / descrição',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items:
                    const [
                          'Desenvolvimento',
                          'Reunião',
                          'Code Review',
                          'Design',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setDialogState(() => category = value ?? category),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    if (shouldAdd == true && titleController.text.trim().isNotEmpty) {
      await viewModel.addManualEntry(titleController.text.trim(), category);
    }
    titleController.dispose();
  }
}

class _ReportHeading extends StatelessWidget {
  const _ReportHeading({
    required this.completedCount,
    required this.onExport,
    required this.onAdd,
  });

  final int completedCount;
  final VoidCallback onExport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diário de Tarefas',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '24 de outubro de 2024  •  $completedCount sessões gravadas',
              style: const TextStyle(color: Color(0xFF9298AD)),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.copy),
              label: const Text('Exportar'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Registro Manual'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.viewModel});

  final TimeTrackingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final completedCount = viewModel.entries.length;
    final averageMinutes = completedCount == 0
        ? 0
        : viewModel.registeredTime.inMinutes ~/ completedCount;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1200
        ? 4
        : width >= 700
        ? 2
        : 1;
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: columns == 1 ? 2.8 : 1.7,
      children: [
        _MetricCard(
          label: 'TEMPO TOTAL TRABALHADO',
          value: _formatHours(viewModel.totalWorked),
          detail: '${(viewModel.completion * 100).round()}% da meta diária',
          icon: Icons.timer_outlined,
          color: const Color(0xFF42D6A3),
        ),
        _MetricCard(
          label: 'TAREFAS CONCLUÍDAS',
          value: completedCount.toString().padLeft(2, '0'),
          detail: 'concluídas hoje',
          icon: Icons.task_alt,
          color: const Color(0xFFB6A7FF),
        ),
        _MetricCard(
          label: 'MÉDIA POR TAREFA',
          value: '${averageMinutes.toString().padLeft(2, '0')}min',
          detail: 'pace diário',
          icon: Icons.speed,
          color: const Color(0xFFF5AE4E),
        ),
        _MetricCard(
          label: 'SALDO DO LIMITE DIÁRIO',
          value: _formatHours(viewModel.remainingTime),
          detail: 'limite de 8h 00m',
          icon: Icons.hourglass_bottom,
          color: const Color(0xFF72B7FF),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9298AD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              detail,
              style: const TextStyle(color: Color(0xFF9298AD), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.entries});

  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, color: Color(0xFF42D6A3)),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Distribuição Contínua do Dia',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '08:00 - 18:00',
                  style: TextStyle(
                    color: Color(0xFF9298AD),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 600;
                final labels = [
                  '08:00',
                  '09:00',
                  '10:00',
                  '11:00',
                  '12:00',
                  '13:00',
                  '14:00',
                  '15:00',
                  '16:00',
                  '17:00',
                  '18:00',
                ];
                return Column(
                  children: [
                    if (!narrow)
                      Row(
                        children: [
                          for (final label in labels)
                            Expanded(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9298AD),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (entries.isEmpty)
                      const SizedBox(
                        height: 104,
                        child: Center(
                          child: Text(
                            'Nenhum registro de tempo hoje',
                            style: TextStyle(color: Color(0xFF9298AD)),
                          ),
                        ),
                      )
                    else if (narrow)
                      Column(
                        children: [
                          for (final entry in entries)
                            _TimelineItem(
                              time: '${entry.start} - ${entry.end}',
                              task: entry.title,
                              color: _timelineColor(entry.category),
                            ),
                        ],
                      )
                    else
                      SizedBox(
                        height: 115,
                        child: Stack(
                          children: [
                            for (var index = 0; index < entries.length; index++)
                              _timelineBar(
                                entries[index],
                                index,
                                constraints.maxWidth,
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            if (entries.isNotEmpty)
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  for (final category
                      in entries.map((entry) => entry.category).toSet())
                    _Legend(label: category, color: _timelineColor(category)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _timelineBar(TimeEntry entry, int index, double maxWidth) {
    final parts = entry.start.split(':');
    final startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final relativeStart = startMinutes - 8 * 60;
    final clippedStart = relativeStart.clamp(0, 600);
    final clippedEnd = (relativeStart + entry.duration.inMinutes).clamp(0, 600);
    if (clippedEnd <= clippedStart) return const SizedBox.shrink();

    return Positioned(
      left: maxWidth * (clippedStart / 600),
      top: (14 + (index % 2) * 44).toDouble(),
      width: maxWidth * ((clippedEnd - clippedStart) / 600),
      height: 28,
      child: _TimelineBar(
        label: entry.title,
        color: _timelineColor(entry.category),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.task,
    required this.color,
  });

  final String time;
  final String task;
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: Text(
      time,
      style: const TextStyle(
        color: Color(0xFF9298AD),
        fontFamily: 'monospace',
        fontSize: 11,
      ),
    ),
    title: Text(task, style: const TextStyle(fontSize: 13)),
    trailing: Container(width: 4, height: 24, color: color),
  );
}

class _TimelineBar extends StatelessWidget {
  const _TimelineBar({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .75),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 9, color: color),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF9298AD), fontSize: 11),
      ),
    ],
  );
}

class _ReportEntries extends StatelessWidget {
  const _ReportEntries({required this.entries});

  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Registros do Dia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${entries.length} sessões gravadas',
                  style: const TextStyle(color: Color(0xFF9298AD)),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nenhum registro lançado hoje',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9298AD)),
              ),
            )
          else
            for (final entry in entries) _ReportEntryRow(entry: entry),
        ],
      ),
    );
  }
}

class _ReportEntryRow extends StatelessWidget {
  const _ReportEntryRow({required this.entry});

  final TimeEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF252E43))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 6,
        children: [
          SizedBox(
            width: 480,
            child: Text(
              entry.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${entry.project}  •  ${entry.category}',
            style: const TextStyle(color: Color(0xFF9298AD)),
          ),
          Text(
            '${entry.start} — ${entry.end}',
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Color(0xFFB7BDD2),
            ),
          ),
          Text(
            _formatHours(entry.duration),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Color _timelineColor(String category) => switch (category) {
  'Reunião' || 'Reuniões' => const Color(0xFFF5AE4E),
  'Code Review' => const Color(0xFF72B7FF),
  'Design' || 'Design System' => const Color(0xFF42D6A3),
  _ => const Color(0xFF5B4BEB),
};

String _formatHours(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '${hours}h ${minutes}m';
}
