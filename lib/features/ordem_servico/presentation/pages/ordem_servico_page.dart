import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/preferencias_service.dart';
import '../../../../core/widgets/erro_conexao.dart';
import '../../../equipamento/data/repositories/equipamento_repository.dart';
import '../../../equipamento/domain/entities/equipamento_entity.dart';
import '../../data/models/ordem_servico_model.dart';
import '../bloc/os_bloc.dart';

class OrdemServicoPage extends StatelessWidget {
  const OrdemServicoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OsBloc()..add(OsStarted()),
      child: const _OsView(),
    );
  }
}

class _OsView extends StatefulWidget {
  const _OsView();
  @override
  State<_OsView> createState() => _OsViewState();
}

class _OsViewState extends State<_OsView> {
  StatusOS? _filtro;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          PopupMenuButton<StatusOS?>(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list),
                if (_filtro != null)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.statusAguardando,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onSelected: (v) => setState(() => _filtro = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Todos os status')),
              ...StatusOS.values.map((s) => PopupMenuItem(value: s, child: Text(s.label))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
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
                hintText: 'Buscar por equipamento, setor, nº...',
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
            child: BlocBuilder<OsBloc, OsState>(
        builder: (context, state) {
          if (state is OsLoading || state is OsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OsError) {
            return ErroConexao(mensagem: state.message);
          }
          if (state is OsSuccess) {
            var ordens = _filtro == null
                ? state.ordens
                : state.ordens.where((o) => o.status == _filtro).toList();
            if (_query.isNotEmpty) {
              ordens = ordens.where((o) =>
                o.equipamento.nome.toLowerCase().contains(_query) ||
                o.equipamento.setor.label.toLowerCase().contains(_query) ||
                o.numero.toLowerCase().contains(_query) ||
                o.descricaoProblema.toLowerCase().contains(_query) ||
                o.solicitante.toLowerCase().contains(_query)
              ).toList();
            }

            if (ordens.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _query.isNotEmpty || _filtro != null
                            ? Icons.search_off
                            : Icons.assignment_outlined,
                        size: 40, color: AppColors.primary),
                    ),
                    const Gap(16),
                    Text(
                      _query.isNotEmpty || _filtro != null
                          ? 'Nenhuma OS encontrada'
                          : 'Nenhuma OS cadastrada',
                      style: Theme.of(context).textTheme.titleMedium),
                    const Gap(4),
                    Text(
                      _query.isNotEmpty || _filtro != null
                          ? 'Tente outro filtro ou busca'
                          : 'Crie uma nova ordem de serviço',
                      style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de contagem
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '${ordens.length} ${ordens.length == 1 ? 'OS' : 'OS'}'
                    '${_filtro != null || _query.isNotEmpty ? ' encontradas' : ' no total'}'
                    ' · ${ordens.where((o) => o.criticidade == Criticidade.alta && o.status != StatusOS.concluida).length} críticas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: ordens.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (context, i) {
                      final os = ordens[i];
                      final color = _statusColor(os.status);
                      final bg = _statusBg(os.status);
                      final bordaColor = switch (os.criticidade) {
                        Criticidade.alta => AppColors.criticidadeAlta,
                        Criticidade.media => AppColors.criticidadeMedia,
                        Criticidade.baixa => AppColors.criticidadeBaixa,
                      };
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _abrirDetalhes(context, os as OrdemServicoModel),
                            onLongPress: os.status != StatusOS.concluida && os.status != StatusOS.cancelada
                                ? () => _menuRapidoStatus(context, os as OrdemServicoModel)
                                : null,
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  // Borda colorida por criticidade
                                  Container(width: 4, color: bordaColor),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(os.numero,
                                                  style: const TextStyle(
                                                      color: AppColors.textLight,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500)),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                    color: bg, borderRadius: BorderRadius.circular(6)),
                                                child: Text(os.status.label,
                                                    style: TextStyle(
                                                        color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ),
                                          const Gap(8),
                                          Text(os.equipamento.nome,
                                              style: Theme.of(context).textTheme.bodyLarge),
                                          const Gap(3),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined,
                                                  size: 13, color: AppColors.textLight),
                                              const Gap(3),
                                              Text(os.equipamento.setor.label,
                                                  style: Theme.of(context).textTheme.bodyMedium),
                                              const Gap(8),
                                              const Icon(Icons.build_outlined,
                                                  size: 13, color: AppColors.textLight),
                                              const Gap(3),
                                              Text(os.tipoManutencao.label,
                                                  style: Theme.of(context).textTheme.bodyMedium),
                                            ],
                                          ),
                                          const Gap(8),
                                          Text(os.descricaoProblema,
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                          const Gap(8),
                                          Row(
                                            children: [
                                              const Icon(Icons.schedule_outlined,
                                                  size: 13, color: AppColors.textLight),
                                              const Gap(3),
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm').format(os.dataAbertura),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              const Spacer(),
                                              _CriticidadeBadge(criticidade: os.criticidade),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  void _menuRapidoStatus(BuildContext context, OrdemServicoModel os) {
    final statusDisponiveis = StatusOS.values
        .where((s) => s != StatusOS.concluida && s != os.status)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Gap(16),
            Text('Trocar status', style: Theme.of(context).textTheme.titleMedium),
            const Gap(4),
            Text(os.equipamento.nome, style: Theme.of(context).textTheme.bodyMedium),
            const Gap(16),
            ...statusDisponiveis.map((s) {
              final color = _statusColor(s);
              final bg = _statusBg(s);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.circle, color: color, size: 12),
                ),
                title: Text(s.label),
                onTap: () {
                  context.read<OsBloc>().add(OsAtualizarStatus(id: os.id, status: s.name));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status atualizado: ${s.label}'),
                      backgroundColor: color,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _abrirFormulario(BuildContext context, OrdemServicoModel? existente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OsBloc>(),
        child: _OsForm(existente: existente),
      ),
    );
  }

  void _abrirDetalhes(BuildContext context, OrdemServicoModel os) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OsBloc>(),
        child: _OsDetalhes(os: os),
      ),
    );
  }
}

class _CriticidadeBadge extends StatelessWidget {
  final Criticidade criticidade;
  const _CriticidadeBadge({required this.criticidade});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (criticidade) {
      Criticidade.alta => (AppColors.criticidadeAlta, AppColors.criticidadeAltaBg),
      Criticidade.media => (AppColors.criticidadeMedia, AppColors.criticidadeMediaBg),
      Criticidade.baixa => (AppColors.criticidadeBaixa, AppColors.criticidadeBaixaBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(criticidade.label.split('—').first.trim(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── FORMULÁRIO ──────────────────────────────────────────────────────────────

class _OsForm extends StatefulWidget {
  final OrdemServicoModel? existente;
  const _OsForm({this.existente});
  @override
  State<_OsForm> createState() => _OsFormState();
}

class _OsFormState extends State<_OsForm> {
  final _formKey = GlobalKey<FormState>();
  final _problemaCtrl = TextEditingController();
  final _solicitanteCtrl = TextEditingController();
  List<EquipamentoEntity> _equipamentos = [];
  EquipamentoEntity? _equipSelecionado;
  TipoManutencao _tipo = TipoManutencao.corretiva;
  Criticidade _criticidade = Criticidade.media;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
    if (widget.existente != null) {
      _problemaCtrl.text = widget.existente!.descricaoProblema;
      _solicitanteCtrl.text = widget.existente!.solicitante;
      _tipo = widget.existente!.tipoManutencao;
      _criticidade = widget.existente!.criticidade;
    }
  }

  Future<void> _carregar() async {
    final repo = EquipamentoRepository();
    final list = await repo.listar().first;
    setState(() {
      _equipamentos = list;
      if (widget.existente != null) {
        _equipSelecionado = list.where((e) => e.id == widget.existente!.equipamento.id).firstOrNull;
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _problemaCtrl.dispose();
    _solicitanteCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_equipSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um equipamento')),
      );
      return;
    }
    final numero = widget.existente?.numero ??
        'OS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final model = OrdemServicoModel(
      id: widget.existente?.id ?? '',
      numero: numero,
      equipamento: _equipSelecionado!,
      tipoManutencao: _tipo,
      criticidade: _criticidade,
      status: widget.existente?.status ?? StatusOS.aberta,
      descricaoProblema: _problemaCtrl.text.trim(),
      solicitante: _solicitanteCtrl.text.trim(),
      dataAbertura: widget.existente?.dataAbertura ?? DateTime.now(),
    );
    context.read<OsBloc>().add(OsSalvar(model));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: _loading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : Form(
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
                    Text(widget.existente == null ? 'Nova OS' : 'Editar OS',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Gap(20),
                    DropdownButtonFormField<EquipamentoEntity>(
                      value: _equipSelecionado,
                      decoration: const InputDecoration(labelText: 'Equipamento'),
                      items: _equipamentos
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text('${e.nome} (${e.ntagPatrimonio})')))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _equipSelecionado = v;
                        _criticidade = v?.criticidade ?? Criticidade.media;
                      }),
                      validator: (v) => v == null ? 'Obrigatório' : null,
                    ),
                    const Gap(12),
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<TipoManutencao>(
                          value: _tipo,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: TipoManutencao.values
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                              .toList(),
                          onChanged: (v) => setState(() => _tipo = v!),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: DropdownButtonFormField<Criticidade>(
                          value: _criticidade,
                          decoration: const InputDecoration(labelText: 'Criticidade'),
                          items: Criticidade.values
                              .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.label.split('—').first.trim())))
                              .toList(),
                          onChanged: (v) => setState(() => _criticidade = v!),
                        ),
                      ),
                    ]),
                    const Gap(12),
                    TextFormField(
                      controller: _solicitanteCtrl,
                      decoration: const InputDecoration(labelText: 'Solicitante'),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                    const Gap(12),
                    TextFormField(
                      controller: _problemaCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição do problema'),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    ),
                    const Gap(24),
                    ElevatedButton(
                      onPressed: _salvar,
                      child: Text(widget.existente == null ? 'Abrir OS' : 'Salvar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── DETALHES ────────────────────────────────────────────────────────────────

class _OsDetalhes extends StatefulWidget {
  final OrdemServicoModel os;
  const _OsDetalhes({required this.os});
  @override
  State<_OsDetalhes> createState() => _OsDetalhesState();
}

class _OsDetalhesState extends State<_OsDetalhes> {
  late final TextEditingController _solucaoCtrl;
  late final TextEditingController _tecnicoCtrl;

  OrdemServicoModel get os => widget.os;
  bool get isConcluida => os.status == StatusOS.concluida || os.status == StatusOS.cancelada;

  @override
  void initState() {
    super.initState();
    _solucaoCtrl = TextEditingController(text: os.descricaoSolucao ?? '');
    _tecnicoCtrl = TextEditingController(text: os.tecnicoResponsavel ?? '');
    _carregarNomeTecnico();
  }

  Future<void> _carregarNomeTecnico() async {
    // Só pré-preenche se o campo ainda estiver vazio
    if (_tecnicoCtrl.text.isNotEmpty) return;
    final nome = await PreferenciasService.getNomeTecnico();
    if (nome != null && nome.isNotEmpty && mounted) {
      _tecnicoCtrl.text = nome;
    }
  }

  @override
  void dispose() {
    _solucaoCtrl.dispose();
    _tecnicoCtrl.dispose();
    super.dispose();
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

  void _encerrar() {
    if (_solucaoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva a solução antes de encerrar')),
      );
      return;
    }
    if (_tecnicoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o técnico responsável')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar OS'),
        content: const Text('Confirma o encerramento desta ordem de serviço?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha dialog
              context.read<OsBloc>().add(OsEncerrar(
                id: os.id,
                descricaoSolucao: _solucaoCtrl.text.trim(),
                tecnicoResponsavel: _tecnicoCtrl.text.trim(),
              ));
              Navigator.pop(context); // fecha modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OS encerrada com sucesso ✓'),
                  backgroundColor: AppColors.statusConcluida,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Encerrar',
                style: TextStyle(color: AppColors.statusConcluida, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(os.status);
    final bg = _statusBg(os.status);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Gap(16),

            // Cabeçalho
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(os.numero,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w500)),
                    const Gap(2),
                    Text(os.equipamento.nome, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Text(os.status.label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ]),
            const Gap(16),
            const Divider(),
            const Gap(12),

            // Info
            _InfoRow(label: 'Equipamento', value: '${os.equipamento.nome} (${os.equipamento.ntagPatrimonio})'),
            _InfoRow(label: 'Setor', value: os.equipamento.setor.label),
            _InfoRow(label: 'Tipo', value: os.tipoManutencao.label),
            _InfoRow(label: 'Criticidade', value: os.criticidade.label),
            _InfoRow(label: 'Solicitante', value: os.solicitante),
            _InfoRow(label: 'Abertura', value: DateFormat('dd/MM/yyyy HH:mm').format(os.dataAbertura)),
            if (os.dataEncerramento != null)
              _InfoRow(label: 'Encerramento', value: DateFormat('dd/MM/yyyy HH:mm').format(os.dataEncerramento!)),
            if (os.tecnicoResponsavel != null && os.tecnicoResponsavel!.isNotEmpty)
              _InfoRow(label: 'Técnico', value: os.tecnicoResponsavel!),
            const Gap(12),

            // Problema
            Text('Problema:', style: Theme.of(context).textTheme.titleMedium),
            const Gap(6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
              child: Text(os.descricaoProblema),
            ),
            const Gap(16),

            // Solução (editável se não concluída)
            Row(children: [
              Text('Solução:', style: Theme.of(context).textTheme.titleMedium),
              if (isConcluida) ...[
                const Gap(6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusConcluidaBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Concluída',
                      style: TextStyle(color: AppColors.statusConcluida, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            const Gap(6),
            if (isConcluida)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusConcluidaBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusConcluida.withOpacity(0.2)),
                ),
                child: Text(
                  os.descricaoSolucao?.isNotEmpty == true ? os.descricaoSolucao! : 'Sem descrição de solução.',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              )
            else ...[
              TextField(
                controller: _solucaoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Descreva a solução aplicada...',
                  labelText: 'Descrição da solução',
                ),
              ),
              const Gap(12),
              TextField(
                controller: _tecnicoCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nome do técnico responsável',
                  labelText: 'Técnico responsável',
                  prefixIcon: Icon(Icons.engineering_outlined),
                ),
              ),
            ],

            const Gap(20),

            // Status chips (apenas se não concluída/cancelada)
            if (!isConcluida) ...[
              Text('Atualizar status:', style: Theme.of(context).textTheme.titleMedium),
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: StatusOS.values
                    .where((s) => s != StatusOS.concluida)
                    .map((s) {
                  final sc = _statusColor(s);
                  final sb = _statusBg(s);
                  final selected = os.status == s;
                  return GestureDetector(
                    onTap: () {
                      context.read<OsBloc>().add(OsAtualizarStatus(id: os.id, status: s.name));
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? sb : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? sc : AppColors.divider, width: selected ? 1.5 : 1),
                      ),
                      child: Text(s.label,
                          style: TextStyle(
                              color: selected ? sc : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const Gap(20),

              // Botão encerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _encerrar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Encerrar OS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusConcluida,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            const Gap(8),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:', style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
