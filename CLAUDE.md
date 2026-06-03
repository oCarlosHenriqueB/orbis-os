# Orbis OS — CLAUDE.md

> Leia este arquivo no início de cada sessão antes de tocar em qualquer código.

---

## Identidade do Projeto

- **Nome no app:** Orbis OS
- **Package:** `com.carlosbresio.clinical_os_manager`
- **GitHub:** https://github.com/oCarlosHenriqueB/orbis-os
- **Domínio:** Gerenciador de Ordens de Serviço para Engenharia Clínica Hospitalar
- **Hospital:** Hospital e Maternidade Municipal Santa Ana — Santana de Parnaíba

---

## Stack

- Flutter 3.44.0 / Dart 3.12.0 / Apple M1 ARM64
- Clean Architecture + Feature-First
- `flutter_bloc` (BLoC pattern), `go_router`, `get_it`, `injectable`, `gap`, `intl`
- Firebase: `firebase_auth`, `cloud_firestore`, `firebase_core`
- Emulador: Pixel 8 Pro API 36 — `flutter run -d emulator-5554`

---

## Estrutura de Pastas

```
lib/
├── config/routes/app_router.dart       # GoRouter + ShellRoute (4 abas)
├── core/
│   ├── enums/app_enums.dart            # Todos os enums + nomeHospital
│   └── theme/app_theme.dart            # AppColors + AppTheme (Material 3)
├── features/
│   ├── auth/                           # Firebase Auth (BLoC completo)
│   ├── dashboard/                      # Stream Firestore em tempo real
│   ├── equipamento/                    # CRUD completo + BLoC + Firestore
│   ├── ordem_servico/                  # CRUD + BLoC + encerramento
│   └── perfil/                         # Info do usuário + logout
└── main.dart
```

---

## Identidade Visual (Material 3)

```dart
// AppColors — sempre usar estas constantes, nunca Color() direto
primary:           #0B4F6C  (Azul Petróleo)
secondary:         #1F2937  (Cinza Corporativo)
background:        #F0F4F8
surface:           #FFFFFF
statusAberta:      #2563EB  / bg: #EFF6FF
statusEmAtendimento:#0B4F6C / bg: #E8F4F8
statusAguardando:  #D97706  / bg: #FFFBEB
statusConcluida:   #059669  / bg: #ECFDF5
statusCancelada:   #6B7280  / bg: #F3F4F6
statusCalibracao:  #7C3AED  / bg: #F5F3FF
criticidadeAlta:   #DC2626  / bg: #FEF2F2
criticidadeMedia:  #D97706  / bg: #FFFBEB
criticidadeBaixa:  #059669  / bg: #ECFDF5
```

---

## Enums Principais

```dart
enum TipoManutencao { corretiva, preventiva, calibracao, inspecao, testeSeguranca }
enum Criticidade    { alta, media, baixa }
enum StatusOS       { aberta, emExecucao, aguardandoPeca, calibracao, validacaoUsuario, concluida, cancelada }
enum SetorHospital  { prontoSocorro, ambulatorio, utiAdulto, utiNeonatal, centroCirurgico, ... }
```

`SetorHospital` tem getter `.andar` (retorna `Andar`) e `.label`.  
`nomeHospital` e `municipioHospital` são constantes no final de `app_enums.dart`.

---

## O Que Já Está Implementado ✅

### Auth
- Login com email/senha via Firebase Auth
- Redirect automático via GoRouter (`authStateChanges`)
- BLoC: `AuthBloc` / `AuthLoginRequested` / `AuthLogoutRequested` / `AuthCheckRequested`

### Dashboard
- Stream do Firestore em tempo real
- Cards de stats: Abertas, Em Execução, Aguardando Peça, Concluídas
- Lista de OS críticas (criticidade Alta, não concluídas) — top 5

### Ordens de Serviço
- Lista com busca (equipamento, setor, número, problema, solicitante)
- Filtro por status (ícone com ponto laranja quando ativo)
- Formulário de criação/edição em modal bottom sheet
- Modal de detalhes com:
  - Informações completas da OS
  - Campos editáveis: descrição da solução + técnico responsável
  - Chips de atualização de status (exceto "Concluída")
  - Botão "Encerrar OS" (verde) → salva solução + técnico + `dataEncerramento` no Firestore
  - Modo somente leitura quando `concluida` ou `cancelada`
- BLoC: `OsStarted`, `OsListLoaded`, `OsSalvar`, `OsAtualizarStatus`, `OsEncerrar`
- Repository: `listar()`, `salvar()`, `atualizarStatus()`, `encerrar()`

