import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoLorazepam {
  static const String nome = 'Lorazepam';
  static const String idBulario = 'lorazepam';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/lorazepam.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Lorazepam tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardLorazepam(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardLorazepam(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLorazepam._textoObs(
            'Benzodiazepínico - Ansiolítico - Sedativo-hipnótico - Anticonvulsivante'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLorazepam._linhaPreparo('Ampola 2mg/mL (1mL)', ''),
        MedicamentoLorazepam._linhaPreparo('Ampola 4mg/mL (1mL)', ''),
        MedicamentoLorazepam._linhaPreparo('Comprimido 1mg, 2mg, 2,5mg', ''),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLorazepam._linhaPreparo(
            'Via IV', 'NÃO diluir - usar direto da ampola'),
        MedicamentoLorazepam._linhaPreparo(
            'Velocidade máxima', '2 mg/min (administração lenta)'),
        MedicamentoLorazepam._linhaPreparo(
            'Via IM', 'Uso direto (absorção errática)'),
        MedicamentoLorazepam._linhaPreparo(
            'Via oral', 'Comprimido com ou sem alimentos'),
        MedicamentoLorazepam._linhaPreparo(
            'Para infusão', 'Diluir em SF 0,9% ou SG 5%'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (isAdulto) ...[
          MedicamentoLorazepam._linhaIndicacaoDoseFixa(
            titulo: 'Status epilepticus',
            descricaoDose:
                '4mg IV em bolus lento (2 mg/min), repetir após 10min se necessário',
            doseFixa: '4 mg',
          ),
          MedicamentoLorazepam._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação pré-operatória',
            descricaoDose: '0,044 mg/kg IV (máx 2mg) 15-20min antes',
            unidade: 'mg',
            dosePorKg: 0.044,
            peso: peso,
            doseMaxima: 2,
          ),
          MedicamentoLorazepam._linhaIndicacaoDoseFixa(
            titulo: 'Agitação psicomotora',
            descricaoDose: '1-4mg IV/IM',
            doseFixa: '1-4 mg',
          ),
          MedicamentoLorazepam._linhaIndicacaoDoseFixa(
            titulo: 'Ansiedade aguda',
            descricaoDose: '2-4mg VO/IV',
            doseFixa: '2-4 mg',
          ),
          MedicamentoLorazepam._linhaIndicacaoDoseFixa(
            titulo: 'Insônia',
            descricaoDose: '1-4mg VO ao deitar',
            doseFixa: '1-4 mg',
          ),
        ] else ...[
          MedicamentoLorazepam._linhaIndicacaoDoseCalculada(
            titulo: 'Status epilepticus pediátrico',
            descricaoDose:
                '0,1 mg/kg IV (máx 4mg), repetir após 10min se necessário',
            unidade: 'mg',
            dosePorKg: 0.1,
            peso: peso,
            doseMaxima: 4,
          ),
          MedicamentoLorazepam._linhaIndicacaoDoseCalculada(
            titulo: 'Sedação pediátrica',
            descricaoDose: '0,05-0,1 mg/kg IV/IM (máx 2mg)',
            unidade: 'mg',
            dosePorKgMinima: 0.05,
            dosePorKgMaxima: 0.1,
            peso: peso,
            doseMaxima: 2,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoLorazepam._textoObs('Sedação em UTI (uso off-label):'),
        MedicamentoLorazepam._textoObs(
            '  - Preparo: 50mg em 50mL SG 5% (1 mg/mL)'),
        MedicamentoLorazepam._textoObs('  - Taxa: 0,01-0,1 mg/kg/h'),
        MedicamentoLorazepam._textoObs(
            '  - Adulto 70kg: 0,7-7 mg/h (0,7-7 mL/h)'),
        MedicamentoLorazepam._textoObs(
            'PREFERIR bolus intermitente à infusão contínua'),
        MedicamentoLorazepam._textoObs(
            'Infusão contínua: risco de acúmulo e tolerância'),
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
      textoDose = '${doseCalculada.toStringAsFixed(2)} $unidade';
    } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
      double doseMin = dosePorKgMinima * peso;
      double doseMax = dosePorKgMaxima * peso;
      if (doseMaxima != null) {
        doseMax = doseMax > doseMaxima ? doseMaxima : doseMax;
      }
      textoDose =
          '${doseMin.toStringAsFixed(2)}–${doseMax.toStringAsFixed(2)} $unidade';
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
