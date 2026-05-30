import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/preferencias_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'privacidade_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _nomeCtrl = TextEditingController();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarNome();
  }

  Future<void> _carregarNome() async {
    final nome = await PreferenciasService.getNomeTecnico();
    if (nome != null && mounted) {
      _nomeCtrl.text = nome;
    }
  }

  Future<void> _salvarNome() async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) return;
    setState(() => _salvando = true);
    await PreferenciasService.setNomeTecnico(nome);
    setState(() => _salvando = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome salvo com sucesso ✓'),
          backgroundColor: AppColors.statusConcluida,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const Gap(12),
                  Text(email, style: Theme.of(context).textTheme.titleMedium),
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Técnico de Engenharia Clínica',
                        style: TextStyle(color: AppColors.primary,
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Nome do técnico
            _SecaoCard(
              titulo: 'Identificação',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seu nome será pré-preenchido ao encerrar OS.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nomeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Seu nome completo',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                              onSubmitted: (_) => _salvarNome(),
                            ),
                          ),
                          const Gap(10),
                          ElevatedButton(
                            onPressed: _salvando ? null : _salvarNome,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: _salvando
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Salvar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),

            // Hospital
            _SecaoCard(
              titulo: 'Hospital',
              children: [
                _InfoItem(icon: Icons.local_hospital_outlined,
                    label: 'Instituição', value: nomeHospital),
                _InfoItem(icon: Icons.location_city_outlined,
                    label: 'Município', value: municipioHospital),
              ],
            ),
            const Gap(12),

            // App
            _SecaoCard(
              titulo: 'Sobre o App',
              children: [
                _InfoItem(icon: Icons.apps_outlined,
                    label: 'Sistema', value: 'Orbis OS'),
                _InfoItem(icon: Icons.build_circle_outlined,
                    label: 'Versão', value: '1.0.0'),
                _InfoItem(icon: Icons.category_outlined,
                    label: 'Módulo', value: 'Engenharia Clínica'),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.privacy_tip_outlined,
                      size: 20, color: AppColors.primary),
                  title: const Text('Política de Privacidade',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  subtitle: const Text('Ver política completa',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textLight, size: 18),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacidadePage()),
                  ),
                ),
              ],
            ),
            const Gap(12),

            // Logout
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.criticidadeAltaBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_outlined,
                      color: AppColors.criticidadeAlta, size: 20),
                ),
                title: const Text('Sair do sistema',
                    style: TextStyle(color: AppColors.criticidadeAlta,
                        fontWeight: FontWeight.w500)),
                subtitle: const Text('Encerrar sessão'),
                onTap: () => _confirmarLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair do Orbis OS?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Sair',
                style: TextStyle(color: AppColors.criticidadeAlta)),
          ),
        ],
      ),
    );
  }
}

class _SecaoCard extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  const _SecaoCard({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(titulo,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: AppColors.primary),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
    );
  }
}
