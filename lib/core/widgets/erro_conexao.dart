import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';

class ErroConexao extends StatelessWidget {
  final String mensagem;
  const ErroConexao({required this.mensagem});

  bool get _semConexao =>
      mensagem.toLowerCase().contains('network') ||
      mensagem.toLowerCase().contains('unavailable') ||
      mensagem.toLowerCase().contains('connection') ||
      mensagem.toLowerCase().contains('socket');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.criticidadeAltaBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _semConexao ? Icons.wifi_off_outlined : Icons.error_outline,
                size: 40,
                color: AppColors.criticidadeAlta,
              ),
            ),
            const Gap(16),
            Text(
              _semConexao ? 'Sem conexão' : 'Algo deu errado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(6),
            Text(
              _semConexao
                  ? 'Verifique sua internet e tente novamente.'
                  : 'Tente novamente em instantes.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
