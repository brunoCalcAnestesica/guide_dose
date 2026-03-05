import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../shared_data.dart';
import '../drogas_card/drogas.dart';
import 'unit_converter.dart';

// Função auxiliar para conversão segura de tipos numéricos
double? _convertToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Função para converter doses de mcg para mg quando apropriado
String _formatarDoseComConversao(double dose, String unidade) {
  if (unidade.toLowerCase().contains('mcg') && dose >= 100) {
    final doseEmMg = dose / 1000;
    return '${doseEmMg.toStringAsFixed(2)} mg';
  }
  return '${dose.toStringAsFixed(2)} $unidade';
}

// Função auxiliar para mapear faixa etária para chave JSON
String _getFaixaEtariaKey(String faixaEtaria) {
  switch (faixaEtaria) {
    case 'Recém-nascido':
      return 'recem_nascido';
    case 'Lactente':
      return 'lactente';
    case 'Criança':
      return 'crianca';
    case 'Adolescente':
      return 'adolescente';
    case 'Adulto':
      return 'adulto';
    case 'Idoso':
      return 'idoso';
    default:
      return 'adulto';
  }
}

// Widget para linha de preparo minimalista
Widget _linhaPreparo(String texto, String observacao) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $texto',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        if (observacao.isNotEmpty) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              observacao,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

// Widget para linha de indicação com dose calculada
Widget _linhaIndicacaoDoseCalculada({
  required String titulo,
  required String descricaoDose,
  double? dosePorKg,
  double? dosePorKgMinima,
  double? dosePorKgMaxima,
  double? doseMaxima,
  double? doseMinima,
  double? doseLimite,
  String unidade = '',
  required double peso,
}) {
  String doseCalculada = '';

  debugPrint('💊 DEBUG: Calculando dose para: $titulo');
  debugPrint('💊 DEBUG: Unidade: $unidade');
  debugPrint('💊 DEBUG: Peso: $peso kg');

  // Verificar se a unidade é uma infusão contínua usando o UnitConverter
  final isInfusaoContinua = UnitConverter.isInfusionUnit(unidade);
  debugPrint('💊 DEBUG: É infusão contínua: $isInfusaoContinua');

  if (!isInfusaoContinua) {
    debugPrint('💊 DEBUG: Processando como dose de bolus...');
    // Fazer cálculo para doses únicas (mg/kg, mcg/kg, mg, mcg, etc.)
    if (dosePorKg != null) {
      final dose = dosePorKg * peso;
      // Aplicar dose limite se especificada
      final doseFinal =
          doseLimite != null && dose > doseLimite ? doseLimite : dose;
      if (doseMaxima != null && doseFinal > doseMaxima) {
        doseCalculada =
            _formatarDoseComConversao(doseMaxima, unidade) + ' (máx)';
      } else if (doseLimite != null && dose > doseLimite) {
        doseCalculada =
            _formatarDoseComConversao(doseFinal, unidade) + ' (limite)';
      } else {
        doseCalculada = _formatarDoseComConversao(doseFinal, unidade);
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      final doseMin = dosePorKgMinima * peso;
      final doseMax = dosePorKgMaxima * peso;

      // Aplicar dose limite se especificada
      final doseMinFinal =
          doseLimite != null && doseMin > doseLimite ? doseLimite : doseMin;
      final doseMaxFinal =
          doseLimite != null && doseMax > doseLimite ? doseLimite : doseMax;

      if (doseMaxima != null) {
        final doseMinAplicada =
            doseMinFinal > doseMaxima ? doseMaxima : doseMinFinal;
        final doseMaxAplicada =
            doseMaxFinal > doseMaxima ? doseMaxima : doseMaxFinal;
        if (doseMinAplicada == doseMaxAplicada) {
          doseCalculada = _formatarDoseComConversao(doseMinAplicada, unidade);
        } else {
          doseCalculada =
              '${_formatarDoseComConversao(doseMinAplicada, unidade)} - ${_formatarDoseComConversao(doseMaxAplicada, unidade)}';
        }
      } else {
        if (doseMinFinal == doseMaxFinal) {
          doseCalculada = _formatarDoseComConversao(doseMinFinal, unidade);
        } else {
          doseCalculada =
              '${_formatarDoseComConversao(doseMinFinal, unidade)} - ${_formatarDoseComConversao(doseMaxFinal, unidade)}';
        }
        // Adicionar indicação de limite se aplicado
        if (doseLimite != null &&
            (doseMin > doseLimite || doseMax > doseLimite)) {
          doseCalculada += ' (limite)';
        }
      }
    } else if (doseMinima != null && doseMaxima != null) {
      // Doses fixas (não calculadas por peso)
      if (doseMinima == doseMaxima) {
        doseCalculada = _formatarDoseComConversao(doseMinima, unidade);
      } else {
        doseCalculada =
            '${_formatarDoseComConversao(doseMinima, unidade)} - ${_formatarDoseComConversao(doseMaxima, unidade)}';
      }
      // Adicionar dose limite se especificada
      if (doseLimite != null) {
        doseCalculada +=
            ' (limite: ${_formatarDoseComConversao(doseLimite, unidade)})';
      }
    } else if (doseMaxima != null) {
      // Dose única fixa
      doseCalculada = _formatarDoseComConversao(doseMaxima, unidade);
      // Adicionar dose limite se especificada
      if (doseLimite != null) {
        doseCalculada +=
            ' (limite: ${_formatarDoseComConversao(doseLimite, unidade)})';
      }
    }
  }

  debugPrint('💊 DEBUG: Dose calculada final: $doseCalculada');
  debugPrint('💊 DEBUG: --- Fim do cálculo ---\n');

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            if (doseCalculada.isNotEmpty) ...[
              Text(
                doseCalculada,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ],
        ),
        if (descricaoDose.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            descricaoDose,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    ),
  );
}

