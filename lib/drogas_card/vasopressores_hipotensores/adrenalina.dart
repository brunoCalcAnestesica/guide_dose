import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAdrenalina {
  static const String nome = 'Adrenalina';
  static const String idBulario = 'adrenalina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/adrenalina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos, void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto = SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardAdrenalina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAdrenalina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAdrenalina._textoObs('• Vasopressor - Simpatomimético alfa e beta'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAdrenalina._linhaPreparo('Ampola 1mg/mL (1mL)', 'Solução injetável'),
        MedicamentoAdrenalina._linhaPreparo('Auto-injetor 0,3mg/0,3mL', 'Para anafilaxia'),
        MedicamentoAdrenalina._linhaPreparo('Auto-injetor 0,15mg/0,3mL', 'Pediatrico para anafilaxia'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAdrenalina._linhaPreparo('1mg em 250mL SF 0,9%', '4 mcg/mL para infusão'),
        MedicamentoAdrenalina._linhaPreparo('1mg em 100mL SF 0,9%', '10 mcg/mL para infusão'),
        MedicamentoAdrenalina._linhaPreparo('1mg em 50mL SF 0,9%', '20 mcg/mL para infusão'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAdrenalina._linhaIndicacaoDoseFixa(
            titulo: 'Anafilaxia',
            descricaoDose: '0,3-0,5mg IM (repetir a cada 5-15min)',
            doseFixa: '0,3-0,5 mg',
          ),
          MedicamentoAdrenalina._linhaIndicacaoDoseFixa(
            titulo: 'Parada cardiorrespiratória',
            descricaoDose: '1mg IV bolus (repetir a cada 3-5min)',
            doseFixa: '1 mg',
          ),
          MedicamentoAdrenalina._linhaIndicacaoDoseCalculada(
            titulo: 'Choque séptico',
            descricaoDose: '0,05-0,5 mcg/kg/min IV contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.5,
            peso: peso,
          ),
        ] else ...[
          MedicamentoAdrenalina._linhaIndicacaoDoseCalculada(
            titulo: 'Anafilaxia pediátrica',
            descricaoDose: '0,01mg/kg IM (máx 0,3mg)',
            unidade: 'mg',
            dosePorKg: 0.01,
            doseMaxima: 0.3,
            peso: peso,
          ),
          MedicamentoAdrenalina._linhaIndicacaoDoseCalculada(
            titulo: 'Parada cardiorrespiratória pediátrica',
            descricaoDose: '0,01mg/kg IV bolus (repetir a cada 3-5min)',
            unidade: 'mg',
            dosePorKg: 0.01,
            peso: peso,
          ),
          MedicamentoAdrenalina._linhaIndicacaoDoseCalculada(
            titulo: 'Choque séptico pediátrico',
            descricaoDose: '0,05-0,3 mcg/kg/min IV contínua',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.3,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAdrenalina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAdrenalina._textoObs('• Vasopressor de primeira linha em choque e anafilaxia'),
        MedicamentoAdrenalina._textoObs('• Efeito imediato, meia-vida curta (2-3 minutos)'),
        MedicamentoAdrenalina._textoObs('• Monitorar PA, FC e ECG durante uso'),
        MedicamentoAdrenalina._textoObs('• Contraindicado em glaucoma, hipertireoidismo'),
        MedicamentoAdrenalina._textoObs('• Extravasamento causa necrose - usar via central'),
        MedicamentoAdrenalina._textoObs('• Interage com digitálicos (arritmias)'),
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

  static Widget _linhaIndicacaoDoseFixa({
    required String titulo,
    required String descricaoDose,
    required String doseFixa,
  }) {
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
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Dose: $doseFixa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '1mg em 250mL SF 0,9% (4 mcg/mL)': 4.0, // mcg/mL
      '1mg em 100mL SF 0,9% (10 mcg/mL)': 10.0, // mcg/mL
      '1mg em 50mL SF 0,9% (20 mcg/mL)': 20.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 0.5,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 0.3,
      );
    }
  }

  static Widget _linhaIndicacaoDoseCalculada({
    required String titulo,
    required String descricaoDose,
    String? unidade,
    double? dosePorKg,
    double? dosePorKgMinima,
    double? dosePorKgMaxima,
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
                border: Border.all(color: Colors.blue.shade200),
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
