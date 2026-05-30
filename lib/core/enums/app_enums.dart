enum TipoManutencao {
  corretiva,
  preventiva,
  calibracao,
  inspecao,
  testeSeguranca;

  String get label => switch (this) {
    TipoManutencao.corretiva => 'Corretiva',
    TipoManutencao.preventiva => 'Preventiva',
    TipoManutencao.calibracao => 'Calibração',
    TipoManutencao.inspecao => 'Inspeção',
    TipoManutencao.testeSeguranca => 'Teste de Segurança Elétrica',
  };
}

enum CategoriaOS {
  biomedico,
  predial,
  infraestrutura;

  String get label => switch (this) {
    CategoriaOS.biomedico => 'Biomédico',
    CategoriaOS.predial => 'Predial',
    CategoriaOS.infraestrutura => 'Infraestrutura',
  };
}

enum Criticidade {
  alta,
  media,
  baixa;

  String get label => switch (this) {
    Criticidade.alta => 'Alta — Suporte à Vida',
    Criticidade.media => 'Média',
    Criticidade.baixa => 'Baixa',
  };
}

enum StatusOS {
  aberta,
  emExecucao,
  aguardandoPeca,
  calibracao,
  validacaoUsuario,
  concluida,
  cancelada;

  String get label => switch (this) {
    StatusOS.aberta => 'Aberta',
    StatusOS.emExecucao => 'Em Execução',
    StatusOS.aguardandoPeca => 'Aguardando Peça',
    StatusOS.calibracao => 'Calibração/Teste',
    StatusOS.validacaoUsuario => 'Validação Usuário',
    StatusOS.concluida => 'Concluída',
    StatusOS.cancelada => 'Cancelada',
  };
}

enum StatusAtivo {
  ativo,
  emManutencao,
  aguardandoCalibracao,
  emprestado,
  baixado;

  String get label => switch (this) {
    StatusAtivo.ativo => 'Ativo',
    StatusAtivo.emManutencao => 'Em Manutenção',
    StatusAtivo.aguardandoCalibracao => 'Aguardando Calibração',
    StatusAtivo.emprestado => 'Emprestado',
    StatusAtivo.baixado => 'Baixado',
  };
}

enum Andar {
  terreo,
  primeiroAndar,
  segundoAndar,
  terceiroAndar;

  String get label => switch (this) {
    Andar.terreo => 'Térreo',
    Andar.primeiroAndar => '1º Andar',
    Andar.segundoAndar => '2º Andar',
    Andar.terceiroAndar => '3º Andar',
  };
}

enum SetorHospital {
  // Térreo
  prontoSocorro,
  ambulatorio,
  administrativo,
  sadt,
  // 1º Andar
  utiNeonatal,
  utiAdulto,
  centroParto,
  centroCirurgico,
  cme,
  // 2º Andar
  uci,
  enfermariasPediatria,
  utiPediatrica,
  brinquedoteca,
  maternidade,
  lactario,
  // 3º Andar
  clinicaCirurgica,
  clinicaMedica,
  // Geral
  outros;

  String get label => switch (this) {
    SetorHospital.prontoSocorro => 'Pronto-Socorro',
    SetorHospital.ambulatorio => 'Ambulatório',
    SetorHospital.administrativo => 'Administrativo',
    SetorHospital.sadt => 'SADT',
    SetorHospital.utiNeonatal => 'UTI Neonatal',
    SetorHospital.utiAdulto => 'UTI Adulto',
    SetorHospital.centroParto => 'Centro de Parto Normal',
    SetorHospital.centroCirurgico => 'Centro Cirúrgico',
    SetorHospital.cme => 'CME',
    SetorHospital.uci => 'UCI',
    SetorHospital.enfermariasPediatria => 'Enfermarias Pediatria',
    SetorHospital.utiPediatrica => 'UTI Pediátrica',
    SetorHospital.brinquedoteca => 'Brinquedoteca',
    SetorHospital.maternidade => 'Maternidade',
    SetorHospital.lactario => 'Lactário',
    SetorHospital.clinicaCirurgica => 'Clínica Cirúrgica',
    SetorHospital.clinicaMedica => 'Clínica Médica',
    SetorHospital.outros => 'Outros',
  };

  Andar get andar => switch (this) {
    SetorHospital.prontoSocorro ||
    SetorHospital.ambulatorio ||
    SetorHospital.administrativo ||
    SetorHospital.sadt => Andar.terreo,
    SetorHospital.utiNeonatal ||
    SetorHospital.utiAdulto ||
    SetorHospital.centroParto ||
    SetorHospital.centroCirurgico ||
    SetorHospital.cme => Andar.primeiroAndar,
    SetorHospital.uci ||
    SetorHospital.enfermariasPediatria ||
    SetorHospital.utiPediatrica ||
    SetorHospital.brinquedoteca ||
    SetorHospital.maternidade ||
    SetorHospital.lactario => Andar.segundoAndar,
    SetorHospital.clinicaCirurgica ||
    SetorHospital.clinicaMedica => Andar.terceiroAndar,
    SetorHospital.outros => Andar.terreo,
  };
}

// Nome oficial do hospital
const String nomeHospital = 'Hospital e Maternidade Municipal Santa Ana';
const String municipioHospital = 'Santana de Parnaíba';