// Widget para texto de observação minimalista
Widget _textoObs(String texto) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade700,
      ),
    ),
  );
}

// Widget para título de seção minimalista
Widget _buildSecaoTitulo(String titulo, IconData icone) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(
          icone,
          color: Colors.grey.shade700,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    ),
  );
}

// Função para construir indicações por faixa etária
List<Widget> _buildIndicacoesPorFaixa(
    Map<String, dynamic>? indicacoes, String faixaEtariaKey, double peso) {
  debugPrint('🔍 DEBUG: Processando indicações para faixa etária: $faixaEtariaKey');
  debugPrint('🔍 DEBUG: Peso do paciente: $peso kg');

  if (indicacoes == null || !indicacoes.containsKey(faixaEtariaKey)) {
    debugPrint(
        '❌ DEBUG: Indicações não disponíveis para faixa etária: $faixaEtariaKey');
    return [const Text('Indicações não disponíveis para esta faixa etária.')];
  }

  final indicacoesFaixa = indicacoes[faixaEtariaKey];
  if (indicacoesFaixa is! List) {
    debugPrint(
        '❌ DEBUG: Formato de indicações inválido para faixa etária: $faixaEtariaKey');
    return [
      const Text('Formato de indicações inválido para esta faixa etária.')
    ];
  }

  if (indicacoesFaixa.isEmpty) {
    debugPrint(
        '❌ DEBUG: Nenhuma indicação específica para faixa etária: $faixaEtariaKey');
    return [const Text('Nenhuma indicação específica para esta faixa etária.')];
  }

  debugPrint(
      '✅ DEBUG: Encontradas ${indicacoesFaixa.length} indicações para $faixaEtariaKey');

  return indicacoesFaixa.map<Widget>((indicacao) {
    final dados = indicacao as Map<String, dynamic>;

    debugPrint('📋 DEBUG: Processando indicação: ${dados['titulo']}');
    debugPrint('📋 DEBUG: Descrição da dose: ${dados['descricaoDose']}');
    debugPrint('📋 DEBUG: Unidade: ${dados['unidade']}');

    // Tratamento especial para doses calculadas por peso
    double? dosePorKgMinima;
    double? dosePorKgMaxima;

    if (dados['dosePorKgMinima'] is String &&
        dados['dosePorKgMinima'].contains('/ peso')) {
      final valor = double.tryParse(
          dados['dosePorKgMinima'].toString().split('/ peso')[0].trim());
      dosePorKgMinima = valor != null ? valor / peso : null;
      debugPrint('📋 DEBUG: Dose por kg mínima (especial): $dosePorKgMinima');
    } else {
      dosePorKgMinima = _convertToDouble(dados['dosePorKgMinima']);
      debugPrint('📋 DEBUG: Dose por kg mínima: $dosePorKgMinima');
    }

    if (dados['dosePorKgMaxima'] is String &&
        dados['dosePorKgMaxima'].contains('/ peso')) {
      final valor = double.tryParse(
          dados['dosePorKgMaxima'].toString().split('/ peso')[0].trim());
      dosePorKgMaxima = valor != null ? valor / peso : null;
      debugPrint('📋 DEBUG: Dose por kg máxima (especial): $dosePorKgMaxima');
    } else {
      dosePorKgMaxima = _convertToDouble(dados['dosePorKgMaxima']);
      debugPrint('📋 DEBUG: Dose por kg máxima: $dosePorKgMaxima');
    }

    // Verificar se tem dose fixa (doseMinima/doseMaxima) ou dose por kg
    final doseMinima = _convertToDouble(dados['doseMinima']);
    final doseMaxima = _convertToDouble(dados['doseMaxima']);

    debugPrint('📋 DEBUG: Dose mínima fixa: $doseMinima');
    debugPrint('📋 DEBUG: Dose máxima fixa: $doseMaxima');

    // Mostrar indicações específicas se existirem
    if (dados['indicacoes'] != null) {
      final indicacoesEspecificas = dados['indicacoes'] as List;
      debugPrint(
          '📋 DEBUG: Indicações específicas (${indicacoesEspecificas.length} itens):');
      for (int i = 0; i < indicacoesEspecificas.length; i++) {
        debugPrint('  ${i + 1}. ${indicacoesEspecificas[i]}');
      }
    } else {
      debugPrint('📋 DEBUG: Nenhuma indicação específica encontrada');
    }

    return _linhaIndicacaoDoseCalculada(
      titulo: dados['titulo'] ?? '',
      descricaoDose: dados['descricaoDose'] ?? dados['dose'] ?? '',
      dosePorKg: _convertToDouble(dados['dosePorKg']),
      dosePorKgMinima: dosePorKgMinima,
      dosePorKgMaxima: dosePorKgMaxima,
      doseMinima: doseMinima,
      doseMaxima: doseMaxima,
      doseLimite: _convertToDouble(dados['doseLimite']),
      unidade: dados['unidade'] ?? '',
      peso: peso,
    );
  }).toList();
}

