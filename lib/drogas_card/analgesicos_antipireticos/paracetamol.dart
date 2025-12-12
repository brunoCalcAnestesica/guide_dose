import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoParacetamol {
  static const String nome = 'Paracetamol';
  static const String idBulario = 'paracetamol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/paracetamol.json');
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
      conteudo: _buildCardParacetamol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardParacetamol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoParacetamol._textoObs('Analgésico e antipirético não opioide (inibidor COX central)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoParacetamol._linhaPreparo('Solução injetável 10mg/mL (100mL = 1g)', 'Uso IV'),
        MedicamentoParacetamol._linhaPreparo('Frasco 50mL (500mg), 100mL (1000mg)', 'Pronto para uso'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoParacetamol._linhaPreparo('IV: administrar direto do frasco', 'Infundir em 15 minutos'),
        MedicamentoParacetamol._linhaPreparo('Pode diluir em 100mL SF 0,9% se necessário', 'Para volumes menores'),
        MedicamentoParacetamol._linhaPreparo('Não administrar bolus rápido', 'Risco hipotensão'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoParacetamol._linhaIndicacaoDoseFixa(
            titulo: 'Febre',
            descricaoDose: '500-1000mg a cada 6-8h VO/IV (máx 4g/dia)',
            doseFixa: '500-1000 mg',
          ),
          MedicamentoParacetamol._linhaIndicacaoDoseFixa(
            titulo: 'Dor leve a moderada',
            descricaoDose: '500-1000mg a cada 6-8h VO/IV',
            doseFixa: '500-1000 mg',
          ),
          MedicamentoParacetamol._linhaIndicacaoDoseFixa(
            titulo: 'Dor pós-operatória',
            descricaoDose: '1000mg IV a cada 6h (infundir 15 min)',
            doseFixa: '1000 mg',
          ),
          MedicamentoParacetamol._linhaIndicacaoDoseFixa(
            titulo: 'Analgesia multimodal (adjuvante)',
            descricaoDose: '1000mg IV 6/6h + opioide/AINE',
            doseFixa: '1000 mg',
          ),
        ] else ...[
          MedicamentoParacetamol._linhaIndicacaoDoseCalculada(
            titulo: 'Febre neonatal',
            descricaoDose: '10-12 mg/kg/dose a cada 8-12h IV',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 12,
            peso: peso,
          ),
          MedicamentoParacetamol._linhaIndicacaoDoseCalculada(
            titulo: 'Febre pediátrica',
            descricaoDose: '10-15 mg/kg/dose a cada 6h IV (máx 1g/dose)',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
          MedicamentoParacetamol._linhaIndicacaoDoseCalculada(
            titulo: 'Dor leve-moderada pediátrica',
            descricaoDose: '10-15 mg/kg/dose a cada 6h IV',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
          MedicamentoParacetamol._linhaIndicacaoDoseCalculada(
            titulo: 'Dor pós-operatória pediátrica',
            descricaoDose: '15 mg/kg/dose a cada 6h IV',
            unidade: 'mg',
            dosePorKg: 15,
            doseMaxima: 1000,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoParacetamol._textoObs('Analgésico/antipirético sem efeito anti-inflamatório'),
        MedicamentoParacetamol._textoObs('Dose máxima: 4g/dia (adultos), 75mg/kg/dia (crianças)'),
        MedicamentoParacetamol._textoObs('Intervalo mínimo: 6 horas entre doses'),
        MedicamentoParacetamol._textoObs('Hepatotoxicidade: risco em doses >4g/dia ou hepatopatia'),
        MedicamentoParacetamol._textoObs('Hepatopatas: reduzir dose máxima para 3g/dia'),
        MedicamentoParacetamol._textoObs('IV: infundir em 15 min (hipotensão se rápido)'),
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
