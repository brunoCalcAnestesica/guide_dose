import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSalbutamol {
  static const String nome = 'Salbutamol';
  static const String idBulario = 'salbutamol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/salbutamol.json');
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
      conteudo: _buildCardSalbutamol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSalbutamol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSalbutamol._textoObs('β2-agonista seletivo de curta duração - Broncodilatador'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSalbutamol._linhaPreparo('Aerosol 100mcg/jato (spray MDI)', '200 doses'),
        MedicamentoSalbutamol._linhaPreparo('Solução nebulização 5mg/mL', 'Frasco 10mL, 20mL'),
        MedicamentoSalbutamol._linhaPreparo('Ampola IV 0,5mg/mL (1mL)', 'Uso IV (raro - emergência)'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSalbutamol._linhaPreparo('Nebulização: 2,5-5mg (0,5-1mL) em 3-4mL SF 0,9%', 'Nebulizar 5-15 min'),
        MedicamentoSalbutamol._linhaPreparo('Spray MDI: 2-4 jatos (200-400mcg)', 'Espaçador em crianças'),
        MedicamentoSalbutamol._linhaPreparo('IV: diluir 0,5mg em 100mL SF 0,9%', '5 mcg/mL (uso emergência)'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSalbutamol._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo agudo/crise asmática',
            descricaoDose: '2,5-5mg nebulização a cada 20 min (3 doses), depois 2-4h',
            doseFixa: '2,5-5 mg nebulização',
          ),
          MedicamentoSalbutamol._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo leve-moderado (MDI)',
            descricaoDose: '2-4 jatos (200-400mcg) a cada 4-6h',
            doseFixa: '2-4 jatos',
          ),
          MedicamentoSalbutamol._linhaIndicacaoDoseFixa(
            titulo: 'Asma grave refratária (IV)',
            descricaoDose: '5-20 mcg/min IV contínua (titular resposta)',
            doseFixa: '5-20 mcg/min',
          ),
        ] else ...[
          MedicamentoSalbutamol._linhaIndicacaoDoseCalculada(
            titulo: 'Broncoespasmo pediátrico (nebulização)',
            descricaoDose: '0,15 mg/kg (mín 2,5mg, máx 5mg) a cada 20 min × 3, depois 1-4h',
            unidade: 'mg',
            dosePorKg: 0.15,
            doseMaxima: 5.0,
            peso: peso,
          ),
          MedicamentoSalbutamol._linhaIndicacaoDoseFixa(
            titulo: 'Broncoespasmo leve (MDI pediátrico)',
            descricaoDose: '<5 anos: 2 jatos. >5 anos: 2-4 jatos a cada 4-6h',
            doseFixa: '2-4 jatos',
          ),
          MedicamentoSalbutamol._linhaIndicacaoDoseCalculada(
            titulo: 'Asma grave IV (pediátrico)',
            descricaoDose: '0,1-0,2 mcg/kg/min IV (titular)',
            unidade: 'mcg/kg/min',
            dosePorKgMinima: 0.1,
            dosePorKgMaxima: 0.2,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSalbutamol._textoObs('Broncodilatador β2-seletivo - ação rápida (onset 5-15 min)'),
        MedicamentoSalbutamol._textoObs('Duração: 4-6 horas (inalatório)'),
        MedicamentoSalbutamol._textoObs('Via inalatória preferencial - maior eficácia, menos efeitos sistêmicos'),
        MedicamentoSalbutamol._textoObs('Nebulização: 2,5-5mg em 3-4mL SF 0,9%, nebulizar 5-15 min'),
        MedicamentoSalbutamol._textoObs('Efeitos adversos: taquicardia, tremor, hipocalemia (doses altas)'),
        MedicamentoSalbutamol._textoObs('Monitorar K⁺ em uso IV (risco hipocalemia)'),
        MedicamentoSalbutamol._textoObs('Broncodilatador de resgate - não usar regularmente sem corticoide'),
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
    String? textoDose;

    if (dosePorKg != null) {
      double doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose = '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