// Enum para classificar tipos de medicamentos
enum TipoMedicamento {
  apenasInfusao, // Só infusão contínua
  apenasBolus, // Só bolus/doses únicas
  misto // Pode ser bolus, infusão ou ambos
}

// Função para classificar o tipo de medicamento baseado nas indicações
TipoMedicamento _classificarTipoMedicamento(Map<String, dynamic>? indicacoes) {
  if (indicacoes == null) return TipoMedicamento.apenasBolus;

  bool temDosesBolus = false;
  bool temDosesInfusao = false;

  // Verificar todas as faixas etárias
  for (final faixaEtaria in indicacoes.values) {
    if (faixaEtaria is List) {
      for (final indicacao in faixaEtaria) {
        if (indicacao is Map<String, dynamic>) {
          final unidade = indicacao['unidade']?.toString().toLowerCase() ?? '';

          // Usar UnitConverter para detectar infusões contínuas
          if (UnitConverter.isInfusionUnit(unidade)) {
            temDosesInfusao = true;
          } else {
            // Se não é infusão contínua, é dose única (bolus)
            temDosesBolus = true;
          }
        }
      }
    }
  }

  // Classificar baseado no que foi encontrado
  if (temDosesInfusao && !temDosesBolus) {
    return TipoMedicamento.apenasInfusao;
  } else if (temDosesBolus && !temDosesInfusao) {
    return TipoMedicamento.apenasBolus;
  } else {
    return TipoMedicamento.misto;
  }
}

// Função para determinar se deve mostrar a calculadora de infusão
bool _deveMostrarCalculadoraInfusao(
    Map<String, dynamic>? infusao, TipoMedicamento tipo) {
  if (infusao == null) return false;

  // Para medicamentos apenas de infusão ou mistos, sempre mostrar se há infusão
  if (tipo == TipoMedicamento.apenasInfusao || tipo == TipoMedicamento.misto) {
    final unidade = infusao['unidade']?.toString().toLowerCase() ?? '';
    return unidade.contains('/min') || unidade.contains('/h');
  }

  return false;
}

// Função para determinar se deve mostrar o cálculo de doses (bolus)
bool _deveMostrarCalculoDoses(
    Map<String, dynamic>? infusao,
    Map<String, dynamic>? indicacoes,
    String faixaEtariaKey,
    TipoMedicamento tipo) {
  // Para medicamentos apenas de infusão, nunca mostrar cálculo de bolus
  if (tipo == TipoMedicamento.apenasInfusao) return false;

  // Para medicamentos apenas de bolus, sempre mostrar se há indicações
  if (tipo == TipoMedicamento.apenasBolus) {
    return indicacoes != null && indicacoes.containsKey(faixaEtariaKey);
  }

  // Para medicamentos mistos, verificar se há doses de bolus nas indicações
  if (tipo == TipoMedicamento.misto &&
      indicacoes != null &&
      indicacoes.containsKey(faixaEtariaKey)) {
    final indicacoesFaixa = indicacoes[faixaEtariaKey];
    if (indicacoesFaixa is! List) {
      return false;
    }
    for (final indicacao in indicacoesFaixa) {
      final dados = indicacao as Map<String, dynamic>;
      final unidade = dados['unidade']?.toString().toLowerCase() ?? '';

      // Se a unidade não contém /min ou /h, é dose única (bolus)
      if (!unidade.contains('/min') && !unidade.contains('/h')) {
        return true;
      }
    }
  }

  return false;
}

// Função para obter o título da calculadora baseado no tipo de medicamento
String _getTituloCalculadora(
    TipoMedicamento tipo, Map<String, dynamic>? infusao) {
  switch (tipo) {
    case TipoMedicamento.apenasInfusao:
      return 'Cálculo de Infusão Contínua';
    case TipoMedicamento.apenasBolus:
      return 'Cálculo de Doses';
    case TipoMedicamento.misto:
      if (infusao != null) {
        final unidade = infusao['unidade']?.toString().toLowerCase() ?? '';
        if (unidade.contains('/min') || unidade.contains('/h')) {
          return 'Cálculo de Infusão Contínua';
        }
      }
      return 'Cálculo de Doses';
  }
}

// Função para obter o ícone da calculadora baseado no tipo de medicamento
IconData _getIconeCalculadora(TipoMedicamento tipo) {
  switch (tipo) {
    case TipoMedicamento.apenasInfusao:
      return Icons.speed;
    case TipoMedicamento.apenasBolus:
      return Icons.calculate;
    case TipoMedicamento.misto:
      return Icons.medical_services;
  }
}

