import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoDextrose25 {
  static const String nome = 'Dextrose 25%';
  static const String idBulario = 'dextrose_25';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/dextrose_25.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Dextrose 25% tem indicações para todas as faixas etárias
    return true;
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    if (!_temIndicacoesParaFaixaEtaria(faixaEtaria)) {
      return const SizedBox.shrink();
    }

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardDextrose25(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardDextrose25(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrose25._textoObs('Solução de glicose hipertônica'),
        MedicamentoDextrose25._textoObs('Fonte de energia e correção de hipoglicemia'),
        MedicamentoDextrose25._textoObs('Osmolaridade: 1250 mOsm/L'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrose25._linhaPreparo('Ampola 25% (20mL)', 'Via IV'),
        MedicamentoDextrose25._linhaPreparo('Ampola 25% (50mL)', 'Via IV'),
        MedicamentoDextrose25._linhaPreparo('Frasco 25% (100mL)', 'Via IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrose25._linhaPreparo('Administrar via central preferencialmente', 'Evitar via periférica'),
        MedicamentoDextrose25._linhaPreparo('Diluir para concentrações menores', 'SG 10% ou SG 5%'),
        MedicamentoDextrose25._linhaPreparo('Administrar em 5–10 min', 'Infusão lenta'),
        MedicamentoDextrose25._linhaPreparo('Monitorar glicemia', 'Antes e após administração'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrose25._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoDextrose25._textoObs('Contraindicação: hiperglicemia'),
        MedicamentoDextrose25._textoObs('Monitorar glicemia continuamente'),
        MedicamentoDextrose25._textoObs('Risco de flebite em via periférica'),
        MedicamentoDextrose25._textoObs('Cuidado em pacientes diabéticos'),
        MedicamentoDextrose25._textoObs('Pode causar hiperglicemia reativa'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia sintomática',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia assintomática',
          descricaoDose: '0,25–0,5 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia sintomática',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia assintomática',
          descricaoDose: '0,25–0,5 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia sintomática',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia assintomática',
          descricaoDose: '0,25–0,5 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Correção de hipoglicemia pós-exercício',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia sintomática',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia assintomática',
          descricaoDose: '0,25–0,5 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Correção de hipoglicemia pós-exercício',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia sintomática',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia assintomática',
          descricaoDose: '0,25–0,5 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Correção de hipoglicemia pós-exercício',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia por insulina',
          descricaoDose: '0,5–1 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia sintomática',
          descricaoDose: '0,3–0,7 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.7,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia assintomática',
          descricaoDose: '0,2–0,4 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.4,
          peso: peso,
        ),
        MedicamentoDextrose25._linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia por insulina',
          descricaoDose: '0,3–0,7 mL/kg IV em 5–10 min',
          unidade: 'mL',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.7,
          peso: peso,
        ),
      ]);
    }

    return indicacoes;
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicamentoDextrose25._textoObs('Infusão contínua: 0,1–0,3 mL/kg/h'),
        MedicamentoDextrose25._textoObs('Diluir para SG 10% ou SG 5%'),
        MedicamentoDextrose25._textoObs('Via central preferencialmente'),
        MedicamentoDextrose25._textoObs('Monitorar glicemia continuamente'),
        MedicamentoDextrose25._textoObs('Ajustar conforme resposta glicêmica'),
        const SizedBox(height: 16),
        ConversaoInfusaoSlider(
          peso: peso,
          doseMin: isAdulto ? 0.1 : 0.05,
          doseMax: isAdulto ? 0.3 : 0.2,
          unidade: 'mL/kg/h',
          opcoesConcentracoes: {
            'Dextrose 25% (250mg/mL)': 250.0,
            'Dextrose 10% (100mg/mL)': 100.0,
            'Dextrose 5% (50mg/mL)': 50.0,
          },
        ),
      ],
    );
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
    double? doseFixa,
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (doseFixa != null) {
      if (doseFixa < 1) {
        textoDose = '${doseFixa.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseFixa.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      if (doseCalculada < 1) {
        textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
      } else {
        textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
      }
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null && doseMin < doseMinima) {
        doseMin = doseMinima;
      }
      if (doseMaxima != null && doseMax > doseMaxima) {
        doseMax = doseMaxima;
      }
      // Verificar se dose mínima não ultrapassou a máxima
      if (doseMin > doseMax) doseMin = doseMax;
      textoDose = '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
    } else if (doseMinima != null && doseMaxima != null) {
      textoDose = '${doseMinima.toStringAsFixed(0)}–${doseMaxima.toStringAsFixed(0)} $unidade';
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              child: Text(
                'Dose calculada: $textoDose',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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
}