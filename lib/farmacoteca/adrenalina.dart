import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../shared_data.dart';
import '../drogas_card/drogas.dart' show ConversaoInfusaoSlider;

/// Cria um card expansível para exibir informações de um medicamento.
Widget buildMedicamentoExpansivel({
  required BuildContext context,
  required String nome,
  required String idBulario,
  required Widget conteudo,
}) {
  return _CustomExpansionCard(
    nome: nome,
    onBularioPressed: () {
      Navigator.pushNamed(context, '/bulario', arguments: idBulario);
    },
    conteudo: conteudo,
  );
}

class _CustomExpansionCard extends StatefulWidget {
  final String nome;
  final VoidCallback onBularioPressed;
  final Widget conteudo;

  const _CustomExpansionCard({
    required this.nome,
    required this.onBularioPressed,
    required this.conteudo,
  });

  @override
  State<_CustomExpansionCard> createState() => _CustomExpansionCardState();
}

class _CustomExpansionCardState extends State<_CustomExpansionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: _toggleExpansion,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.medical_information_rounded,
                        size: 24, color: Colors.blueGrey),
                    tooltip: 'Abrir bulário',
                    onPressed: widget.onBularioPressed,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: _isExpanded
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: widget.conteudo,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Card de informações da Adrenalina (baseado em dados JSON)
Widget _buildCardAdrenalina(
  BuildContext context,
  double peso,
  bool isAdulto,
  Map<String, dynamic> dados,
) {
  final faixaEtaria = SharedData.faixaEtaria;
  final faixaEtariaKey = _getFaixaEtariaKey(faixaEtaria);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(
        dados['nome'] ?? 'Adrenalina',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      if (faixaEtaria.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            'Faixa etária: $faixaEtaria',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary),
          ),
        ),

      // Apresentações
      const Text('Apresentações',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ...((dados['apresentacoes'] as List?) ?? []).map(
        (apresentacao) => _linhaPreparo(
          apresentacao['nome'] ?? '',
          apresentacao['observacao'] ?? '',
        ),
      ),

      const SizedBox(height: 16),
      // Preparo
      const Text('Preparo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ...((dados['preparo'] as List?) ?? []).map(
        (preparo) => _linhaPreparo(
          preparo['nome'] ?? '',
          preparo['observacao'] ?? '',
        ),
      ),

      const SizedBox(height: 16),
      // Indicações clínicas
      const Text('Indicações clínicas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ..._buildIndicacoesPorFaixa(dados['indicacoes'], faixaEtariaKey, peso),

      const SizedBox(height: 16),
      // Off-label
      const Text('Off-label',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs(
          '• ${dados['off_label']?[faixaEtariaKey] ?? 'Informação não disponível.'}'),

      const SizedBox(height: 16),
      // Cálculo de Infusão
      const Text('Cálculo de Infusão',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _buildCalculadoraInfusao(dados['infusao'], peso),

      const SizedBox(height: 16),
      // Observações
      const Text('Observações',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ...((dados['observacoes'] as List?) ?? [])
          .map((obs) => _textoObs('• $obs')),

      const SizedBox(height: 16),
      // Metabolismo
      const Text('Metabolismo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ...((dados['metabolismo'] as List?) ?? [])
          .map((met) => _textoObs('• $met')),
    ],
  );
}

// Funções auxiliares necessárias
Widget _linhaPreparo(String texto, String observacao) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        if (observacao.isNotEmpty)
          Text(
            ' ($observacao)',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
      ],
    ),
  );
}