// Widget para calculadora de infusão
Widget _buildCalculadoraInfusao(Map<String, dynamic>? infusao, double peso) {
  if (infusao == null) {
    return const Text('Calculadora de infusão não disponível.');
  }

  final opcoesConcentracoes = <String, double>{};
  final opcoesMap = infusao['opcoesConcentracoes'] as Map? ?? {};

  // Processar concentrações e garantir unidades corretas
  for (final entry in opcoesMap.entries) {
    final nomeConcentracao = entry.key.toString();
    final valorConcentracao = _convertToDouble(entry.value) ?? 0.0;

    // Usar UnitConverter para detectar o tipo de infusão e normalizar concentração
    final unidade = infusao['unidade'] ?? 'mcg/kg/min';
    final infusionType = UnitConverter.detectInfusionType(unidade);

    double concentracaoFinal = valorConcentracao;

    // Normalizar concentração baseada no tipo de infusão detectado
    if (infusionType.contains('mcg')) {
      // Dose em mcg - normalizar concentração para mcg/mL
      if (nomeConcentracao.contains('mg/mL')) {
        concentracaoFinal = valorConcentracao * 1000; // mg/mL para mcg/mL
      } else if (nomeConcentracao.contains('mcg/mL')) {
        concentracaoFinal = valorConcentracao; // já está em mcg/mL
      } else {
        // Se não especifica a unidade no nome, assumir que o valor já está correto
        concentracaoFinal = valorConcentracao;
      }
    } else if (infusionType.contains('mg')) {
      // Dose em mg - normalizar concentração para mg/mL
      if (nomeConcentracao.contains('mcg/mL')) {
        concentracaoFinal = valorConcentracao / 1000; // mcg/mL para mg/mL
      } else if (nomeConcentracao.contains('mg/mL')) {
        concentracaoFinal = valorConcentracao; // já está em mg/mL
      } else {
        // Se não especifica a unidade no nome, assumir que o valor já está correto
        concentracaoFinal = valorConcentracao;
      }
    } else {
      // Fallback: assumir mcg/kg/min
      if (nomeConcentracao.contains('mg/mL')) {
        concentracaoFinal = valorConcentracao * 1000; // mg/mL para mcg/mL
      } else if (nomeConcentracao.contains('mcg/mL')) {
        concentracaoFinal = valorConcentracao; // já está em mcg/mL
      } else {
        // Se não especifica a unidade no nome, assumir que o valor já está correto
        concentracaoFinal = valorConcentracao;
      }
    }

    opcoesConcentracoes[nomeConcentracao] = concentracaoFinal;
  }

  return ConversaoInfusaoSlider(
    peso: peso,
    opcoesConcentracoes: opcoesConcentracoes,
    unidade: infusao['unidade'] ?? 'mcg/kg/min',
    doseMin: _convertToDouble(infusao['doseMin']) ?? 0.05,
    doseMax: _convertToDouble(infusao['doseMax']) ?? 2.0,
  );
}

// Card de informações do medicamento (baseado em dados JSON)
Widget _buildCardMedicamento(
  BuildContext context,
  double peso,
  bool isAdulto,
  Map<String, dynamic> dados,
  String nomeMedicamento,
) {
  final faixaEtaria = SharedData.faixaEtaria;
  final faixaEtariaKey = _getFaixaEtariaKey(faixaEtaria);

  // Extrair dados do medicamento (pode estar em wrapper ou diretamente)
  final medicamentoData = dados.containsKey('nome')
      ? dados
      : (dados.values.isNotEmpty ? dados.values.first as Map<String, dynamic>? : null) ?? dados;

  // Classificar o tipo de medicamento
  final tipoMedicamento =
      _classificarTipoMedicamento(medicamentoData['indicacoes']);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      if (medicamentoData['classe'] != null) ...[
        Text(
          medicamentoData['classe'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],

      // Apresentações
      _buildSecaoTitulo('Apresentações', Icons.medication_liquid),
      const SizedBox(height: 8),
      if (medicamentoData['apresentacoes'] != null) ...[
        ...(() {
          final apresentacoes = medicamentoData['apresentacoes'];
          if (apresentacoes is! List) return <Widget>[];
          return apresentacoes.map(
            (apresentacao) => _linhaPreparo(
              apresentacao['nome'] ?? '',
              apresentacao['observacao'] ?? '',
            ),
          );
        })(),
      ] else if (medicamentoData['apresentacao'] != null) ...[
        _textoObs('• ${medicamentoData['apresentacao']}'),
      ] else ...[
        _textoObs('• Informação não disponível'),
      ],

      const SizedBox(height: 16),
      // Preparo
      _buildSecaoTitulo('Preparo', Icons.science),
      const SizedBox(height: 8),
      ...(() {
        final preparo = medicamentoData['preparo'];
        if (preparo is! List) return <Widget>[];
        return preparo.map(
          (prep) => _linhaPreparo(
            prep['nome'] ?? prep.toString(),
            prep['observacao'] ?? '',
          ),
        );
      })(),

      const SizedBox(height: 16),
      // Indicações clínicas
      _buildSecaoTitulo('Indicações clínicas', Icons.medical_information),
      const SizedBox(height: 8),
      ..._buildIndicacoesPorFaixa(
          medicamentoData['indicacoes'], faixaEtariaKey, peso),

      // Cálculo de Doses/Infusão - lógica inteligente baseada no tipo de medicamento
      if (_deveMostrarCalculadoraInfusao(
              medicamentoData['infusao'], tipoMedicamento) ||
          _deveMostrarCalculoDoses(
              medicamentoData['infusao'],
              medicamentoData['indicacoes'],
              faixaEtariaKey,
              tipoMedicamento)) ...[
        const SizedBox(height: 16),
        // Título baseado no tipo de medicamento - só mostrar se não for apenas bolus
        if (tipoMedicamento != TipoMedicamento.apenasBolus) ...[
          _buildSecaoTitulo(
              _getTituloCalculadora(
                  tipoMedicamento, medicamentoData['infusao']),
              _getIconeCalculadora(tipoMedicamento)),
          const SizedBox(height: 8),
        ],
        // Mostrar calculadora de infusão se necessário
        if (_deveMostrarCalculadoraInfusao(
            medicamentoData['infusao'], tipoMedicamento))
          _buildCalculadoraInfusao(medicamentoData['infusao'], peso),
      ],
    ],
  );
}

