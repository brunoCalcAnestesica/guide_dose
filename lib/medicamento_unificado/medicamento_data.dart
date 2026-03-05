import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Modelo de dados para medicamento com suporte multilíngue
/// Estrutura baseada no JSON com pagina1 (cálculos) e pagina2 (detalhes)
class MedicamentoData {
  final String id;
  final String nome;
  final String classe;
  final List<ApresentacaoData> apresentacoes;
  final List<PreparoData> preparos;
  final List<IndicacaoData> indicacoes;
  final List<SliderInfusaoData> slidersInfusao;
  final List<String> observacoes;
  final AjustesEspeciaisData ajustesEspeciais;

  MedicamentoData({
    required this.id,
    required this.nome,
    required this.classe,
    required this.apresentacoes,
    required this.preparos,
    required this.indicacoes,
    required this.slidersInfusao,
    required this.observacoes,
    required this.ajustesEspeciais,
  });

  static final Map<String, Map<String, dynamic>> _jsonCache = {};

  /// Carrega medicamento de um arquivo JSON asset
  static Future<MedicamentoData> fromAsset(String assetPath, String idioma) async {
    final cached = _jsonCache[assetPath];
    if (cached != null) {
      return MedicamentoData.fromJson(cached, idioma, assetPath);
    }
    final jsonString = await rootBundle.loadString(assetPath);
    final json = await compute(_decodeJson, jsonString);
    _jsonCache[assetPath] = json;
    return MedicamentoData.fromJson(json, idioma, assetPath);
  }

  static Map<String, dynamic> _decodeJson(String raw) =>
      jsonDecode(raw) as Map<String, dynamic>;

  factory MedicamentoData.fromJson(Map<String, dynamic> json, String idioma, String assetPath) {
    // Aceita ZH como alias de CH (template usa ZH, app usa CH)
    final data = json[idioma] ?? (idioma == 'CH' ? json['ZH'] : null) ?? json['PT'] ?? <String, dynamic>{};
    final pagina1 = data['pagina1'] ?? {};
    final pagina2 = data['pagina2'] ?? {};
    
    // Extrai o ID do nome do arquivo (ex: adrenalina.json -> adrenalina)
    final id = assetPath.split('/').last.replaceAll('.json', '');
    
    // Obtém o nome traduzido - prioriza campo 'nome', depois vistaRapida, depois ID capitalizado
    String nome;
    if (data['nome'] != null) {
      nome = data['nome'];
    } else if (data['vistaRapida'] != null && (data['vistaRapida'] as List).isNotEmpty) {
      // Extrai o nome base do primeiro item de vistaRapida (ex: "Epinephrine (adult)" -> "Epinephrine")
      final primeiroNome = data['vistaRapida'][0]['nome'] ?? '';
      nome = primeiroNome.split(' (').first.split(' -').first.trim();
      if (nome.isEmpty) {
        nome = id[0].toUpperCase() + id.substring(1);
      }
    } else {
      nome = id[0].toUpperCase() + id.substring(1);
    }
    
    return MedicamentoData(
      id: id,
      nome: nome,
      classe: pagina2['classe'] ?? '',
      apresentacoes: (pagina2['apresentacoes'] as List? ?? [])
          .map((a) => ApresentacaoData.fromJson(a))
          .toList(),
      preparos: (pagina2['preparo'] as List? ?? [])
          .map((p) => PreparoData.fromJson(p))
          .toList(),
      indicacoes: (pagina1['indicacoes'] as List? ?? [])
          .map((i) => IndicacaoData.fromJson(i))
          .toList(),
      slidersInfusao: (pagina1['slidersInfusao'] as List? ?? [])
          .map((s) => SliderInfusaoData.fromJson(s))
          .toList(),
      observacoes: List<String>.from(pagina2['observacoes'] ?? []),
      ajustesEspeciais: AjustesEspeciaisData.fromJson(pagina2['ajustesEspeciais'] ?? {}),
    );
  }

