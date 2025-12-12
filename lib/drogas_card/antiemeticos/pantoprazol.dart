import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoPantoprazol {
  static const String nome = 'Pantoprazol';
  static const String idBulario = 'pantoprazol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/pantoprazol.json');
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
      conteudo: _buildCardPantoprazol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardPantoprazol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPantoprazol._textoObs('Inibidor da Bomba de Prótons (IBP) - Segunda geração'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPantoprazol._linhaPreparo('Comprimidos 20mg, 40mg', 'Gastrorresistentes'),
        MedicamentoPantoprazol._linhaPreparo('Frasco-ampola 40mg', 'Pó liofilizado para IV'),
        MedicamentoPantoprazol._linhaPreparo('Solução injetável 40mg/10mL', 'Uso IV'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPantoprazol._linhaPreparo('40mg em 10mL SF 0,9%', 'Bolus IV lento 2-15 min'),
        MedicamentoPantoprazol._linhaPreparo('200mg em 250mL SF 0,9%', '0,8 mg/mL para infusão HDA'),
        MedicamentoPantoprazol._linhaPreparo('80mg em 100mL SF 0,9%', '0,8 mg/mL alternativo'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoPantoprazol._linhaIndicacaoDoseFixa(
            titulo: 'Úlcera péptica (gástrica/duodenal)',
            descricaoDose: '40mg/dia VO ou IV por 2-4 semanas',
            doseFixa: '40 mg',
          ),
          MedicamentoPantoprazol._linhaIndicacaoDoseFixa(
            titulo: 'Esofagite de refluxo (DRGE)',
            descricaoDose: '40mg/dia VO ou IV por 4-8 semanas',
            doseFixa: '40 mg',
          ),
          MedicamentoPantoprazol._linhaIndicacaoDoseFixa(
            titulo: 'Síndrome de Zollinger-Ellison',
            descricaoDose: '80-240mg/dia VO (dividir se >80mg)',
            doseFixa: '80-240 mg',
          ),
          MedicamentoPantoprazol._linhaIndicacaoDoseFixa(
            titulo: 'Erradicação H. pylori',
            descricaoDose: '40mg 2x/dia + amoxicilina + claritromicina',
            doseFixa: '40 mg 2x/dia',
          ),
          MedicamentoPantoprazol._linhaIndicacaoDoseFixa(
            titulo: 'Hemorragia digestiva alta',
            descricaoDose: '80mg IV bolus + 8mg/h infusão por 72h',
            doseFixa: '80 mg bolus',
          ),
        ] else ...[
          MedicamentoPantoprazol._linhaIndicacaoDoseCalculada(
            titulo: 'Esofagite de refluxo pediátrica (>5 anos, ≥15kg)',
            descricaoDose: '0,8-1,6 mg/kg/dia VO (máx 40mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.8,
            dosePorKgMaxima: 1.6,
            doseMaxima: 40.0,
            peso: peso,
          ),
          MedicamentoPantoprazol._linhaIndicacaoDoseFixa(
            titulo: 'Dose padrão pediátrica',
            descricaoDose: '15-40kg: 20mg/dia. >40kg: 40mg/dia',
            doseFixa: peso >= 15 && peso < 40 ? '20 mg' : peso >= 40 ? '40 mg' : 'Peso <15kg: não estabelecido',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoPantoprazol._textoObs('IBP de 2ª geração - menos interações que omeprazol'),
        MedicamentoPantoprazol._textoObs('Protocolo HDA: 80mg bolus + 8mg/h por 72 horas'),
        MedicamentoPantoprazol._textoObs('Monitorar magnésio sérico em uso >3 meses'),
        MedicamentoPantoprazol._textoObs('Melhor opção que omeprazol em pacientes usando clopidogrel'),
        MedicamentoPantoprazol._textoObs('Contraindicado com atazanavir e rilpivirina'),
        MedicamentoPantoprazol._textoObs('Administrar IV lentamente (nunca bolus rápido)'),
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