// Classe genérica para medicamentos
class MedicamentoGenerico {
  final String nome;
  final String idBulario;
  final String arquivoJson;

  static final Map<String, Map<String, dynamic>> _jsonCache = {};

  const MedicamentoGenerico({
    required this.nome,
    required this.idBulario,
    required this.arquivoJson,
  });

  static Map<String, dynamic> _decodeJson(String raw) =>
      json.decode(raw) as Map<String, dynamic>;

  Future<Map<String, dynamic>> carregarDados() async {
    final cacheKey = 'farmacoteca/$arquivoJson';
    final cached = _jsonCache[cacheKey];
    if (cached != null) return cached;
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/farmacoteca/$arquivoJson');
      final Map<String, dynamic> jsonMap = await compute(_decodeJson, jsonStr);
      _jsonCache[cacheKey] = jsonMap;
      return jsonMap;
    } catch (e) {
      throw Exception('Erro ao carregar dados de $nome: $e');
    }
  }

  Future<Map<String, dynamic>> carregarBulario() async {
    final cacheKey = 'medicamentos/$arquivoJson';
    final cached = _jsonCache[cacheKey];
    if (cached != null) return cached['PT']?['bulario'] ?? {'erro': 'Bulário não encontrado'};
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/medicamentos/$arquivoJson');
      final Map<String, dynamic> jsonMap = await compute(_decodeJson, jsonStr);
      _jsonCache[cacheKey] = jsonMap;
      return jsonMap['PT']['bulario'];
    } catch (e) {
      throw Exception('Erro ao carregar bulário de $nome: $e');
    }
  }

  Widget buildCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: carregarDados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erro ao carregar $nome',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final dados = snapshot.data ?? {};
        final peso = SharedData.peso ?? 70;
        final isAdulto = SharedData.faixaEtaria == 'Adulto' ||
            SharedData.faixaEtaria == 'Idoso';

        return buildMedicamentoExpansivel(
          context: context,
          nome: nome,
          idBulario: idBulario,
          isFavorito: false,
          onToggleFavorito: () {},
          conteudo: _buildCardMedicamento(
            context,
            peso,
            isAdulto,
            dados,
            nome,
          ),
        );
      },
    );
  }
}