  /// Retorna true se o medicamento tem indicações ou slider para a faixa etária.
  /// Quando [isAdulto] é false (pediátrico), retorna false para medicamentos apenas de adulto
  /// (ex: Angiotensina II), ocultando-os da lista de cálculos.
  bool temConteudoParaFaixaEtaria(bool isAdulto) {
    if (isAdulto) {
      final temIndicacaoAdulto = indicacoes.any((i) => i.parametros.isAdulto);
      final temSliderAdulto = slidersInfusao.any(
          (s) => s.adulto.doseMax > 0);
      return temIndicacaoAdulto || temSliderAdulto;
    } else {
      final temIndicacaoPediatrica =
          indicacoes.any((i) => i.parametros.isPediatrico);
      final temSliderPediatrico = slidersInfusao.any(
          (s) => s.pediatrico.doseMax > 0);
      return temIndicacaoPediatrica || temSliderPediatrico;
    }
  }
}

/// Dados de apresentação do medicamento
class ApresentacaoData {
  final String forma;
  final String obs;

  ApresentacaoData({
    required this.forma,
    required this.obs,
  });

  factory ApresentacaoData.fromJson(Map<String, dynamic> json) {
    return ApresentacaoData(
      forma: json['forma'] ?? '',
      obs: json['obs'] ?? '',
    );
  }
}

/// Dados de preparo/diluição
class PreparoData {
  final String diluicao;
  final String concentracao;

  PreparoData({
    required this.diluicao,
    required this.concentracao,
  });

  factory PreparoData.fromJson(Map<String, dynamic> json) {
    return PreparoData(
      diluicao: json['diluicao'] ?? '',
      concentracao: json['concentracao'] ?? '',
    );
  }
}

/// Dados de indicação clínica
class IndicacaoData {
  final String titulo;
  final String descricaoDose;
  final String tipoDose; // 'fixa', 'calculada', 'infusao'
  final ParametrosIndicacaoData parametros;

  IndicacaoData({
    required this.titulo,
    required this.descricaoDose,
    required this.tipoDose,
    required this.parametros,
  });

  factory IndicacaoData.fromJson(Map<String, dynamic> json) {
    return IndicacaoData(
      titulo: json['titulo'] ?? '',
      descricaoDose: json['descricaoDose'] ?? '',
      tipoDose: json['tipoDose'] ?? 'fixa',
      parametros: ParametrosIndicacaoData.fromJson(json['parametros'] ?? {}),
    );
  }

  bool get isFixa => tipoDose == 'fixa';
  bool get isCalculada => tipoDose == 'calculada';
  bool get isInfusao => tipoDose == 'infusao';
}

/// Parâmetros da indicação
class ParametrosIndicacaoData {
  final String unidade;
  final double? dosePorKg;
  final double? dosePorKgMin;  // Para faixas de dose calculada (ex: 1-2 mg/kg)
  final double? dosePorKgMax;  // Para faixas de dose calculada (ex: 1-2 mg/kg)
  final double? doseMin;
  final double? doseMax;
  final double? doseMaxima;
  final String? doseFixa;
  final String faixaEtaria;
  final String sexo;
  final String via;
  final String intervalo;
  final String ajusteRenal;
  final String ajusteHepatico;
  
  // Campos para ajuste automático baseado em função renal
  final double? clCrThreshold;      // ClCr abaixo do qual aplica ajuste (ex: 30)
  final double? fatorAjusteRenal;   // Fator de multiplicação (ex: 0.5 para 50%)

  ParametrosIndicacaoData({
    required this.unidade,
    this.dosePorKg,
    this.dosePorKgMin,
    this.dosePorKgMax,
    this.doseMin,
    this.doseMax,
    this.doseMaxima,
    this.doseFixa,
    required this.faixaEtaria,
    required this.sexo,
    required this.via,
    required this.intervalo,
    required this.ajusteRenal,
    required this.ajusteHepatico,
    this.clCrThreshold,
    this.fatorAjusteRenal,
  });

  factory ParametrosIndicacaoData.fromJson(Map<String, dynamic> json) {
    return ParametrosIndicacaoData(
      unidade: json['unidade'] ?? 'mg',
      dosePorKg: json['dosePorKg']?.toDouble(),
      dosePorKgMin: json['dosePorKgMin']?.toDouble(),
      dosePorKgMax: json['dosePorKgMax']?.toDouble(),
      doseMin: json['doseMin']?.toDouble(),
      doseMax: json['doseMax']?.toDouble(),
      doseMaxima: json['doseMaxima']?.toDouble(),
      doseFixa: json['doseFixa'],
      faixaEtaria: json['faixaEtaria'] ?? 'Todas',
      sexo: json['sexo'] ?? 'Todos',
      via: json['via'] ?? '',
      intervalo: json['intervalo'] ?? '',
      ajusteRenal: json['ajusteRenal'] ?? 'NAO',
      ajusteHepatico: json['ajusteHepatico'] ?? 'NAO',
      clCrThreshold: json['clCrThreshold']?.toDouble(),
      fatorAjusteRenal: json['fatorAjusteRenal']?.toDouble(),
    );
  }

