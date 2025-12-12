import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPetidina {
  static const String nome = 'Petidina';
  static const String idBulario = 'petidina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/petidina.json');
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
      conteudo: _buildCardPetidina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardPetidina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPetidina._textoObs('Analgésico opioide sintético - Agonista μ-opioide (meperidina)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPetidina._linhaPreparo('Ampola 50mg/mL (2mL = 100mg)', 'Solução injetável'),
        MedicamentoPetidina._linhaPreparo('Ampola 100mg/mL (2mL = 200mg)', 'Concentração alta'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPetidina._linhaPreparo('50mg em 10mL SF 0,9%', '5 mg/mL para IV lento'),
        MedicamentoPetidina._linhaPreparo('100mg em 100mL SF 0,9%', '1 mg/mL para infusão'),
        MedicamentoPetidina._linhaPreparo('IM/SC: usar direto da ampola', 'Injeção profunda'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoPetidina._linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda moderada a grave',
            descricaoDose: '50-150mg IM/SC a cada 3-4h',
            doseFixa: '50-150 mg',
          ),
          MedicamentoPetidina._linhaIndicacaoDoseFixa(
            titulo: 'Dor aguda IV',
            descricaoDose: '50-100mg IV lento a cada 2-3h (velocidade máx 25mg/min)',
            doseFixa: '50-100 mg',
          ),
          MedicamentoPetidina._linhaIndicacaoDoseFixa(
            titulo: 'Analgesia obstétrica (trabalho de parto)',
            descricaoDose: '50-100mg IM a cada 3-4h',
            doseFixa: '50-100 mg',
          ),
          MedicamentoPetidina._linhaIndicacaoDoseFixa(
            titulo: 'Tremores pós-anestésicos',
            descricaoDose: '12,5-25mg IV lento (efeito antitremor)',
            doseFixa: '12,5-25 mg',
          ),
        ] else ...[
          MedicamentoPetidina._linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica IM/SC',
            descricaoDose: '1-1,5 mg/kg a cada 3-4h (máx 100mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 1.5,
            doseMaxima: 100,
            peso: peso,
          ),
          MedicamentoPetidina._linhaIndicacaoDoseCalculada(
            titulo: 'Dor aguda pediátrica IV',
            descricaoDose: '0,5-1 mg/kg IV lento a cada 2-3h (máx 50mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            doseMaxima: 50,
            peso: peso,
          ),
          MedicamentoPetidina._linhaIndicacaoDoseCalculada(
            titulo: 'Sedoanalgesia pediátrica',
            descricaoDose: '1-2 mg/kg IM dose única (procedimentos)',
            unidade: 'mg',
            dosePorKgMinima: 1.0,
            dosePorKgMaxima: 2.0,
            doseMaxima: 100,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPetidina._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPetidina._textoObs('Opioide sintético - 1/10 potência da morfina'),
        MedicamentoPetidina._textoObs('EVITAR uso prolongado (acúmulo normeperidina - convulsões)'),
        MedicamentoPetidina._textoObs('Contraindicado com IMAOs (intervalo mínimo 14 dias)'),
        MedicamentoPetidina._textoObs('Dose máxima: 600mg/dia adultos, 8-10 mg/kg/dia pediátrico'),
        MedicamentoPetidina._textoObs('Tremores pós-anestésicos: 12,5-25mg IV (efeito antitremor)'),
        MedicamentoPetidina._textoObs('Ter naloxona disponível (antagonista opioide)'),
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
      '100mg em 100mL SF 0,9% (1 mg/mL)': 1.0,
      '250mg em 250mL SF 0,9% (1 mg/mL)': 1.0,
      '500mg em 500mL SF 0,9% (1 mg/mL)': 1.0,
      '100mg em 50mL SF 0,9% (2 mg/mL)': 2.0,
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/h',
        doseMin: 10.0,
        doseMax: 50.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mg/h',
        doseMin: 5.0,
        doseMax: 30.0,
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
