# Auditoria Técnica — Orbis OS

> Data: 30/05/2026 · Escopo: `lib/` completo, `pubspec.yaml`, navegação, camada Firestore.
> Tipo: análise técnica (sem alteração de código).

---

## 1. Visão geral

O app está **funcional e bem organizado na superfície** (feature-first, tema centralizado, BLoC nas features principais, UX cuidada). Porém, sob a casca, há **divergências relevantes entre o que o CLAUDE.md promete e o que o código realmente faz** — principalmente em Clean Architecture, Dependency Injection e consistência de acesso ao Firestore. Nada disso impede o lançamento na Play Store, mas vira dívida cara à medida que o app cresce.

Veredito resumido: **bom MVP, arquitetura "Clean" apenas no nome**. Os pilares estruturais (DI, camada de domínio, regras de segurança) estão ausentes ou pela metade.

---

## 2. Inconsistências por pilar

### 2.1 Clean Architecture — **parcial / quebrada**

- **Domain incompleta.** Existe `domain/entities`, mas **não há `domain/repositories` (interfaces) nem `usecases`**. A presentation depende diretamente da implementação concreta em `data/`. O fluxo correto seria `presentation → usecase → repository(interface) → repository(impl)`. Hoje é `presentation → repository concreto`.
- **Model estende Entity.** `OrdemServicoModel extends OrdemServicoEntity` acopla as duas camadas. O hack `_EquipamentoInline extends EquipamentoEntity` confirma o atrito — a entidade está sendo forçada a representar dado de persistência.
- **Presentation importando `data/models`.** Dashboard e Relatório importam `ordem_servico_model.dart` diretamente. A UI nunca deveria conhecer a camada de dados.
- **Violação mais grave: acesso direto ao Firestore na UI.** `DashboardPage` e `RelatorioPage` fazem `FirebaseFirestore.instance.collection('ordens_servico').snapshots()` dentro de `StreamBuilder`, **pulando repository e BLoC por completo**. Isso quebra o padrão usado em OS/Equipamento e duplica a lógica de mapeamento.

### 2.2 BLoC — **inconsistente**

- **Duas features não usam BLoC.** OS e Equipamento seguem o padrão; **Dashboard e Relatório usam StreamBuilder cru**. Padrão arquitetural aplicado pela metade.
- **`emit` fora do handler (bug latente).** Em `OsBloc._onStarted`, o `onError` do stream chama `emit(OsError(...))` dentro do callback assíncrono do stream, **depois** do handler já ter retornado. Isso dispara o erro do bloc *"emit was called after an event handler completed"* e pode derrubar a tela. O caminho de sucesso usa `add(OsListLoaded)` (correto) — mas o de erro não.
- **Mutações sem estado.** `_onSalvar`, `_onAtualizarStatus` e `_onEncerrar` não emitem `loading`/`success`. A UI fecha o modal otimisticamente e confia no stream. Se a escrita falhar, emite `OsError`, que **substitui a lista inteira** → a tela trava num estado de erro até ser reaberta.
- **Repositório instanciado dentro do BLoC.** `final _repo = OrdemServicoRepository()` impede injeção e testes unitários (não dá pra mockar).

### 2.3 Firestore — **funcional, mas frágil e caro em escala**

- **Sem regras de segurança versionadas.** Não há `firestore.rules` no projeto. Se o banco estiver em modo de teste/aberto, **qualquer cliente pode ler e escrever toda a base** — risco crítico num app hospitalar com dados de OS.
- **Sem paginação.** `listar()` faz `snapshots()` da coleção **inteira**, sempre. Dashboard e Relatório baixam todas as OS para contar/agrupar **em memória no cliente**.
- **Número de OS gerado no cliente, não atômico.** `'OS-${millisecondsSinceEpoch.substring(7)}'` é suscetível a colisão sob concorrência e não garante sequência. O correto é um contador transacional (ou `runTransaction`) server-side.
- **Equipamento denormalizado sem sincronização.** O equipamento é embutido (snapshot) na OS. Bom para histórico, mas **se o equipamento mudar de nome/setor, as OS antigas e abertas ficam com dado obsoleto** — comportamento não documentado nem tratado.
- **Filtro de período em memória.** O Relatório baixa tudo e filtra com `isAfter/isBefore` no cliente (e exclui exatamente as datas-limite por usar comparação exclusiva).
- **Sem escopo multi-tenant.** Tudo numa coleção global única, sem separação por hospital/unidade. Limita expansão para mais de um hospital.