Widget _linhaIndicacaoDoseCalculada({
  required String titulo,
  required String descricaoDose,
  String unidade = '',
  double? dosePorKg,
  double? dosePorKgMinima,
  double? dosePorKgMaxima,
  double? doseMaxima,
  double? doseFixa,
  double? doseFixaMinima,
  double? doseFixaMaxima,
  required double peso,
}) {
  double? doseCalculada;
  double? doseCalculadaMin;
  double? doseCalculadaMax;

  // Identificar se é dose de infusão contínua (não exibe dose calculada)
  final isInfusao = descricaoDose.contains('/kg/min') ||
      descricaoDose.contains('/kg/h') ||
      descricaoDose.contains('mcg/kg/min') ||
      descricaoDose.contains('mg/kg/h') ||
      descricaoDose.contains('infusão contínua') ||
      descricaoDose.contains('IV contínua') ||
      descricaoDose.contains('EV contínua');

  // DOSE FIXA: não depende do peso
  if (doseFixa != null) {
    doseCalculada = doseFixa;
  }

  if (doseFixaMinima != null) {
    doseCalculadaMin = doseFixaMinima;
  }

  if (doseFixaMaxima != null) {
    doseCalculadaMax = doseFixaMaxima;
  }

  // DOSE POR KG: multiplica pelo peso
  if (dosePorKg != null) {
    doseCalculada = dosePorKg * peso;
    if (doseMaxima != null && doseCalculada > doseMaxima) {
      doseCalculada = doseMaxima;
    }
  }

  if (dosePorKgMinima != null) {
    doseCalculadaMin = dosePorKgMinima * peso;
    if (doseMaxima != null && doseCalculadaMin > doseMaxima) {
      doseCalculadaMin = doseMaxima;
    }
  }

  if (dosePorKgMaxima != null) {
    doseCalculadaMax = dosePorKgMaxima * peso;
    if (doseMaxima != null && doseCalculadaMax > doseMaxima) {
      doseCalculadaMax = doseMaxima;
    }
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          descricaoDose,
          style: const TextStyle(fontSize: 13),
        ),
        // Mostra dose única (fixa ou calculada por kg)
        if (!isInfusao &&
            doseCalculada != null &&
            doseCalculadaMin == null &&
            doseCalculadaMax == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Dose: ${_formatarDose(doseCalculada)} $unidade',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        // Mostra faixa de dose (fixa ou calculada por kg)
        if (!isInfusao && doseCalculadaMin != null && doseCalculadaMax != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Dose: ${_formatarDose(doseCalculadaMin)}–${_formatarDose(doseCalculadaMax)} $unidade',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    ),
  );
}

/// Formata a dose removendo decimais desnecessários
String _formatarDose(double dose) {
  if (dose == dose.roundToDouble()) {
    return dose.toInt().toString();
  }
  return dose.toStringAsFixed(2);
}

Widget _textoObs(String texto) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 13),
    ),
  );
}

// Funções auxiliares para trabalhar com dados JSON
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

List<Widget> _buildIndicacoesPorFaixa(
    Map<String, dynamic>? indicacoes, String faixaEtariaKey, double peso) {
  if (indicacoes == null || !indicacoes.containsKey(faixaEtariaKey)) {
    return [const Text('Indicações não disponíveis para esta faixa etária.')];
  }

  final indicacoesFaixa = indicacoes[faixaEtariaKey] as List? ?? [];

  return indicacoesFaixa.map<Widget>((indicacao) {
    final dados = indicacao as Map<String, dynamic>;

    return _linhaIndicacaoDoseCalculada(
      titulo: dados['titulo'] ?? '',
      descricaoDose: dados['descricaoDose'] ?? '',
      // Doses por kg (calculadas com base no peso)
      dosePorKg: _convertToDouble(dados['dosePorKg']),
      dosePorKgMinima: _convertToDouble(dados['dosePorKgMinima']),
      dosePorKgMaxima: _convertToDouble(dados['dosePorKgMaxima']),
      doseMaxima: _convertToDouble(dados['doseMaxima']),
      // Doses fixas (não dependem do peso)
      doseFixa: _convertToDouble(dados['doseFixa']),
      doseFixaMinima: _convertToDouble(dados['doseFixaMinima']),
      doseFixaMaxima: _convertToDouble(dados['doseFixaMaxima']),
      unidade: dados['unidade'] ?? '',
      peso: peso,
    );
  }).toList();
}

Widget _buildCalculadoraInfusao(Map<String, dynamic>? infusao, double peso) {
  if (infusao == null) {
    return const Text('Calculadora de infusão não disponível.');
  }

  final opcoesConcentracoes = <String, double>{};
  final opcoesMap = infusao['opcoesConcentracoes'] as Map? ?? {};
  for (final entry in opcoesMap.entries) {
    opcoesConcentracoes[entry.key.toString()] =
        _convertToDouble(entry.value) ?? 0.0;
  }

  return ConversaoInfusaoSlider(
    peso: peso,
    opcoesConcentracoes: opcoesConcentracoes,
    unidade: infusao['unidade'] ?? 'mcg/kg/min',
    doseMin: _convertToDouble(infusao['doseMin']) ?? 0.05,
    doseMax: _convertToDouble(infusao['doseMax']) ?? 2.0,
  );
}

// Função auxiliar para conversão segura de tipos numéricos
double? _convertToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class MedicamentoAdrenalina {
  static const String nome = 'Adrenalina';
  static const String idBulario = 'adrenalina';

  static Future<Map<String, dynamic>> carregarDados() async {
    final String jsonStr =
        await rootBundle.loadString('assets/farmacoteca/005_adrenalina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['adrenalina'] ?? {};
  }

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/adrenalina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context) {
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
          conteudo: _buildCardAdrenalina(
            context,
            peso,
            isAdulto,
            dados,
          ),
        );
      },
    );
  }
}