### Equipamentos
- Lista com busca (nome, marca, modelo, NTag, setor)
- Formulário CRUD em modal bottom sheet
- Página de detalhe (`EquipamentoDetalhePage`) com histórico de OS do equipamento
- BLoC: `EquipamentoStarted`, `EquipamentoLoaded`, `EquipamentoSalvar`, `EquipamentoExcluir`

### Perfil
- Dados do usuário (email, iniciais)
- Info do hospital
- Logout com confirmação

### Navegação
- GoRouter com ShellRoute
- NavigationBar com 4 abas: Dashboard / OS / Equipamentos / Perfil

---

## Firestore — Estrutura das Coleções

### `ordens_servico`
```
numero, status, criticidade, tipoManutencao,
descricaoProblema, descricaoSolucao?, solicitante, tecnicoResponsavel?,
dataAbertura (Timestamp), dataEncerramento? (Timestamp),
equipamento: { id, nome, marca, modelo, ntag, setor, criticidade }
```

### `equipamentos`
```
nome, marca, modelo, ntagPatrimonio, setor, criticidade,
ativo (bool), ultimaManutencao? (Timestamp)
```

---

## O Que Já Está Implementado ✅ (atualizado)

### UX
- Borda colorida à esquerda do card de OS por criticidade
- Long press → menu rápido de troca de status (bottom sheet)
- Badge com contagem de OS filtradas e críticas
- Snackbar de confirmação após atualizar status e encerrar OS
- Busca em tempo real nas listas de OS e Equipamentos
- Banner animado de sem conexão (`ConnectivityBanner`) via `connectivity_plus`
- Widget `ErroConexao` amigável nas páginas de erro

### Relatórios
- Página `RelatorioPage` acessível pelo ícone 📊 no Dashboard
- Stats por status, tipo de manutenção, setor e técnico
- Filtro por período (DateRangePicker)
- Tempo médio de resolução calculado das OS encerradas

### Perfil
- Nome do técnico salvo localmente com `shared_preferences` (`PreferenciasService`)
- Pré-preenchimento automático do campo "Técnico responsável" ao encerrar OS
- Link para Política de Privacidade dentro do app

### Play Store (em andamento)
- Ícone gerado: `assets/images/app_icon.png` (1024x1024, cruz médica branca / fundo #0B4F6C)
- `flutter_launcher_icons` + `flutter_native_splash` configurados no `pubspec.yaml`
- `build.gradle.kts` configurado para ler `android/key.properties` (não commitado)
- `*.jks`, `*.keystore`, `android/key.properties` no `.gitignore`
- Política de privacidade: `docs/privacy-policy.html` (hospedar no GitHub Pages)
- Página de privacidade dentro do app (`PrivacidadePage`)

## Pendências / Próximos Passos

### Para publicar na Play Store (checklist)
1. ✅ Ícone + splash gerados (`dart run flutter_launcher_icons` + `dart run flutter_native_splash:create`)
2. ✅ Keystore gerado: `~/orbis-os-key.jks` — senha: `OrbisOS2025` — alias: `orbis-os`
3. ✅ `android/key.properties` criado (não commitado no git)
4. ✅ AAB gerado e assinado: `build/app/outputs/bundle/release/app-release.aab` (57.7MB)
5. ✅ Código commitado e pushed para o GitHub
6. ⬜ Ativar GitHub Pages no repositório (`/docs` branch `main`) → `https://ocarloshenriqueb.github.io/orbis-os/privacy-policy.html`
7. ⬜ Criar conta Google Play Console ($25 taxa única) → play.google.com/console
8. ⬜ Fazer upload do `.aab` na Play Store

### IMPORTANTE — Keystore
- Arquivo: `~/orbis-os-key.jks` (na home do Mac, NÃO no projeto)
- Senha: `OrbisOS2025`
- Alias: `orbis-os`
- Faça backup desse arquivo em local seguro — sem ele não dá para publicar atualizações

### Futuro (pós-publicação)
- Exportar relatórios em PDF
- Modo offline básico
- Testes com outros usuários

---

## Padrões de Código

- Sempre usar `AppColors.xxx` — nunca `Color(0xFF...)` diretamente nas páginas
- BLoC segue padrão: event → bloc handler → repository → state
- Modelos têm `fromFirestore(DocumentSnapshot)` e `toFirestore()`
- Assets: `assets/images/` e `assets/icons/` existem mas estão vazias (`.gitkeep`)
- `flutter run -d emulator-5554` para rodar no emulador Android