// Classe para gerenciar todos os medicamentos da farmacoteca
class FarmacotecaManager {
  static List<MedicamentoGenerico> _medicamentos = [
    const MedicamentoGenerico(
      nome: 'Acetazolamida',
      idBulario: 'acetazolamida',
      arquivoJson: '001_acetazolamida.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ácido Aminocaproico',
      idBulario: 'acido_aminocaproico',
      arquivoJson: '002_acido_aminocaproico.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ácido Tranexâmico',
      idBulario: 'acido_tranexamico',
      arquivoJson: '003_acido_tranexamico.json',
    ),
    const MedicamentoGenerico(
      nome: 'Adenosina',
      idBulario: 'adenosina',
      arquivoJson: '004_adenosina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Adrenalina',
      idBulario: 'adrenalina',
      arquivoJson: '005_adrenalina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Água Destilada',
      idBulario: 'agua_destilada',
      arquivoJson: '006_agua_destilada.json',
    ),
    const MedicamentoGenerico(
      nome: 'Alfentanil',
      idBulario: 'alfentanil',
      arquivoJson: '007_alfentanil.json',
    ),
    const MedicamentoGenerico(
      nome: 'Alteplase',
      idBulario: 'alteplase',
      arquivoJson: '008_alteplase.json',
    ),
    const MedicamentoGenerico(
      nome: 'Amiodarona',
      idBulario: 'amiodarona',
      arquivoJson: '009_amiodarona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Atracúrio',
      idBulario: 'atracurio',
      arquivoJson: '010_atracurio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Atropina',
      idBulario: 'atropina',
      arquivoJson: '011_atropina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Betametasona',
      idBulario: 'betametasona',
      arquivoJson: '013_betametasona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Bicarbonato de Sódio',
      idBulario: 'bicarbonato_sodio',
      arquivoJson: '014_bicarbonato_sodio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Bromoprida',
      idBulario: 'bromoprida',
      arquivoJson: '015_bromoprida.json',
    ),
    const MedicamentoGenerico(
      nome: 'Bumetadina',
      idBulario: 'bumetadina',
      arquivoJson: '016_bumetadina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Bupivacaína',
      idBulario: 'bupivacaina',
      arquivoJson: '017_bupivacaina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Buprenorfina',
      idBulario: 'buprenorfina',
      arquivoJson: '018_buprenorfina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Cefazolina',
      idBulario: 'cefazolina',
      arquivoJson: '019_cefazolina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ceftriaxona',
      idBulario: 'ceftriaxona',
      arquivoJson: '020_ceftriaxona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Cefuroxima',
      idBulario: 'cefuroxima',
      arquivoJson: '021_cefuroxima.json',
    ),
    const MedicamentoGenerico(
      nome: 'Cetamina',
      idBulario: 'cetamina',
      arquivoJson: '022_cetamina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Cisatracúrio',
      idBulario: 'cisatracurio',
      arquivoJson: '023_cisatracurio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Clemastina',
      idBulario: 'clemastina',
      arquivoJson: '024_clemastina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Clindamicina',
      idBulario: 'clindamicina',
      arquivoJson: '025_clindamicina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Clonidina',
      idBulario: 'clonidina',
      arquivoJson: '026_clonidina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Cloreto de Cálcio',
      idBulario: 'cloreto_calcio',
      arquivoJson: '027_cloreto_calcio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Cloreto de Potássio',
      idBulario: 'cloreto_potassio',
      arquivoJson: '028_cloreto_potassio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Coloides',
      idBulario: 'coloides',
      arquivoJson: '029_coloides.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dantroleno',
      idBulario: 'dantroleno',
      arquivoJson: '030_dantroleno.json',
    ),
    const MedicamentoGenerico(
      nome: 'Desflurano',
      idBulario: 'desflurano',
      arquivoJson: '031_desflurano.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dexametasona',
      idBulario: 'dexametasona',
      arquivoJson: '032_dexametasona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dexmedetomidina',
      idBulario: 'dexmedetomidina',
      arquivoJson: '033_dexmedetomidina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dextrocetamina',
      idBulario: 'dextrocetamina',
      arquivoJson: '034_dextrocetamina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dextrose 25%',
      idBulario: 'dextrose_25',
      arquivoJson: '035_dextrose_25.json',
    ),
    const MedicamentoGenerico(
      nome: 'Diazepam',
      idBulario: 'diazepam',
      arquivoJson: '036_diazepam.json',
    ),
    const MedicamentoGenerico(
      nome: 'Digoxina',
      idBulario: 'digoxina',
      arquivoJson: '037_digoxina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dimenidrinato',
      idBulario: 'dimenidrinato',
      arquivoJson: '038_dimenidrinato.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dobutamina',
      idBulario: 'dobutamina',
      arquivoJson: '039_dobutamina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Dopamina',
      idBulario: 'dopamina',
      arquivoJson: '040_dopamina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Droperidol',
      idBulario: 'droperidol',
      arquivoJson: '041_droperidol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Efedrina',
      idBulario: 'efedrina',
      arquivoJson: '042_efedrina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Emulsão Lipídica',
      idBulario: 'emulsao_lipidica',
      arquivoJson: '043_emulsao_lipidica.json',
    ),
    const MedicamentoGenerico(
      nome: 'Enflurano',
      idBulario: 'enflurano',
      arquivoJson: '044_enflurano.json',
    ),
    const MedicamentoGenerico(
      nome: 'Enoxaparina',
      idBulario: 'enoxaparina',
      arquivoJson: '045_enoxaparina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Epinefrina Racemica',
      idBulario: 'epinefrina_racemica',
      arquivoJson: '046_epinefrina_racemica.json',
    ),
    const MedicamentoGenerico(
      nome: 'Esmolol',
      idBulario: 'esmolol',
      arquivoJson: '047_esmolol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Etomidato',
      idBulario: 'etomidato',
      arquivoJson: '048_etomidato.json',
    ),
    const MedicamentoGenerico(
      nome: 'Fenitoína',
      idBulario: 'fenitoina',
      arquivoJson: '049_fenitoina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Fenobarbital',
      idBulario: 'fenobarbital',
      arquivoJson: '050_fenobarbital.json',
    ),
    const MedicamentoGenerico(
      nome: 'Fenoterol',
      idBulario: 'fenoterol',
      arquivoJson: '051_fenoterol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Fentanil',
      idBulario: 'fentanil',
      arquivoJson: '052_fentanil.json',
    ),
    const MedicamentoGenerico(
      nome: 'Flumazenil',
      idBulario: 'flumazenil',
      arquivoJson: '053_flumazenil.json',
    ),
    const MedicamentoGenerico(
      nome: 'Furosemida',
      idBulario: 'furosemida',
      arquivoJson: '054_furosemida.json',
    ),
    const MedicamentoGenerico(
      nome: 'Glicose 50%',
      idBulario: 'glicose_50',
      arquivoJson: '055_glicose_50.json',
    ),
    const MedicamentoGenerico(
      nome: 'Gluconato de Cálcio',
      idBulario: 'gluconato_calcio',
      arquivoJson: '057_gluconato_calcio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Granisetrona',
      idBulario: 'granisetrona',
      arquivoJson: '058_granisetrona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Halotano',
      idBulario: 'halotano',
      arquivoJson: '059_halotano.json',
    ),
    const MedicamentoGenerico(
      nome: 'Heliox',
      idBulario: 'heliox',
      arquivoJson: '060_heliox.json',
    ),
    const MedicamentoGenerico(
      nome: 'Heparina Sódica',
      idBulario: 'heparina_sodica',
      arquivoJson: '061_heparina_sodica.json',
    ),
    const MedicamentoGenerico(
      nome: 'Hidrocortisona',
      idBulario: 'hidrocortisona',
      arquivoJson: '062_hidrocortisona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Hidroxicobalamina',
      idBulario: 'hidroxicobalamina',
      arquivoJson: '063_hidroxicobalamina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Hioscina',
      idBulario: 'hioscina',
      arquivoJson: '064_hioscina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Insulina Regular',
      idBulario: 'insulina_regular',
      arquivoJson: '065_insulina_regular.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ipatrópio',
      idBulario: 'ipatropio',
      arquivoJson: '066_ipatropio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Isoflurano',
      idBulario: 'isoflurano',
      arquivoJson: '067_isoflurano.json',
    ),
    const MedicamentoGenerico(
      nome: 'Levetiracetam',
      idBulario: 'levetiracetam',
      arquivoJson: '068_levetiracetam.json',
    ),
    const MedicamentoGenerico(
      nome: 'Lidocaína',
      idBulario: 'lidocaina',
      arquivoJson: '069_lidocaina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Lidocaína Antiarritmica',
      idBulario: 'lidocaina_antiarritmica',
      arquivoJson: '070_lidocaina_antiarritmica.json',
    ),
    const MedicamentoGenerico(
      nome: 'Lorazepam',
      idBulario: 'lorazepam',
      arquivoJson: '071_lorazepam.json',
    ),
    const MedicamentoGenerico(
      nome: 'Manitol',
      idBulario: 'manitol',
      arquivoJson: '072_manitol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Meperidina',
      idBulario: 'meperidina',
      arquivoJson: '073_meperidina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Metadona',
      idBulario: 'metadona',
      arquivoJson: '074_metadona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Metilprednisolona',
      idBulario: 'metilprednisolona',
      arquivoJson: '075_metilprednisolona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Metoclopramida',
      idBulario: 'metoclopramida',
      arquivoJson: '076_metoclopramida.json',
    ),
    const MedicamentoGenerico(
      nome: 'Metoprolol',
      idBulario: 'metoprolol',
      arquivoJson: '077_metoprolol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Metronidazol',
      idBulario: 'metronidazol',
      arquivoJson: '078_metronidazol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Midazolam',
      idBulario: 'midazolam',
      arquivoJson: '079_midazolam.json',
    ),
    const MedicamentoGenerico(
      nome: 'Milrinona',
      idBulario: 'milrinona',
      arquivoJson: '080_milrinona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Mivacúrio',
      idBulario: 'mivacurio',
      arquivoJson: '081_mivacurio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Morfina',
      idBulario: 'morfina',
      arquivoJson: '082_morfina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Nalbufina',
      idBulario: 'nalbuphina',
      arquivoJson: '083_nalbuphina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Naloxona',
      idBulario: 'naloxona',
      arquivoJson: '084_naloxona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Neostigmina',
      idBulario: 'neostigmina',
      arquivoJson: '085_neostigmina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Nitroglicerina',
      idBulario: 'nitroglicerina',
      arquivoJson: '086_nitroglicerina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Nitroprussiato de Sódio',
      idBulario: 'nitroprussiato',
      arquivoJson: '087_nitroprussiato.json',
    ),
    const MedicamentoGenerico(
      nome: 'Noradrenalina',
      idBulario: 'noradrenalina',
      arquivoJson: '088_noradrenalina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Octreotida',
      idBulario: 'octreotida',
      arquivoJson: '089_octreotida.json',
    ),
    const MedicamentoGenerico(
      nome: 'Omeprazol',
      idBulario: 'omeprazol',
      arquivoJson: '090_omeprazol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ondansetrona',
      idBulario: 'ondansetrona',
      arquivoJson: '091_ondansetrona.json',
    ),
    const MedicamentoGenerico(
      nome: 'Óxido Nítrico',
      idBulario: 'oxido_nitrico',
      arquivoJson: '092_oxido_nitrico.json',
    ),
    const MedicamentoGenerico(
      nome: 'Óxido Nitroso',
      idBulario: 'oxido_nitroso',
      arquivoJson: '093_oxido_nitroso.json',
    ),
    const MedicamentoGenerico(
      nome: 'Pancurônio',
      idBulario: 'pancuronio',
      arquivoJson: '094_pancuronio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Pantoprazol',
      idBulario: 'pantoprazol',
      arquivoJson: '095_pantoprazol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Paracetamol',
      idBulario: 'paracetamol',
      arquivoJson: '096_paracetamol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Pentazocina',
      idBulario: 'pentazocina',
      arquivoJson: '097_pentazocina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Petidina',
      idBulario: 'petidina',
      arquivoJson: '098_petidina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Picada de Cobra',
      idBulario: 'picada_cobra',
      arquivoJson: '099_picada_cobra.json',
    ),
    const MedicamentoGenerico(
      nome: 'Pilocarpina',
      idBulario: 'pilocarpina',
      arquivoJson: '100_pilocarpina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Plasma-Lyte',
      idBulario: 'plasmalyte',
      arquivoJson: '101_plasma_lyte.json',
    ),
    const MedicamentoGenerico(
      nome: 'Propofol',
      idBulario: 'propofol',
      arquivoJson: '102_propofol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Protamina',
      idBulario: 'protamina',
      arquivoJson: '103_protamina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ranitidina',
      idBulario: 'ranitidina',
      arquivoJson: '104_ranitidina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Remidazolam',
      idBulario: 'remidazolam',
      arquivoJson: '105_remidazolam.json',
    ),
    const MedicamentoGenerico(
      nome: 'Remifentanil',
      idBulario: 'remifentanil',
      arquivoJson: '106_remifentanil.json',
    ),
    const MedicamentoGenerico(
      nome: 'Rocurônio',
      idBulario: 'rocuronio',
      arquivoJson: '107_rocuronio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Ropivacaína',
      idBulario: 'ropivacaina',
      arquivoJson: '108_ropivacaina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Salbutamol',
      idBulario: 'salbutamol',
      arquivoJson: '109_salbutamol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Sevoflurano',
      idBulario: 'sevoflurano',
      arquivoJson: '110_sevoflurano.json',
    ),
    const MedicamentoGenerico(
      nome: 'Solução Salina 20%',
      idBulario: 'solucao_salina_20',
      arquivoJson: '111_solucao_salina_20.json',
    ),
    const MedicamentoGenerico(
      nome: 'Solução Salina Hipertônica',
      idBulario: 'solucao_salina_hipertonica',
      arquivoJson: '112_solucao_salina_hipertonica.json',
    ),
    const MedicamentoGenerico(
      nome: 'Soro Fisiológico',
      idBulario: 'soro_fisiologico',
      arquivoJson: '113_soro_fisiologico.json',
    ),
    const MedicamentoGenerico(
      nome: 'Succinilcolina',
      idBulario: 'succinilcolina',
      arquivoJson: '114_succinilcolina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Sufentanil',
      idBulario: 'sufentanil',
      arquivoJson: '115_sufentanil.json',
    ),
    const MedicamentoGenerico(
      nome: 'Sugamadex',
      idBulario: 'sugamadex',
      arquivoJson: '116_sugamadex.json',
    ),
    const MedicamentoGenerico(
      nome: 'Sulfato de Magnésio',
      idBulario: 'sulfato_magnesio',
      arquivoJson: '117_sulfato_magnesio.json',
    ),
    const MedicamentoGenerico(
      nome: 'Terbutalina',
      idBulario: 'terbutalina',
      arquivoJson: '118_terbutalina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Terlipressina',
      idBulario: 'terlipressina',
      arquivoJson: '119_terlipressina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Timoglobulina',
      idBulario: 'timoglobulina',
      arquivoJson: '120_timoglobulina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Tiopental',
      idBulario: 'tiopental',
      arquivoJson: '121_tiopental.json',
    ),
    const MedicamentoGenerico(
      nome: 'Torasemida',
      idBulario: 'torasemida',
      arquivoJson: '123_torasemida.json',
    ),
    const MedicamentoGenerico(
      nome: 'Tramadol',
      idBulario: 'tramadol',
      arquivoJson: '124_tramadol.json',
    ),
    const MedicamentoGenerico(
      nome: 'Vancomicina',
      idBulario: 'vancomicina',
      arquivoJson: '125_vancomicina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Vasopressina',
      idBulario: 'vasopressina',
      arquivoJson: '126_vasopressina.json',
    ),
    const MedicamentoGenerico(
      nome: 'Vecurônio',
      idBulario: 'vecuronio',
      arquivoJson: '127_vecuronio.json',
    ),
    // Aqui podem ser adicionados novos medicamentos no futuro:
  ];

  static bool _inicializado = false;

  static Future<void> _inicializar() async {
    if (_inicializado) return;

    try {
      // A lista de medicamentos já está definida estaticamente acima
      // Não precisamos redefinir aqui

      _inicializado = true;
    } catch (e) {
      throw Exception('Erro ao inicializar farmacoteca: $e');
    }
  }

  static Future<List<MedicamentoGenerico>> getMedicamentos() async {
    await _inicializar();
    return _medicamentos;
  }

  static Future<List<Map<String, dynamic>>> getMedicamentosParaUI() async {
    await _inicializar();

    return _medicamentos
        .map((med) => {
              'nome': med.nome,
              'builder': (BuildContext context) =>
                  med.buildCard(context),
            })
        .toList();
  }

  static Future<MedicamentoGenerico?> getMedicamentoPorNome(String nome) async {
    await _inicializar();
    try {
      return _medicamentos
          .firstWhere((med) => med.nome.toLowerCase() == nome.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
