import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAlteplase {
  static const String nome = 'Alteplase';
  static const String idBulario = 'alteplase';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/alteplase.json');
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
      conteudo: _buildCardAlteplase(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAlteplase(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlteplase._textoObs('• Trombolítico - Ativador do plasminogênio tecidual (rt-PA)'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlteplase._linhaPreparo('Frasco 50mg', 'Pó liofilizado para reconstituição'),
        MedicamentoAlteplase._linhaPreparo('Frasco 100mg', 'Pó liofilizado para reconstituição'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlteplase._linhaPreparo('Reconstituir com água para injeção', 'Não usar SF 0,9% para reconstituição'),
        MedicamentoAlteplase._linhaPreparo('Diluir em SF 0,9% ou SG 5%', 'Para infusão IV'),
        MedicamentoAlteplase._linhaPreparo('Usar imediatamente após reconstituição', 'Não armazenar solução reconstituída'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAlteplase._linhaIndicacaoDoseCalculada(
            titulo: 'AVC isquêmico agudo',
            descricaoDose: '0,9 mg/kg IV (máx 90mg) - 10% bolus + 90% em 60min',
            unidade: 'mg',
            dosePorKg: 0.9,
            doseMaxima: 90,
            peso: peso,
          ),
          if (peso >= 65) ...[
            MedicamentoAlteplase._linhaIndicacaoDoseFixa(
              titulo: 'IAM - Pacientes ≥65kg',
              descricaoDose: '15mg bolus + 50mg/30min + 35mg/60min',
              doseFixa: '100mg total',
            ),
            MedicamentoAlteplase._linhaIndicacaoDoseFixa(
              titulo: 'Embolia pulmonar - Pacientes ≥65kg',
              descricaoDose: '10mg bolus + 90mg em 2h',
              doseFixa: '100mg total',
            ),
          ] else ...[
            MedicamentoAlteplase._linhaIndicacaoDoseCalculada(
              titulo: 'IAM - Pacientes <65kg',
              descricaoDose: '15mg bolus + 0,75mg/kg/30min + 0,5mg/kg/60min',
              unidade: 'mg',
              dosePorKgMinima: 0.75,
              dosePorKgMaxima: 1.25,
              peso: peso,
            ),
            MedicamentoAlteplase._linhaIndicacaoDoseCalculada(
              titulo: 'Embolia pulmonar - Pacientes <65kg',
              descricaoDose: '10mg bolus + 1,5mg/kg em 2h',
              unidade: 'mg',
              dosePorKg: 1.5,
              peso: peso,
            ),
          ],
        ] else ...[
          MedicamentoAlteplase._linhaIndicacaoDoseFixa(
            titulo: 'Trombolítico pediátrico',
            descricaoDose: '0,1–0,6 mg/kg/h por 6h',
            doseFixa: '0,1–0,6 mg/kg/h',
          ),
          if (peso <= 10) ...[
            MedicamentoAlteplase._linhaIndicacaoDoseFixa(
              titulo: 'Desobstrução cateter ≤10kg',
              descricaoDose: '0,5mg diluído no volume do lúmen',
              doseFixa: '0,5 mg',
            ),
          ] else ...[
            MedicamentoAlteplase._linhaIndicacaoDoseFixa(
              titulo: 'Desobstrução cateter >10kg',
              descricaoDose: '1mg diluído no volume do lúmen (máx 2mg)',
              doseFixa: '1 mg (máx 2 mg)',
            ),
          ],
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlteplase._textoObs('• Trombolítico para dissolução de trombos'),
        MedicamentoAlteplase._textoObs('• Janela terapêutica crítica: AVC ≤4,5h, IAM ≤6h'),
        MedicamentoAlteplase._textoObs('• Contraindicado em sangramento ativo ou AVC hemorrágico'),
        MedicamentoAlteplase._textoObs('• Monitorar sinais de sangramento continuamente'),
        MedicamentoAlteplase._textoObs('• Evitar punções arteriais durante tratamento'),
        MedicamentoAlteplase._textoObs('• Risco de hemorragia intracraniana'),
        MedicamentoAlteplase._textoObs('• Uso hospitalar com monitorização intensiva'),
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
