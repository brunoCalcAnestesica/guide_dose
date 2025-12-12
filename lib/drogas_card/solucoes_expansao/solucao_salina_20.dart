import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoSolucaoSalina20 {
  static const String nome = 'Solução Salina 20%';
  static const String idBulario = 'solucaosalina20';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/solucaosalina20.json');
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
      conteudo: _buildCardSolucaoSalina20(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardSolucaoSalina20(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalina20._textoObs('Solução eletrolítica hipertônica concentrada (NaCl 20%) - Corretor hidroeletrolítico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalina20._linhaPreparo('Ampola 10mL, 20mL (200mg/mL = 20%)', 'NaCl hipertônico'),
        MedicamentoSolucaoSalina20._linhaPreparo('Frasco 250mL, 500mL', 'Volumes grandes'),
        MedicamentoSolucaoSalina20._linhaPreparo('Osmolaridade: 3.400 mOsm/L', '11× plasma (300 mOsm/L)'),
        MedicamentoSolucaoSalina20._linhaPreparo('Composição: 34 mEq Na⁺/10mL', '3,4 mEq/mL'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalina20._linhaPreparo('Via CENTRAL: pode usar puro', 'Infundir lento 10-30 min'),
        MedicamentoSolucaoSalina20._linhaPreparo('Via PERIFÉRICA: SEMPRE diluir 1:1', '100mL NaCl 20% + 100mL SF 0,9% = NaCl 10%'),
        MedicamentoSolucaoSalina20._linhaPreparo('NUNCA administrar puro via periférica', 'Risco necrose vascular'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoSolucaoSalina20._linhaIndicacaoDoseFixa(
            titulo: 'Hiponatremia aguda sintomática (<120 mEq/L)',
            descricaoDose: '100-150 mL NaCl 20% IV central lento (10-30 min). Meta: ↑Na⁺ 4-6 mEq/L em 1-2h',
            doseFixa: '100-150 mL',
          ),
          MedicamentoSolucaoSalina20._linhaIndicacaoDoseFixa(
            titulo: 'Hipertensão intracraniana (osmoterapia)',
            descricaoDose: '75-150 mL NaCl 20% IV central em 15-30 min. Reduz PIC 30-50%',
            doseFixa: '75-150 mL',
          ),
          MedicamentoSolucaoSalina20._linhaIndicacaoDoseFixa(
            titulo: 'Edema cerebral agudo (trauma/encefalopatia)',
            descricaoDose: '100 mL NaCl 20% IV central em 10-20 min',
            doseFixa: '100 mL',
          ),
        ] else ...[
          MedicamentoSolucaoSalina20._linhaIndicacaoDoseCalculada(
            titulo: 'Hiponatremia sintomática pediátrica',
            descricaoDose: '2-4 mL/kg NaCl 20% IV central/diluído (máx 100 mL)',
            unidade: 'mL',
            dosePorKgMinima: 2.0,
            dosePorKgMaxima: 4.0,
            doseMaxima: 100,
            peso: peso,
          ),
          MedicamentoSolucaoSalina20._linhaIndicacaoDoseCalculada(
            titulo: 'Osmoterapia pediátrica (PIC elevada)',
            descricaoDose: '0,5-1 mL/kg NaCl 20% diluído IV (máx 50 mL)',
            unidade: 'mL',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            doseMaxima: 50,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoSolucaoSalina20._textoObs('Solução hipertônica emergência - 3.400 mOsm/L (11× plasma)'),
        MedicamentoSolucaoSalina20._textoObs('Fornece 3,4 mEq Na⁺/mL (34 mEq/10mL, 340 mEq/100mL)'),
        MedicamentoSolucaoSalina20._textoObs('ATENÇÃO: Via CENTRAL preferencial - periférica SEMPRE diluir 1:1'),
        MedicamentoSolucaoSalina20._textoObs('ATENÇÃO: Monitorar Na⁺ HORÁRIO - meta ↑4-6 mEq/L em 4-6h'),
        MedicamentoSolucaoSalina20._textoObs('LIMITE CRÍTICO: Máx ↑10-12 mEq/L/24h (prevenir mielinólise pontina)'),
        MedicamentoSolucaoSalina20._textoObs('Cálculo déficit: (Na⁺ desejado - atual) × peso × 0,6 = mEq Na⁺'),
        MedicamentoSolucaoSalina20._textoObs('Infusão lenta: 100mL em 10-30 min (nunca bolus rápido)'),
        MedicamentoSolucaoSalina20._textoObs('Ter furosemida disponível (risco sobrecarga volêmica)'),
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
              'Volume: $doseFixa',
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
                'Volume calculado: $textoDose',
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
