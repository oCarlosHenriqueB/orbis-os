import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../ordem_servico/data/models/ordem_servico_model.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  // Filtro de período
  DateTime? _dataInicio;
  DateTime? _dataFim;

  Future<void> _selecionarPeriodo() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dataInicio != null && _dataFim != null
          ? DateTimeRange(start: _dataInicio!, end: _dataFim!)
          : null,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _dataInicio = range.start;
        _dataFim = range.end.copyWith(hour: 23, minute: 59, second: 59);
      });
    }
  }

  void _limparFiltro() => setState(() {
        _dataInicio = null;
        _dataFim = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          if (_dataInicio != null)
            TextButton.icon(
              onPressed: _limparFiltro,
              icon: const Icon(Icons.close, size: 16, color: Colors.white),
              label: const Text('Limpar', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            tooltip: 'Filtrar por período',
            onPressed: _selecionarPeriodo,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ordens_servico')
            .orderBy('dataAbertura', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var ordens = snap.data?.docs
                  .map((d) => OrdemServicoModel.fromFirestore(d))
                  .toList() ??
              [];

          // Aplicar filtro de período
          if (_dataInicio != null && _dataFim != null) {
            ordens = ordens
                .where((o) =>
                    o.dataAbertura.isAfter(_dataInicio!) &&
                    o.dataAbertura.isBefore(_dataFim!))
                .toList();
          }

          final total = ordens.length;

          // Agrupamentos
          final porStatus = <StatusOS, int>{};
          for (final s in StatusOS.values) {
            porStatus[s] = ordens.where((o) => o.status == s).length;
          }

          final porTipo = <TipoManutencao, int>{};
          for (final t in TipoManutencao.values) {
            porTipo[t] = ordens.where((o) => o.tipoManutencao == t).length;
          }

          final porSetor = <String, int>{};
          for (final o in ordens) {
            final setor = o.equipamento.setor.label;
            porSetor[setor] = (porSetor[setor] ?? 0) + 1;
          }
          final setoresOrdenados = porSetor.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final porTecnico = <String, int>{};
          for (final o in ordens) {
            final tec = o.tecnicoResponsavel;
            if (tec != null && tec.isNotEmpty) {
              porTecnico[tec] = (porTecnico[tec] ?? 0) + 1;
            }
          }
          final tecnicosOrdenados = porTecnico.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final concluidas = ordens.where((o) => o.status == StatusOS.concluida).toList();
          final tempoMedioMs = concluidas.isEmpty
              ? null
              : concluidas
                      .where((o) => o.dataEncerramento != null)
                      .map((o) =>
                          o.dataEncerramento!.difference(o.dataAbertura).inMinutes)
                      .fold(0, (a, b) => a + b) /
                  concluidas.where((o) => o.dataEncerramento != null).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Período ativo
                if (_dataInicio != null && _dataFim != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, color: AppColors.primary, size: 18),
                        const Gap(8),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(_dataInicio!)} → ${DateFormat('dd/MM/yyyy').format(_dataFim!)}',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                // Visão geral
                _SectionHeader(title: 'Visão Geral', icon: Icons.bar_chart_outlined),
                const Gap(10),
                Row(children: [
                  Expanded(
                    child: _BigStatCard(
                      label: 'Total de OS',
                      value: '$total',
                      icon: Icons.assignment_outlined,
                      color: AppColors.primary,
                      bg: AppColors.primarySurface,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: _BigStatCard(
                      label: 'Tempo Médio',
                      value: tempoMedioMs == null
                          ? '—'
                          : tempoMedioMs < 60
                              ? '${tempoMedioMs.round()}min'
                              : tempoMedioMs < 1440
                                  ? '${(tempoMedioMs / 60).toStringAsFixed(1)}h'
                                  : '${(tempoMedioMs / 1440).toStringAsFixed(1)}d',
                      icon: Icons.timer_outlined,
                      color: AppColors.statusCalibracao,
                      bg: AppColors.statusCalibracaoBg,
                    ),
                  ),
                ]),
                const Gap(20),

                // Por Status
                _SectionHeader(title: 'Por Status', icon: Icons.label_outline),
                const Gap(10),
                _Card(
                  child: Column(
                    children: StatusOS.values.map((s) {
                      final count = porStatus[s] ?? 0;
                      final color = _statusColor(s);
                      final bg = _statusBg(s);
                      return _BarRow(
                        label: s.label,
                        count: count,
                        total: total,
                        color: color,
                        bg: bg,
                      );
                    }).toList(),
                  ),
                ),
                const Gap(20),

                // Por Tipo de Manutenção
                _SectionHeader(title: 'Por Tipo de Manutenção', icon: Icons.build_outlined),
                const Gap(10),
                _Card(
                  child: Column(
                    children: TipoManutencao.values.map((t) {
                      final count = porTipo[t] ?? 0;
                      return _BarRow(
                        label: t.label,
                        count: count,
                        total: total,
                        color: AppColors.primary,
                        bg: AppColors.primarySurface,
                      );
                    }).toList(),
                  ),
                ),
                const Gap(20),

                // Por Setor
                _SectionHeader(title: 'Por Setor', icon: Icons.location_on_outlined),
                const Gap(10),
                _Card(
                  child: setoresOrdenados.isEmpty
                      ? const _EmptyRow()
                      : Column(
                          children: setoresOrdenados.map((e) {
                            return _BarRow(
                              label: e.key,
                              count: e.value,
                              total: total,
                              color: AppColors.statusEmAtendimento,
                              bg: AppColors.statusEmAtendimentoBg,
                            );
                          }).toList(),
                        ),
                ),
                const Gap(20),

                // Por Técnico
                _SectionHeader(title: 'Por Técnico', icon: Icons.engineering_outlined),
                const Gap(10),
                _Card(
                  child: tecnicosOrdenados.isEmpty
                      ? const _EmptyRow(message: 'Nenhuma OS encerrada ainda')
                      : Column(
                          children: tecnicosOrdenados.map((e) {
                            return _BarRow(
                              label: e.key,
                              count: e.value,
                              total: total,
                              color: AppColors.statusConcluida,
                              bg: AppColors.statusConcluidaBg,
                            );
                          }).toList(),
                        ),
                ),
                const Gap(32),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(StatusOS s) => switch (s) {
        StatusOS.aberta => AppColors.statusAberta,
        StatusOS.emExecucao => AppColors.statusEmAtendimento,
        StatusOS.aguardandoPeca => AppColors.statusAguardando,
        StatusOS.calibracao => AppColors.statusCalibracao,
        StatusOS.validacaoUsuario => AppColors.secondary,
        StatusOS.concluida => AppColors.statusConcluida,
        StatusOS.cancelada => AppColors.statusCancelada,
      };

  Color _statusBg(StatusOS s) => switch (s) {
        StatusOS.aberta => AppColors.statusAbertaBg,
        StatusOS.emExecucao => AppColors.statusEmAtendimentoBg,
        StatusOS.aguardandoPeca => AppColors.statusAguardandoBg,
        StatusOS.calibracao => AppColors.statusCalibracaoBg,
        StatusOS.validacaoUsuario => AppColors.primarySurface,
        StatusOS.concluida => AppColors.statusConcluidaBg,
        StatusOS.cancelada => AppColors.statusCanceladaBg,
      };
}

// ─── WIDGETS AUXILIARES ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const Gap(8),
        Icon(icon, size: 18, color: AppColors.primary),
        const Gap(6),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _BigStatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(12),
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const Gap(2),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color, bg;
  const _BarRow(
      {required this.label,
      required this.count,
      required this.total,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const Gap(8),
              Text('$count',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 14)),
              const Gap(4),
              Text('(${(pct * 100).round()}%)',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const Gap(5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String message;
  const _EmptyRow({this.message = 'Sem dados'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message,
          style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