  /// Verifica se é para adultos (suporta múltiplos idiomas)
  bool get isAdulto {
    final lower = faixaEtaria.toLowerCase();
    return lower == 'adulto' || 
           lower == 'adult' || 
           lower == 'todas' || 
           lower == 'all' ||
           lower == '成人' ||  // Chinês
           lower == '所有';    // Chinês (todas)
  }
  
  /// Verifica se é pediátrico (suporta múltiplos idiomas)
  bool get isPediatrico {
    final lower = faixaEtaria.toLowerCase();
    return lower == 'pediátrico' || 
           lower == 'pediatrico' || 
           lower == 'pediatric' || 
           lower == 'todas' || 
           lower == 'all' ||
           lower == '儿童' ||  // Chinês (pediátrico)
           lower == '所有';    // Chinês (todas)
  }
}

/// Dados do slider de infusão
class SliderInfusaoData {
  final String titulo;
  final String unidade;
  final DoseFaixaData adulto;
  final DoseFaixaData pediatrico;
  final bool concentracaoEmMcg;
  final List<OpcaoConcentracaoData> opcoesConcentracao;
  final double fatorTempo; // 60 para mcg/kg/min, 1 para UI/kg/h ou mcg/kg/h

  SliderInfusaoData({
    required this.titulo,
    required this.unidade,
    required this.adulto,
    required this.pediatrico,
    required this.concentracaoEmMcg,
    required this.opcoesConcentracao,
    this.fatorTempo = 60, // padrão para mcg/kg/min
  });

  factory SliderInfusaoData.fromJson(Map<String, dynamic> json) {
    return SliderInfusaoData(
      titulo: json['titulo'] ?? 'Infusão Contínua',
      unidade: json['unidade'] ?? 'mcg/kg/min',
      adulto: DoseFaixaData.fromJson(json['adulto']),
      pediatrico: DoseFaixaData.fromJson(json['pediatrico']),
      concentracaoEmMcg: json['concentracaoEmMcg'] ?? true,
      opcoesConcentracao: (json['opcoesConcentracao'] as List? ?? [])
          .map((o) => OpcaoConcentracaoData.fromJson(o))
          .toList(),
      fatorTempo: (json['fatorTempo'] ?? 60).toDouble(),
    );
  }
}

/// Faixa de dose (min/max)
class DoseFaixaData {
  final double doseMin;
  final double doseMax;

  DoseFaixaData({
    required this.doseMin,
    required this.doseMax,
  });

  factory DoseFaixaData.fromJson(Map<String, dynamic>? json) {
    // Se json for null, retorna faixa zerada (slider inválido para essa faixa etária)
    if (json == null) {
      return DoseFaixaData(doseMin: 0.0, doseMax: 0.0);
    }
    return DoseFaixaData(
      doseMin: json['doseMin']?.toDouble() ?? 0.0,
      doseMax: json['doseMax']?.toDouble() ?? 0.0,
    );
  }
}

/// Opção de concentração para o slider
class OpcaoConcentracaoData {
  final String rotulo;
  final double valor;

  OpcaoConcentracaoData({
    required this.rotulo,
    required this.valor,
  });

  factory OpcaoConcentracaoData.fromJson(Map<String, dynamic> json) {
    return OpcaoConcentracaoData(
      rotulo: json['rotulo'] ?? '',
      valor: json['valor']?.toDouble() ?? 0.0,
    );
  }
}

/// Ajustes especiais (idoso, renal, hepático)
class AjustesEspeciaisData {
  final String idoso;
  final String renal;
  final String hepatico;

  AjustesEspeciaisData({
    required this.idoso,
    required this.renal,
    required this.hepatico,
  });

  factory AjustesEspeciaisData.fromJson(Map<String, dynamic> json) {
    return AjustesEspeciaisData(
      idoso: json['idoso'] ?? 'Não requer ajuste',
      renal: json['renal'] ?? 'Não requer ajuste',
      hepatico: json['hepatico'] ?? 'Não requer ajuste',
    );
  }
}
