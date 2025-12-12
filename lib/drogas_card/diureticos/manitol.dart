import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoManitol {
  static const String nome = 'Manitol';
  static const String idBulario = 'manitol';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/manitol.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Manitol tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardManitol(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardManitol(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoManitol._textoObs(
            'Diurético osmótico - Agente desidratante - Protetor renal'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoManitol._linhaPreparo(
            'Frasco 10% (100mg/mL)', '100mL, 250mL, 500mL'),
        MedicamentoManitol._linhaPreparo(
            'Frasco 15% (150mg/mL)', '100mL, 250mL, 500mL'),
        MedicamentoManitol._linhaPreparo(
            'Frasco 20% (200mg/mL)', '100mL, 250mL, 500mL'),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoManitol._linhaPreparo(
            'Filtro de 5 micras', 'OBRIGATÓRIO (previne cristalização)'),
        MedicamentoManitol._linhaPreparo('Tempo de infusão', '20-30 minutos'),
        MedicamentoManitol._linhaPreparo(
            'Se cristalizado', 'Aquecer frasco em banho-maria até dissolver'),
        MedicamentoManitol._linhaPreparo('Verificar', 'Cristais antes de usar'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Edema cerebral/Hipertensão intracraniana (dose inicial)',
            descricaoDose: '0,25-1 g/kg IV em 20-30 minutos',
            unidade: 'g',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção (edema cerebral)',
            descricaoDose: '0,25-0,5 g/kg IV a cada 4-6 horas',
            unidade: 'g',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.5,
            peso: peso,
          ),
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Proteção renal (cirurgia vascular/cardíaca)',
            descricaoDose: '0,5-1 g/kg IV antes do procedimento',
            unidade: 'g',
            dosePorKgMinima: 0.5,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Oligúria/Anúria (teste terapêutico)',
            descricaoDose: '0,2 g/kg IV em 3-5 minutos (teste)',
            unidade: 'g',
            dosePorKg: 0.2,
            peso: peso,
          ),
        ] else ...[
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Edema cerebral pediátrico (dose inicial)',
            descricaoDose: '0,25-1 g/kg IV em 20-30 minutos',
            unidade: 'g',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 1.0,
            peso: peso,
          ),
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Manutenção pediátrica',
            descricaoDose: '0,25-0,5 g/kg IV a cada 4-6 horas',
            unidade: 'g',
            dosePorKgMinima: 0.25,
            dosePorKgMaxima: 0.5,
            peso: peso,
          ),
          MedicamentoManitol._linhaIndicacaoDoseCalculada(
            titulo: 'Teste terapêutico pediátrico',
            descricaoDose: '0,2 g/kg IV em 3-5 minutos',
            unidade: 'g',
            dosePorKg: 0.2,
            peso: peso,
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
      textoDose = '${doseCalculada.toStringAsFixed(1)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(1)}–${doseMax.toStringAsFixed(1)} $unidade';
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