### 2.4 GoRouter — **mistura de paradigmas**

- **Duas fontes de verdade de auth.** O `redirect` lê `FirebaseAuth.instance.currentUser` diretamente, enquanto a UI usa `AuthBloc`. Estado de autenticação duplicado.
- **`ShellRoute` em vez de `StatefulShellRoute`.** Ao trocar de aba, a página é reconstruída e o `BlocProvider` de cada página **recria o BLoC e reabre o stream do Firestore** → leituras repetidas a cada navegação (custo e perda de estado de rolagem/scroll).
- **Navegação fora do router.** `RelatorioPage` é aberta com `Navigator.push(MaterialPageRoute(...))`, fora do GoRouter. Inconsistência de navegação e impossível deep-linkar.
- **Derivação de índice frágil.** `MainShell` infere a aba via `switch` na string da location — quebra com subrotas.

### 2.5 Dependency Injection — **prometida, não implementada**

- **`get_it` + `injectable` estão no `pubspec` mas têm ZERO uso** (`grep` não encontra nada). A pasta `config/routes` existe, mas não há `injection.dart`/`@injectable`.
- Tudo é instanciado manualmente e hardcoded: `OrdemServicoRepository()`, `EquipamentoRepository()` dentro de BLoCs e até dentro de um `State` de formulário (`final repo = EquipamentoRepository()` em `_OsFormState`).
- Resultado: impossível trocar implementações, impossível testar com mocks, dependências acopladas em tempo de compilação.

---

## 3. Débitos técnicos (priorizados)

**Bloqueadores de qualidade / segurança**
1. Regras de segurança do Firestore ausentes (risco de exposição de dados).
2. DI (get_it/injectable) não implementada apesar de declarada.
3. Camada de domínio incompleta — sem interfaces de repositório nem usecases.
4. Acesso direto ao Firestore na UI (Dashboard/Relatório).
5. Cobertura de testes ~zero (só o `widget_test.dart` padrão, provavelmente quebrado pós-refactor).

**Estruturais**
6. Geração de número de OS não atômica/no cliente.
7. Sem paginação nem agregação server-side.
8. Mutações de BLoC sem estados de loading/sucesso/erro isolado.
9. Inconsistência de navegação (Navigator vs GoRouter) e `ShellRoute` sem persistência de estado.

**Higiene / bloat**
10. Dependências declaradas e não usadas: `dio`, `pretty_dio_logger` (não há REST), `freezed`/`json_serializable` (models são manuais), `logger` (sem logging estruturado).
11. Strings mágicas: `'concluida'` hardcoded no repo `encerrar` em vez de `StatusOS.concluida.name`.
12. `withOpacity()` está deprecado no Flutter 3.44 (migrar para `.withValues()`).
13. Localização: `showDateRangePicker(locale: Locale('pt','BR'))` e `DateFormat('dd/MM/yyyy')` **sem `localizationsDelegates` nem `initializeDateFormatting` no `main.dart`** → risco de exceção de localização em runtime.

---

## 4. Possíveis bugs futuros

- **Crash "emit after handler completed"** quando o stream de OS emite erro (offline/permissão). Já latente.
- **Tela de OS travada em erro:** uma falha de escrita emite `OsError` e apaga a lista carregada; só recupera reabrindo a aba.
- **Colisão de número de OS** sob uso concorrente (dois técnicos criando OS no mesmo milissegundo-truncado).
- **Cast nulo de Timestamp:** `(d['dataAbertura'] as Timestamp)` é forçado; um documento sem o campo (escrita manual, migração, serverTimestamp pendente) derruba o mapeamento.
- **Dados obsoletos:** equipamento renomeado/movido não reflete nas OS já criadas.
- **Exceção de localização** no DateRangePicker por falta de delegates (ponto 13).
- **Degradação de memória/custo** conforme a coleção cresce: Dashboard e Relatório carregam tudo a cada abertura.
- **Datas-limite do filtro** de relatório excluídas por comparação exclusiva (`isAfter/isBefore`).

---

## 5. Avaliação de escalabilidade

