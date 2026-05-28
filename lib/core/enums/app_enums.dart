enum TipoManutencao {
  corretiva,
  preventiva,
  calibracao;

  String get label => switch (this) {
    TipoManutencao.corretiva => 'Corretiva',
    TipoManutencao.preventiva => 'Preventiva',
    TipoManutencao.calibracao => 'Calibração',
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
  emAtendimento,
  aguardandoPeca,
  concluida;

  String get label => switch (this) {
    StatusOS.aberta => 'Aberta',
    StatusOS.emAtendimento => 'Em Atendimento',
    StatusOS.aguardandoPeca => 'Aguardando Peça',
    StatusOS.concluida => 'Concluída',
  };
}

enum SetorHospital {
  uti,
  centroCirurgico,
  prontoSocorro,
  enfermaria,
  maternidade,
  imagemDiagnostico,
  laboratorio,
  outros;

  String get label => switch (this) {
    SetorHospital.uti => 'UTI',
    SetorHospital.centroCirurgico => 'Centro Cirúrgico',
    SetorHospital.prontoSocorro => 'Pronto Socorro',
    SetorHospital.enfermaria => 'Enfermaria',
    SetorHospital.maternidade => 'Maternidade',
    SetorHospital.imagemDiagnostico => 'Imagem e Diagnóstico',
    SetorHospital.laboratorio => 'Laboratório',
    SetorHospital.outros => 'Outros',
  };
}
