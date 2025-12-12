import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAtropina {
  static const String nome = 'Atropina';
  static const String idBulario = 'atropina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/atropina.json');
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
      conteudo: _buildCardAtropina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAtropina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtropina._textoObs('• Anticolinérgico - Antagonista muscarínico'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtropina._linhaPreparo('Ampola 1mg/mL (1mL)', 'Solução injetável'),
        MedicamentoAtropina._linhaPreparo('Ampola 0,25mg/mL (1mL)', 'Solução injetável diluída'),
        MedicamentoAtropina._linhaPreparo('Comprimidos 0,5mg', 'Via oral'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtropina._linhaPreparo('Pode ser administrado sem diluição', 'Direto da ampola'),
        MedicamentoAtropina._linhaPreparo('Para doses baixas: diluir em SF 0,9%', 'Concentração conforme necessidade'),
        MedicamentoAtropina._linhaPreparo('1mg em 10mL SF 0,9%', '0,1 mg/mL para doses precisas'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAtropina._linhaIndicacaoDoseFixa(
            titulo: 'Bradicardia sinusal',
            descricaoDose: '0,5mg IV bolus (repetir a cada 3-5min)',
            doseFixa: '0,5 mg',
          ),
          MedicamentoAtropina._linhaIndicacaoDoseFixa(
            titulo: 'Dose máxima total',
            descricaoDose: 'Máximo 3mg total para bradicardia',
            doseFixa: '3 mg total',
          ),
          MedicamentoAtropina._linhaIndicacaoDoseCalculada(
            titulo: 'Pré-medicação anestésica',
            descricaoDose: '0,01-0,02 mg/kg IV/IM',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.02,
            peso: peso,
          ),
          MedicamentoAtropina._linhaIndicacaoDoseCalculada(
            titulo: 'Intoxicação por organofosforados',
            descricaoDose: '0,05-0,1 mg/kg IV (repetir conforme necessário)',
            unidade: 'mg',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.1,
            peso: peso,
          ),
        ] else ...[
          MedicamentoAtropina._linhaIndicacaoDoseCalculada(
            titulo: 'Bradicardia pediátrica',
            descricaoDose: '0,02 mg/kg IV bolus (mín 0,1mg, máx 0,6mg)',
            unidade: 'mg',
            dosePorKg: 0.02,
            doseMinima: 0.1,
            doseMaxima: 0.6,
            peso: peso,
          ),
          MedicamentoAtropina._linhaIndicacaoDoseFixa(
            titulo: 'Dose máxima total pediátrica',
            descricaoDose: 'Máximo 1mg total acumulado',
            doseFixa: '1 mg total',
          ),
          MedicamentoAtropina._linhaIndicacaoDoseCalculada(
            titulo: 'Pré-medicação anestésica pediátrica',
            descricaoDose: '0,01-0,02 mg/kg IV/IM (mín 0,1mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.01,
            dosePorKgMaxima: 0.02,
            doseMinima: 0.1,
            peso: peso,
          ),
          if (peso >= 1) ...[
            MedicamentoAtropina._linhaIndicacaoDoseCalculada(
              titulo: 'Intoxicação pediátrica',
              descricaoDose: '0,02-0,05 mg/kg IV (repetir conforme necessário)',
              unidade: 'mg',
              dosePorKgMinima: 0.02,
              dosePorKgMaxima: 0.05,
              peso: peso,
            ),
          ],
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtropina._textoObs('• Infusão contínua não é rotina para atropina'),
        MedicamentoAtropina._textoObs('• Usar doses intermitentes conforme necessidade'),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAtropina._textoObs('• Anticolinérgico para bradicardia e pré-medicação'),
        MedicamentoAtropina._textoObs('• Efeito imediato (1-2 minutos), duração 2-4 horas'),
        MedicamentoAtropina._textoObs('• Contraindicado em glaucoma de ângulo fechado'),
        MedicamentoAtropina._textoObs('• Cuidado em hipertrofia prostática e íleo paralítico'),
        MedicamentoAtropina._textoObs('• Efeitos adversos: boca seca, taquicardia, retenção urinária'),
        MedicamentoAtropina._textoObs('• Monitorar frequência cardíaca e sinais vitais'),
        MedicamentoAtropina._textoObs('• Antídoto para intoxicações por organofosforados'),
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
    required double peso,
  }) {
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMinima != null && doseCalculada < doseMinima) {
        doseCalculada = doseMinima;
      }
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMinima != null) {
        doseMin = doseMin < doseMinima ? doseMinima : doseMin;
      }
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