### 10 usuários — ✅ Tranquilo
Volume baixo. Baixar a coleção inteira é tolerável, colisão de número é improvável, custo de leituras irrelevante. Os bugs latentes (emit/erro, localização) são os maiores riscos — não a escala.

### 100 usuários — ⚠️ Funciona, começa a doer
A ausência de paginação e as agregações no cliente passam a pesar: cada Dashboard/Relatório aberto lê centenas/milhares de documentos. Custo do Firestore e latência crescem de forma perceptível. A recriação de streams a cada troca de aba multiplica leituras. Colisões de número ainda raras, mas possíveis. **Ponto em que paginação e contadores agregados deixam de ser opcionais.**

### 1000 usuários — ❌ Insustentável sem refatorar
- Cada cliente assinando a coleção completa de OS gera leituras na ordem de N×M → **custo e latência explodem**, com risco de pressão de memória no dispositivo.
- Sem escopo por hospital, tudo compete na mesma coleção/índices.
- Geração de número no cliente vira fonte real de colisões.
- Sem regras de segurança, a superfície de risco é proporcional à base de usuários.
- Necessário: **paginação + queries com limite**, **agregações server-side** (Cloud Functions / aggregation queries / documentos de contadores), **contador transacional de número**, **escopo multi-tenant**, **regras de segurança**, e **cache/offline** explícito.

---

## 6. Roadmap de evolução — 6 meses

### Mês 1 — Fundação e risco crítico
- Escrever e versionar **`firestore.rules`** (auth obrigatório, escopo por usuário/papel) + `firestore.indexes.json`.
- Corrigir o **bug de `emit` no `onError`** do `OsBloc` (encaminhar erro via `add(evento)` em vez de `emit` no callback).
- Adicionar **`localizationsDelegates` + `initializeDateFormatting('pt_BR')`** no `main.dart`.
- Publicar na Play Store (itens 6–8 do checklist do CLAUDE.md).

### Mês 2 — Dependency Injection de verdade
- Implementar **get_it/injectable** (`injection.dart`, `@injectable` nos repos/blocs/serviços).
- Remover instanciação manual de repositórios em BLoCs e em `_OsFormState`.
- Limpar dependências mortas (`dio`, `pretty_dio_logger`; decidir entre adotar `freezed` ou removê-lo).

### Mês 3 — Completar a Clean Architecture
- Introduzir **interfaces de repositório em `domain/repositories`** e implementações em `data`.
- Adicionar **usecases** para os fluxos principais (listar, salvar, encerrar, atualizar status).
- Separar **Model de Entity** (parar de herdar; usar `toEntity()`/`fromEntity()`), eliminando `_EquipamentoInline`.

### Mês 4 — Consistência de dados e navegação
- Migrar **Dashboard e Relatório para BLoC** (eliminar Firestore direto na UI).
- Migrar para **`StatefulShellRoute`** (preserva estado das abas, evita recriar streams) e mover RelatorioPage para dentro do GoRouter.
- Unificar fonte de verdade de auth (router consumindo o estado do `AuthBloc`).

### Mês 5 — Escala e performance
- **Paginação** (`limit` + cursor) nas listas de OS e Equipamentos.
- **Contador transacional** de número de OS (`runTransaction`/Cloud Function).
- **Agregações server-side** para Dashboard/Relatório (documentos de contadores ou aggregation queries) em vez de baixar tudo.
- Avaliar **escopo multi-tenant** (campo `hospitalId` + regras) para suportar mais de uma unidade.

### Mês 6 — Qualidade e robustez
- **Testes**: unitários de BLoC e repositório (com mocks via DI), testes de widget das telas-chave.
- **Estados de loading/erro** nas mutações (sem apagar a lista em falha).
- **Logging estruturado** (`logger`) e relato de erros (ex.: Crashlytics).
- Exportar **relatórios em PDF** e habilitar **modo offline** explícito (itens "Futuro" do CLAUDE.md).

---

## 7. Quick wins (baixo esforço, alto valor)

1. Corrigir `emit` no `onError` do `OsBloc`. *(evita crash)*
2. Adicionar delegates de localização no `main.dart`. *(evita exceção do DatePicker)*
3. Trocar `'concluida'` por `StatusOS.concluida.name` no repositório. *(elimina string mágica)*
4. Publicar `firestore.rules` mínimas. *(fecha o maior risco de segurança)*
5. Remover dependências não usadas do `pubspec`. *(reduz peso do build)*
