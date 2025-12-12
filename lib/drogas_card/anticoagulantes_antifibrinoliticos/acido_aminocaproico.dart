import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAcidoAminocaproico {
  static const String nome = 'Ácido Aminocaproico';
  static const String idBulario = 'acido_aminocaproico';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/farmacoteca/002_acido_aminocaproico.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['acido_aminocaproico'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isFavorito = favoritos.contains(nome);

    // Debug: verificar faixa etária
    print('DEBUG Ácido Aminocaproico - Faixa etária: $faixaEtaria');
    print('DEBUG Ácido Aminocaproico - Tem indicações: ${_temIndicacoesParaFaixaEtaria(faixaEtaria)}');
    
    // Verificar se há indicações para a faixa etária atual
    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink(); // Não exibe o card se não há indicações
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAcidoAminocaproico(
        context,
        peso,
        faixaEtaria,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Mapear faixas etárias para as chaves do JSON
    final faixaEtariaMap = {
      'Recém-nascido': 'recem_nascido',
      'Lactente': 'lactente',
      'Criança': 'crianca',
      'Adolescente': 'adolescente',
      'Adulto': 'adulto',
      'Idoso': 'idoso',
    };

    final chaveFaixaEtaria = faixaEtariaMap[faixaEtaria] ?? 'adulto';
    
    // Dados das indicações por faixa etária
    final indicacoesPorFaixa = {
      'recem_nascido': <Map<String, dynamic>>[],
      'lactente': <Map<String, dynamic>>[],
      'crianca': <Map<String, dynamic>>[],
      'adolescente': <Map<String, dynamic>>[],
      'adulto': [
        {
          'titulo': 'Hiperfibrinólise em cirurgia',
          'descricaoDose': 'Carga: 4–5 g IV em 1h → Manutenção: 1 g/h por até 8h',
          'doseMinima': 4,
          'doseMaxima': 5,
          'unidade': 'g'
        },
        {
          'titulo': 'Hemorragias em coagulopatias',
          'descricaoDose': '100–150 mg/kg IV cada 6h (máx 30 g/dia)',
          'dosePorKgMinima': 100,
          'dosePorKgMaxima': 150,
          'doseMaxima': 30000,
          'unidade': 'mg/kg'
        },
        {
          'titulo': 'Uso oral profilático',
          'descricaoDose': '1–2 g VO 3–4x/dia (máx 8 g/dia)',
          'doseMinima': 1,
          'doseMaxima': 2,
          'unidade': 'g'
        }
      ],
      'idoso': [
        {
          'titulo': 'Hiperfibrinólise em cirurgia',
          'descricaoDose': 'Carga: 3–4 g IV em 1h → Manutenção: 0,5–1 g/h por até 8h',
          'doseMinima': 3,
          'doseMaxima': 4,
          'unidade': 'g'
        }
      ]
    };

    final indicacoes = indicacoesPorFaixa[chaveFaixaEtaria] ?? [];
    return indicacoes.isNotEmpty;
  }

  static Widget _buildCardAcidoAminocaproico(BuildContext context, double peso, String faixaEtaria, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // CLASSE
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Antifibrinolítico', ''),
        
        const SizedBox(height: 16),
        
        // APRESENTAÇÕES
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Frasco 5 g/100 mL (50 mg/mL)', 'Amicar® - uso IV'),
        
        const SizedBox(height: 16),
        
        // PREPARO
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Pode ser usado IV direta, infusão contínua ou VO', ''),
        _linhaPreparo('Diluir em SF 0,9% ou SG 5% para infusão lenta (10–30 min)', ''),
        
        const SizedBox(height: 16),
        
        // INDICAÇÕES
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(faixaEtaria, peso),
        
        const SizedBox(height: 16),
        
        // INFUSÃO CONTÍNUA
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('0,5–2 g/h', 'Concentração: 50 mg/mL'),
        _linhaPreparo('Diluir em SF 0,9% ou SG 5%', 'Infusão lenta'),
        
        const SizedBox(height: 16),
        _buildConversorInfusao(peso),
        
        const SizedBox(height: 16),
        
        // OBSERVAÇÕES
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _textoObs('Antifibrinolítico que bloqueia a conversão de plasminogênio em plasmina'),
        _textoObs('Alternativa ao ácido tranexâmico'),
        _textoObs('Cuidado em insuficiência renal e risco de trombose'),
        _textoObs('Contraindicado em hematuria macroscópica de origem renal'),
        _textoObs('Meia-vida: 1-2 horas'),
        _textoObs('Usar com cautela em disfunção renal grave'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(String faixaEtaria, double peso) {
    final faixaEtariaMap = {
      'Recém-nascido': 'recem_nascido',
      'Lactente': 'lactente',
      'Criança': 'crianca',
      'Adolescente': 'adolescente',
      'Adulto': 'adulto',
      'Idoso': 'idoso',
    };

    final chaveFaixaEtaria = faixaEtariaMap[faixaEtaria] ?? 'adulto';
    
    final indicacoesPorFaixa = {
      'recem_nascido': <Map<String, dynamic>>[],
      'lactente': <Map<String, dynamic>>[],
      'crianca': <Map<String, dynamic>>[],
      'adolescente': <Map<String, dynamic>>[],
      'adulto': [
        {
          'titulo': 'Hiperfibrinólise em cirurgia',
          'descricaoDose': 'Carga: 4–5 g IV em 1h → Manutenção: 1 g/h por até 8h',
          'doseMinima': 4,
          'doseMaxima': 5,
          'unidade': 'g'
        },
        {
          'titulo': 'Hemorragias em coagulopatias',
          'descricaoDose': '100–150 mg/kg IV cada 6h (máx 30 g/dia)',
          'dosePorKgMinima': 100,
          'dosePorKgMaxima': 150,
          'doseMaxima': 30000,
          'unidade': 'mg/kg'
        },
        {
          'titulo': 'Uso oral profilático',
          'descricaoDose': '1–2 g VO 3–4x/dia (máx 8 g/dia)',
          'doseMinima': 1,
          'doseMaxima': 2,
          'unidade': 'g'
        }
      ],
      'idoso': [
        {
          'titulo': 'Hiperfibrinólise em cirurgia',
          'descricaoDose': 'Carga: 3–4 g IV em 1h → Manutenção: 0,5–1 g/h por até 8h',
          'doseMinima': 3,
          'doseMaxima': 4,
          'unidade': 'g'
        }
      ]
    };

    final indicacoes = indicacoesPorFaixa[chaveFaixaEtaria] ?? [];
    
    if (indicacoes.isEmpty) {
      return [
        _textoObs('Não há indicações específicas para esta faixa etária'),
      ];
    }

    return indicacoes.map<Widget>((indicacao) {
      return _linhaIndicacaoDoseCalculada(
        titulo: indicacao['titulo'],
        descricaoDose: indicacao['descricaoDose'],
        unidade: indicacao['unidade'],
        dosePorKg: indicacao['dosePorKg'],
        dosePorKgMinima: indicacao['dosePorKgMinima']?.toDouble(),
        dosePorKgMaxima: indicacao['dosePorKgMaxima']?.toDouble(),
        doseMinima: indicacao['doseMinima']?.toDouble(),
        doseMaxima: indicacao['doseMaxima']?.toDouble(),
        peso: peso,
      );
    }).toList();
  }

  static Widget _linhaPreparo(String texto, String marca) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(text: texto),
                  if (marca.isNotEmpty) ...[
                    const TextSpan(text: ' | ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: marca, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
    double? doseMinima,
    double? doseMaxima,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(1)}–${doseMaxima.toStringAsFixed(1)} $unidade';
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
          if (textoDose != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _textoObs(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }

  static Widget _buildConversorInfusao(double peso) {
    return _ConversorInfusaoAcidoAminocaproico(peso: peso);
  }
}

class _ConversorInfusaoAcidoAminocaproico extends StatefulWidget {
  final double peso;

  const _ConversorInfusaoAcidoAminocaproico({required this.peso});

  @override
  State<_ConversorInfusaoAcidoAminocaproico> createState() => _ConversorInfusaoAcidoAminocaproicoState();
}

class _ConversorInfusaoAcidoAminocaproicoState extends State<_ConversorInfusaoAcidoAminocaproico> {
  double doseSelecionada = 0.5; // g/h
  String diluicaoSelecionada = '5 g/100 mL (50 mg/mL)';
  
  final Map<String, double> diluicoes = {
    '5 g/100 mL (50 mg/mL)': 50.0, // mg/mL
  };

  @override
  Widget build(BuildContext context) {
    final concentracao = diluicoes[diluicaoSelecionada] ?? 50.0;
    final doseEmMgH = doseSelecionada * 1000; // converter g/h para mg/h
    final mlH = doseEmMgH / concentracao; // mg/h ÷ mg/mL = mL/h

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversor de Infusão',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          
          // Dropdown para diluição
          DropdownButton<String>(
            value: diluicaoSelecionada,
            isExpanded: true,
            onChanged: (val) => setState(() => diluicaoSelecionada = val!),
            items: diluicoes.entries.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(e.key, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Slider para dose
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dose: ${doseSelecionada.toStringAsFixed(1)} g/h',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${mlH.toStringAsFixed(1)} mL/h',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          
          Slider(
            value: doseSelecionada,
            min: 0.1,
            max: 2.0,
            divisions: 19,
            label: '${doseSelecionada.toStringAsFixed(1)} g/h',
            onChanged: (val) => setState(() => doseSelecionada = val),
          ),
          
          const SizedBox(height: 4),
          Text(
            'Peso: ${widget.peso.toStringAsFixed(1)} kg | Concentração: ${concentracao.toStringAsFixed(0)} mg/mL',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}