import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/erro_conexao.dart';
import '../../data/models/equipamento_model.dart';
import '../bloc/equipamento_bloc.dart';
import 'equipamento_detalhe_page.dart';

class EquipamentoPage extends StatelessWidget {
  const EquipamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EquipamentoBloc()..add(EquipamentoStarted()),
      child: const _EquipamentoView(),
    );
  }
}

class _EquipamentoView extends StatefulWidget {
  const _EquipamentoView();
  @override
  State<_EquipamentoView> createState() => _EquipamentoViewState();
}

class _EquipamentoViewState extends State<_EquipamentoView> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Equipamentos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Novo Equipamento'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Buscar por nome, marca, NTag, setor...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<EquipamentoBloc, EquipamentoState>(
        builder: (context, state) {
          if (state is EquipamentoLoading || state is EquipamentoInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EquipamentoError) {
            return ErroConexao(mensagem: state.message);
          }
          if (state is EquipamentoSuccess) {
            final equipamentos = _query.isEmpty
                ? state.equipamentos
                : state.equipamentos.where((e) =>
                    e.nome.toLowerCase().contains(_query) ||
                    e.marca.toLowerCase().contains(_query) ||
                    e.modelo.toLowerCase().contains(_query) ||
                    e.ntagPatrimonio.toLowerCase().contains(_query) ||
                    e.setor.label.toLowerCase().contains(_query)
                  ).toList();
            if (equipamentos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _query.isNotEmpty ? Icons.search_off : Icons.medical_services_outlined,
                        size: 40, color: AppColors.primary),
                    ),
                    const Gap(16),
                    Text(
                      _query.isNotEmpty ? 'Nenhum resultado para "$_query"' : 'Nenhum equipamento cadastrado',
                      style: Theme.of(context).textTheme.titleMedium),
                    const Gap(4),
                    Text(
                      _query.isNotEmpty ? 'Tente outro termo' : 'Cadastre seu primeiro equipamento',
                      style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: equipamentos.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, i) {
                final eq = equipamentos[i];
                final (color, bg) = switch (eq.criticidade) {
                  Criticidade.alta => (AppColors.criticidadeAlta, AppColors.criticidadeAltaBg),
                  Criticidade.media => (AppColors.criticidadeMedia, AppColors.criticidadeMediaBg),
                  Criticidade.baixa => (AppColors.criticidadeBaixa, AppColors.criticidadeBaixaBg),
                };
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EquipamentoDetalhePage(equipamento: eq),
                    )),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.medical_services_outlined, color: color, size: 22),
                    ),
                    title: Text(eq.nome, style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(3),
                        Row(children: [
                          const Icon(Icons.business_outlined, size: 12, color: AppColors.textLight),
                          const Gap(3),
                          Text('${eq.marca} • ${eq.modelo}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                        const Gap(2),
                        Row(children: [
                          const Icon(Icons.qr_code, size: 12, color: AppColors.textLight),
                          const Gap(3),
                          Text('${eq.ntagPatrimonio} • ${eq.setor.label}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: bg, borderRadius: BorderRadius.circular(6)),
                          child: Text(eq.criticidade.label.split('—').first.trim(),
                              style: TextStyle(
                                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.textSecondary),
                          onPressed: () => _abrirFormulario(context, eq as EquipamentoModel),
                        ),
                      ],
                    ),
                  )),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
          ),
        ],
      ),
    );
  }

  void _abrirFormulario(BuildContext context, EquipamentoModel? existente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<EquipamentoBloc>(),
        child: _EquipamentoForm(existente: existente),
      ),
    );
  }
}

class _EquipamentoForm extends StatefulWidget {
  final EquipamentoModel? existente;
  const _EquipamentoForm({this.existente});
  @override
  State<_EquipamentoForm> createState() => _EquipamentoFormState();
}

class _EquipamentoFormState extends State<_EquipamentoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome, _marca, _modelo, _ntag;
  late SetorHospital _setor;
  late Criticidade _criticidade;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _nome = TextEditingController(text: e?.nome);
    _marca = TextEditingController(text: e?.marca);
    _modelo = TextEditingController(text: e?.modelo);
    _ntag = TextEditingController(text: e?.ntagPatrimonio);
    _setor = e?.setor ?? SetorHospital.outros;
    _criticidade = e?.criticidade ?? Criticidade.baixa;
  }

  @override
  void dispose() {
    _nome.dispose(); _marca.dispose(); _modelo.dispose(); _ntag.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final model = EquipamentoModel(
      id: widget.existente?.id ?? '',
      nome: _nome.text.trim(),
      marca: _marca.text.trim(),
      modelo: _modelo.text.trim(),
      ntagPatrimonio: _ntag.text.trim(),
      setor: _setor,
      criticidade: _criticidade,
      ativo: true,
    );
    context.read<EquipamentoBloc>().add(EquipamentoSalvar(model));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),
              Text(widget.existente == null ? 'Novo Equipamento' : 'Editar Equipamento',
                  style: Theme.of(context).textTheme.titleLarge),
              const Gap(20),
              TextFormField(controller: _nome,
                  decoration: const InputDecoration(labelText: 'Nome do equipamento'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              const Gap(12),
              Row(children: [
                Expanded(child: TextFormField(controller: _marca,
                    decoration: const InputDecoration(labelText: 'Marca'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
                const Gap(12),
                Expanded(child: TextFormField(controller: _modelo,
                    decoration: const InputDecoration(labelText: 'Modelo'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null)),
              ]),
              const Gap(12),
              TextFormField(controller: _ntag,
                  decoration: const InputDecoration(labelText: 'NTag / Patrimônio'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              const Gap(12),
              DropdownButtonFormField<SetorHospital>(
                value: _setor,
                decoration: const InputDecoration(labelText: 'Setor'),
                items: SetorHospital.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) => setState(() => _setor = v!),
              ),
              const Gap(12),
              DropdownButtonFormField<Criticidade>(
                value: _criticidade,
                decoration: const InputDecoration(labelText: 'Criticidade'),
                items: Criticidade.values
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c.label.split('—').first.trim())))
                    .toList(),
                onChanged: (v) => setState(() => _criticidade = v!),
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(widget.existente == null ? 'Cadastrar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
