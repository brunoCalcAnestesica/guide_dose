import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoCloretoCalcio {
  static const String nome = 'Cloreto de Cálcio';
  static const String idBulario = 'cloreto_calcio';

  static Future<Map<String, dynamic>> carregarBulario() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/medicamentos/cloreto_calcio.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      return jsonMap['PT']['bulario'];
    } catch (e) {
      return {'erro': 'Erro ao carregar o bulário: $e'};
    }
  }

  static bool _temIndicacoesParaFaixaEtaria(String faixaEtaria) {
    // Cloreto de cálcio tem indicações para todas as faixas etárias
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
      conteudo: _buildCardCloretoCalcio(
        context,
        peso,
        faixaEtaria,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardCloretoCalcio(BuildContext context, double peso, String faixaEtaria, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoCalcio._textoObs('Eletrólito crítico'),
        MedicamentoCloretoCalcio._textoObs('Reposição de cálcio elementar'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoCalcio._linhaPreparo('Ampola 10% (1g/10mL)', '27 mg/mL de Ca²⁺ elementar'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoCalcio._linhaPreparo('IV lenta (3–5 min)', 'Administração controlada'),
        MedicamentoCloretoCalcio._linhaPreparo('Evitar periférico', 'Risco de necrose - preferir acesso central'),
        MedicamentoCloretoCalcio._linhaPreparo('1g/100mL SF 0,9%', '10 mg/mL (infusão contínua)'),
        MedicamentoCloretoCalcio._linhaPreparo('500mg/50mL SF 0,9%', '10 mg/mL (infusão contínua)'),
        const SizedBox(height: 16),
        const Text('Indicações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._buildIndicacoesPorFaixaEtaria(peso, faixaEtaria, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoCloretoCalcio._textoObs('Reposição mais concentrada que gluconato'),
        MedicamentoCloretoCalcio._textoObs('3x mais cálcio elementar que o gluconato de cálcio'),
        MedicamentoCloretoCalcio._textoObs('Incompatível com bicarbonato na mesma via (precipita)'),
        MedicamentoCloretoCalcio._textoObs('Extravasamento → risco de necrose → preferir acesso central'),
        MedicamentoCloretoCalcio._textoObs('Monitorar ECG e eletrólitos durante infusão'),
      ],
    );
  }

  static List<Widget> _buildIndicacoesPorFaixaEtaria(double peso, String faixaEtaria, bool isAdulto) {
    List<Widget> indicacoes = [];

    if (faixaEtaria == 'RN') {
      // Recém-nascidos
      indicacoes.addAll([
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
          descricaoDose: '10–20 mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por bloqueadores de canal de cálcio',
          descricaoDose: '8–15 mg/kg IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
          unidade: 'mg',
          dosePorKgMinima: 8,
          dosePorKgMaxima: 15,
          doseMinima: 500,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Antagonismo da toxicidade do magnésio',
          descricaoDose: '5–10 mg/kg IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Reposição de cálcio em transfusão sanguínea',
          descricaoDose: '0,04–0,07 mL de cloreto de cálcio 10% por mL de sangue transfundido',
          unidade: 'mL',
          doseMinima: 1.8,
          doseMaxima: 3.7,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Lactente') {
      // Lactentes
      indicacoes.addAll([
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
          descricaoDose: '10–20 mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por bloqueadores de canal de cálcio',
          descricaoDose: '8–15 mg/kg IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
          unidade: 'mg',
          dosePorKgMinima: 8,
          dosePorKgMaxima: 15,
          doseMinima: 500,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Antagonismo da toxicidade do magnésio',
          descricaoDose: '5–10 mg/kg IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Reposição de cálcio em transfusão sanguínea',
          descricaoDose: '0,04–0,07 mL de cloreto de cálcio 10% por mL de sangue transfundido',
          unidade: 'mL',
          doseMinima: 1.8,
          doseMaxima: 3.7,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Criança') {
      // Crianças
      indicacoes.addAll([
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
          descricaoDose: '10–20 mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por bloqueadores de canal de cálcio',
          descricaoDose: '8–15 mg/kg IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
          unidade: 'mg',
          dosePorKgMinima: 8,
          dosePorKgMaxima: 15,
          doseMinima: 500,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Antagonismo da toxicidade do magnésio',
          descricaoDose: '5–10 mg/kg IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Reposição de cálcio em transfusão sanguínea',
          descricaoDose: '0,04–0,07 mL de cloreto de cálcio 10% por mL de sangue transfundido',
          unidade: 'mL',
          doseMinima: 1.8,
          doseMaxima: 3.7,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adolescente') {
      // Adolescentes
      indicacoes.addAll([
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
          descricaoDose: '10–20 mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por bloqueadores de canal de cálcio',
          descricaoDose: '8–15 mg/kg IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
          unidade: 'mg',
          dosePorKgMinima: 8,
          dosePorKgMaxima: 15,
          doseMinima: 500,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Antagonismo da toxicidade do magnésio',
          descricaoDose: '5–10 mg/kg IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Reposição de cálcio em transfusão sanguínea',
          descricaoDose: '0,04–0,07 mL de cloreto de cálcio 10% por mL de sangue transfundido',
          unidade: 'mL',
          doseMinima: 1.8,
          doseMaxima: 3.7,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Adulto') {
      // Adultos
      indicacoes.addAll([
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
          descricaoDose: '10–20 mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por bloqueadores de canal de cálcio',
          descricaoDose: '8–15 mg/kg IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
          unidade: 'mg',
          dosePorKgMinima: 8,
          dosePorKgMaxima: 15,
          doseMinima: 500,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Antagonismo da toxicidade do magnésio',
          descricaoDose: '5–10 mg/kg IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Reposição de cálcio em transfusão sanguínea',
          descricaoDose: '0,04–0,07 mL de cloreto de cálcio 10% por mL de sangue transfundido',
          unidade: 'mL',
          doseMinima: 1.8,
          doseMaxima: 3.7,
          peso: peso,
        ),
      ]);
    } else if (faixaEtaria == 'Idoso') {
      // Idosos
      indicacoes.addAll([
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
          descricaoDose: '10–20 mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Intoxicação por bloqueadores de canal de cálcio',
          descricaoDose: '8–15 mg/kg IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
          unidade: 'mg',
          dosePorKgMinima: 8,
          dosePorKgMaxima: 15,
          doseMinima: 500,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Antagonismo da toxicidade do magnésio',
          descricaoDose: '5–10 mg/kg IV lenta (máx 1g)',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 10,
          doseMaxima: 1000,
          peso: peso,
        ),
        MedicamentoCloretoCalcio._linhaIndicacaoDoseCalculada(
          titulo: 'Reposição de cálcio em transfusão sanguínea',
          descricaoDose: '0,04–0,07 mL de cloreto de cálcio 10% por mL de sangue transfundido',
          unidade: 'mL',
          doseMinima: 1.8,
          doseMaxima: 3.7,
          peso: peso,
        ),
      ]);
    }

    return indicacoes;
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
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
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