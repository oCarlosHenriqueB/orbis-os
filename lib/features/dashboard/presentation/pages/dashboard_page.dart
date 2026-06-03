import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../ordem_servico/domain/entities/ordem_servico_entity.dart';
import '../../../ordem_servico/data/models/ordem_servico_model.dart';
import '../../../relatorio/presentation/pages/relatorio_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('HospOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Relatórios',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RelatorioPage()),
            ),
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

          final ordens = snap.data?.docs
              .map((d) => OrdemServicoModel.fromFirestore(d))
              .toList() ?? [];

          final abertas = ordens.where((o) => o.status == StatusOS.aberta).length;
          final emExecucao = ordens.where((o) => o.status == StatusOS.emExecucao).length;
          final aguardando = ordens.where((o) => o.status == StatusOS.aguardandoPeca).length;
          final concluidas = ordens.where((o) => o.status == StatusOS.concluida).length;

          final criticas = ordens
              .where((o) => o.criticidade == Criticidade.alta && o.status != StatusOS.concluida)
              .take(5)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_hospital_outlined, color: AppColors.primary, size: 24),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Engenharia Clínica',
                                style: Theme.of(context).textTheme.titleMedium),
                            const Gap(2),
                            Text(nomeHospital,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // Stats
                Text('Visão Geral', style: Theme.of(context).textTheme.titleMedium),
                const Gap(10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _StatCard(title: 'Abertas', value: '$abertas',
                        icon: Icons.assignment_outlined,
                        color: AppColors.statusAberta, bg: AppColors.statusAbertaBg),
                    _StatCard(title: 'Em Execução', value: '$emExecucao',
                        icon: Icons.engineering_outlined,
                        color: AppColors.statusEmAtendimento, bg: AppColors.statusEmAtendimentoBg),
                    _StatCard(title: 'Aguard. Peça', value: '$aguardando',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.statusAguardando, bg: AppColors.statusAguardandoBg),
                    _StatCard(title: 'Concluídas', value: '$concluidas',
                        icon: Icons.check_circle_outline,
                        color: AppColors.statusConcluida, bg: AppColors.statusConcluidaBg),
                  ],
                ),
                const Gap(20),

                // OS Críticas
                Row(
                  children: [
                    Container(
                      width: 4, height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.criticidadeAlta,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Gap(8),
                    Text('OS Críticas — Suporte à Vida',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const Gap(10),
                if (criticas.isNotEmpty)
                  ...criticas.map((os) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OsCard(os: os),
                  ))
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.statusConcluidaBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusConcluida.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.statusConcluida, size: 20),
                        const Gap(8),
                        Text('Nenhuma OS crítica aberta',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.statusConcluida)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair do HospOS?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.criticidadeAlta)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color, bg;
  const _StatCard({required this.title, required this.value,
      required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _OsCard extends StatelessWidget {
  final OrdemServicoEntity os;
  const _OsCard({required this.os});

  Color get _color => switch (os.status) {
    StatusOS.aberta => AppColors.statusAberta,
    StatusOS.emExecucao => AppColors.statusEmAtendimento,
    StatusOS.aguardandoPeca => AppColors.statusAguardando,
    StatusOS.calibracao => AppColors.statusCalibracao,
    StatusOS.validacaoUsuario => AppColors.secondary,
    StatusOS.concluida => AppColors.statusConcluida,
    StatusOS.cancelada => AppColors.statusCancelada,
  };

  Color get _bg => switch (os.status) {
    StatusOS.aberta => AppColors.statusAbertaBg,
    StatusOS.emExecucao => AppColors.statusEmAtendimentoBg,
    StatusOS.aguardandoPeca => AppColors.statusAguardandoBg,
    StatusOS.calibracao => AppColors.statusCalibracaoBg,
    StatusOS.validacaoUsuario => AppColors.primarySurface,
    StatusOS.concluida => AppColors.statusConcluidaBg,
    StatusOS.cancelada => AppColors.statusCanceladaBg,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.criticidadeAltaBg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.criticidadeAltaBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medical_services_outlined,
                color: AppColors.criticidadeAlta, size: 18),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(os.equipamento.nome, style: Theme.of(context).textTheme.bodyLarge),
                const Gap(2),
                Text('${os.equipamento.setor.label} • ${os.tipoManutencao.label}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(6)),
            child: Text(os.status.label,
                style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
