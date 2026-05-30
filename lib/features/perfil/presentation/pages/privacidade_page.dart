import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacidadePage extends StatelessWidget {
  const PrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Secao(
              titulo: 'Sobre o Aplicativo',
              conteudo:
                  'O Orbis OS é um sistema de gerenciamento de ordens de serviço '
                  'desenvolvido exclusivamente para uso interno na Engenharia Clínica '
                  'do Hospital e Maternidade Municipal Santa Ana — Santana de Parnaíba/SP.',
            ),
            _Secao(
              titulo: 'Dados Coletados',
              conteudo:
                  'O aplicativo coleta apenas os dados necessários para funcionamento:\n\n'
                  '• E-mail e senha (autenticação via Firebase Auth)\n'
                  '• Ordens de Serviço: equipamento, setor, tipo, problema, solução, técnico e datas\n'
                  '• Equipamentos: nome, marca, modelo, NTag, setor e criticidade\n'
                  '• Nome do técnico: salvo apenas localmente no dispositivo',
            ),
            _Secao(
              titulo: 'Uso dos Dados',
              conteudo:
                  'Os dados são utilizados exclusivamente para gerenciamento interno '
                  'de manutenções hospitalares. Nenhum dado é compartilhado com '
                  'terceiros, vendido ou usado para fins publicitários.',
            ),
            _Secao(
              titulo: 'Armazenamento e Segurança',
              conteudo:
                  'Os dados são armazenados no Firebase Firestore (Google Cloud), '
                  'com acesso restrito por autenticação. Senhas são gerenciadas pelo '
                  'Firebase Authentication e nunca armazenadas em texto simples.',
            ),
            _Secao(
              titulo: 'Serviços de Terceiros',
              conteudo:
                  'O aplicativo utiliza Firebase Authentication e Cloud Firestore '
                  '(Google). Consulte a Política de Privacidade do Google em '
                  'policies.google.com/privacy para mais informações.',
            ),
            _Secao(
              titulo: 'Contato',
              conteudo:
                  'Para dúvidas sobre esta política, entre em contato:\n'
                  'ocarloshenriqueb@gmail.com',
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Text(
                'Última atualização: junho de 2025',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo, conteudo;
  const _Secao({required this.titulo, required this.conteudo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const Gap(10),
          Text(conteudo,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
        ],
      ),
    );
  }
}
