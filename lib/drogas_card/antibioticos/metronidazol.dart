import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoMetronidazol {
  static const String nome = 'Metronidazol';
  static const String idBulario = 'metronidazol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/metronidazol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Metronidazol tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardMetronidazol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardMetronidazol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetronidazol._textoObs(
            'Antibiótico nitroimidazólico - Antiprotozoário - Antimicrobiano'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetronidazol._linhaPreparo(
            'Frasco 500mg/100mL (5mg/mL)', 'Solução pronta para infusão'),
        MedicamentoMetronidazol._linhaPreparo('Comprimido 250mg, 500mg', ''),
        MedicamentoMetronidazol._linhaPreparo('Supositório 500mg', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoMetronidazol._linhaPreparo(
            'Via IV', 'Solução pronta (não necessita reconstituição)'),
        MedicamentoMetronidazol._linhaPreparo(
            'Tempo de infusão', '30-60 minutos'),
        MedicamentoMetronidazol._linhaPreparo(
            'Via oral', 'Comprimido com ou sem alimentos'),
        MedicamentoMetronidazol._linhaPreparo('Via retal', 'Supositório'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Infecções anaeróbias',
            descricaoDose: '500mg IV/VO a cada 8h',
            doseFixa: '500 mg',
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Infecções abdominais (peritonite, abscesso)',
            descricaoDose: '500mg IV a cada 8h',
            doseFixa: '500 mg',
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Infecções ginecológicas',
            descricaoDose: '500mg IV/VO a cada 8h',
            doseFixa: '500 mg',
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Colite pseudomembranosa (C. difficile)',
            descricaoDose: '500mg VO a cada 8h por 10-14 dias',
            doseFixa: '500 mg',
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Giardíase',
            descricaoDose: '250mg VO 3x/dia por 5-7 dias',
            doseFixa: '250 mg',
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Amebíase',
            descricaoDose: '750mg VO 3x/dia por 5-10 dias',
            doseFixa: '750 mg',
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseFixa(
            titulo: 'Vaginose bacteriana',
            descricaoDose: '500mg VO 2x/dia por 7 dias',
            doseFixa: '500 mg',
          ),
        ] else ...[
          MedicamentoMetronidazol._linhaIndicacaoDoseCalculada(
            titulo: 'Infecções anaeróbias pediátricas',
            descricaoDose: '7,5 mg/kg IV/VO a cada 6-8h (máx 500mg/dose)',
            unidade: 'mg',
            dosePorKg: 7.5,
            peso: peso,
            doseMaxima: 500,
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseCalculada(
            titulo: 'Giardíase pediátrica',
            descricaoDose: '5 mg/kg VO 3x/dia por 5-7 dias (máx 250mg/dose)',
            unidade: 'mg',
            dosePorKg: 5,
            peso: peso,
            doseMaxima: 250,
          ),
          MedicamentoMetronidazol._linhaIndicacaoDoseCalculada(
            titulo: 'Amebíase pediátrica',
            descricaoDose:
                '10-12,5 mg/kg VO 3x/dia por 5-10 dias (máx 750mg/dose)',
            unidade: 'mg',
            dosePorKgMinima: 10,
            dosePorKgMaxima: 12.5,
            peso: peso,
            doseMaxima: 750,
          ),
        ],
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
                    const TextSpan(
                        text: ' | ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: marca,
                        style: const TextStyle(fontStyle: FontStyle.italic)),
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
    double? doseCalculada;
    String? textoDose;

    if (dosePorKg != null) {
      doseCalculada = dosePorKg * peso;
      if (doseMaxima != null && doseCalculada > doseMaxima) {
        doseCalculada = doseMaxima;
      }
      textoDose = '${doseCalculada.toStringAsFixed(0)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(0)}–${doseMax.toStringAsFixed(0)} $unidade';
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
          const Text('• ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
