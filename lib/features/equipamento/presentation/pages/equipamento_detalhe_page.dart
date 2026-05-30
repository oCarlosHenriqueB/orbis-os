import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/equipamento_entity.dart';

class EquipamentoDetalhePage extends StatelessWidget {
  final EquipamentoEntity equipamento;
  const EquipamentoDetalhePage({super.key, required this.equipamento});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (equipamento.criticidade) {
      Criticidade.alta => (AppColors.criticidadeAlta, AppColors.criticidadeAltaBg),
      Criticidade.media => (AppColors.criticidadeMedia, AppColors.criticidadeMediaBg),
      Criticidade.baixa => (AppColors.criticidadeBaixa, AppColors.criticidadeBaixaBg),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(equipamento.nome)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.medical_services_outlined, color: color, size: 28),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(equipamento.nome, style: Theme.of(context).textTheme.titleLarge),
                            const Gap(2),
                            Text('${equipamento.marca} • ${equipamento.modelo}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                        child: Text(equipamento.criticidade.label.split('—').first.trim(),
                            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Divider(height: 1),
                  const Gap(12),
                  _InfoGrid(equipamento: equipamento),
                ],
              ),
            ),
            const Gap(20),

            // Histórico de OS
            Row(
              children: [
                Container(width: 4, height: 18,
                    decoration: BoxDecoration(
                        color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const Gap(8),
                Text('Histórico de OS', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Gap(10),
            _HistoricoOS(ativoId: equipamento.id),
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final EquipamentoEntity equipamento;
  const _InfoGrid({required this.equipamento});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _InfoItem(icon: Icons.qr_code_outlined,
                label: 'NTag / Patrimônio', value: equipamento.ntagPatrimonio)),
            Expanded(child: _InfoItem(icon: Icons.location_on_outlined,
                label: 'Setor', value: equipamento.setor.label)),
          ],
        ),
        const Gap(8),
        Row(
          children: [
            Expanded(child: _InfoItem(icon: Icons.stairs_outlined,
                label: 'Andar', value: equipamento.setor.andar.label)),
            Expanded(child: _InfoItem(icon: Icons.circle_outlined,
                label: 'Status', value: 'Ativo')),
          ],
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const Gap(6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoricoOS extends StatelessWidget {
  final String ativoId;
  const _HistoricoOS({required this.ativoId});

  Color _statusColor(String s) => switch (s) {
    'aberta' => AppColors.statusAberta,
    'emExecucao' => AppColors.statusEmAtendimento,
    'aguardandoPeca' => AppColors.statusAguardando,
    'calibracao' => AppColors.statusCalibracao,
    'concluida' => AppColors.statusConcluida,
    'cancelada' => AppColors.statusCancelada,
    _ => AppColors.textSecondary,
  };

  Color _statusBg(String s) => switch (s) {
    'aberta' => AppColors.statusAbertaBg,
    'emExecucao' => AppColors.statusEmAtendimentoBg,
    'aguardandoPeca' => AppColors.statusAguardandoBg,
    'calibracao' => AppColors.statusCalibracaoBg,
    'concluida' => AppColors.statusConcluidaBg,
    'cancelada' => AppColors.statusCanceladaBg,
    _ => AppColors.surfaceVariant,
  };

  String _statusLabel(String s) => switch (s) {
    'aberta' => 'Aberta',
    'emExecucao' => 'Em Execução',
    'aguardandoPeca' => 'Aguardando Peça',
    'calibracao' => 'Calibração/Teste',
    'validacaoUsuario' => 'Validação Usuário',
    'concluida' => 'Concluída',
    'cancelada' => 'Cancelada',
    _ => s,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ordens_servico')
          .where('equipamento.id', isEqualTo: ativoId)
          .orderBy('dataAbertura', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: AppColors.textLight, size: 20),
                Gap(8),
                Text('Nenhuma OS registrada',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final status = d['status'] as String? ?? '';
            final tipo = d['tipoManutencao'] as String? ?? '';
            final numero = d['numero'] as String? ?? '';
            final problema = d['descricaoProblema'] as String? ?? '';
            final dataAbertura = (d['dataAbertura'] as Timestamp?)?.toDate();
            final dataEncerramento = (d['dataEncerramento'] as Timestamp?)?.toDate();
            final color = _statusColor(status);
            final bg = _statusBg(status);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(numero,
                          style: const TextStyle(fontSize: 12,
                              color: AppColors.textLight, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusLabel(status),
                            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(_tipoLabel(tipo),
                      style: Theme.of(context).textTheme.bodyLarge),
                  const Gap(3),
                  Text(problema,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const Gap(8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 12, color: AppColors.textLight),
                      const Gap(3),
                      Text(
                        dataAbertura != null
                            ? DateFormat('dd/MM/yyyy').format(dataAbertura)
                            : '—',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (dataEncerramento != null) ...[
                        const Gap(8),
                        const Icon(Icons.check_outlined, size: 12, color: AppColors.statusConcluida),
                        const Gap(3),
                        Text(
                          DateFormat('dd/MM/yyyy').format(dataEncerramento),
                          style: const TextStyle(fontSize: 12, color: AppColors.statusConcluida),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _tipoLabel(String t) => switch (t) {
    'corretiva' => 'Corretiva',
    'preventiva' => 'Preventiva',
    'calibracao' => 'Calibração',
    'inspecao' => 'Inspeção',
    'testeSeguranca' => 'Teste de Segurança Elétrica',
    _ => t,
  };
}
