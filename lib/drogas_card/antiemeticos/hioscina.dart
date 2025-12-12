import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoHioscina {
  static const String nome = 'Hioscina';
  static const String idBulario = 'hioscina';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/hioscina.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final faixaEtaria = SharedData.faixaEtaria;
    final isAdulto = faixaEtaria == 'Adulto' || faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    // Hioscina tem indicações para todas as faixas etárias
    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardHioscina(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardHioscina(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHioscina._textoObs(
            'Anticolinérgico - Antiespasmódico - Antagonista muscarínico'),
        const SizedBox(height: 16),
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHioscina._linhaPreparo('Ampola 20mg/mL', ''),
        MedicamentoHioscina._linhaPreparo('Comprimido 10mg', ''),
        const SizedBox(height: 16),
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHioscina._linhaPreparo('Via IV/IM', 'Pronta para uso'),
        MedicamentoHioscina._linhaPreparo(
            'Infusão IV', 'Diluir em SF 0,9% se necessário'),
        MedicamentoHioscina._linhaPreparo('Via oral', 'Comprimido com água'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoHioscina._linhaIndicacaoDoseFixa(
            titulo: 'Cólica biliar/renal',
            descricaoDose: '20mg IM ou IV a cada 6-8h',
            doseFixa: '20 mg',
          ),
          MedicamentoHioscina._linhaIndicacaoDoseFixa(
            titulo: 'Espasmo gastrointestinal',
            descricaoDose: '20mg IM ou IV a cada 6-8h',
            doseFixa: '20 mg',
          ),
          MedicamentoHioscina._linhaIndicacaoDoseFixa(
            titulo: 'Náuseas e vômitos',
            descricaoDose: '20mg IM ou IV',
            doseFixa: '20 mg',
          ),
          MedicamentoHioscina._linhaIndicacaoDoseFixa(
            titulo: 'Sedação pré-operatória',
            descricaoDose: '20mg IM 30-60min antes',
            doseFixa: '20 mg',
          ),
        ] else ...[
          MedicamentoHioscina._linhaIndicacaoDoseCalculada(
            titulo: 'Cólica/espasmo pediátrico',
            descricaoDose: '0,3-0,6 mg/kg/dia dividido em 3-4 doses',
            unidade: 'mg/dia',
            dosePorKgMinima: 0.3,
            dosePorKgMaxima: 0.6,
            peso: peso,
          ),
        ],
        const SizedBox(height: 16),
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoHioscina._textoObs('Início de ação: 15-30 minutos (oral)'),
        MedicamentoHioscina._textoObs('Início IM/IV: 10-15 minutos'),
        MedicamentoHioscina._textoObs('Pico de efeito: 1-2 horas'),
        MedicamentoHioscina._textoObs('Duração: 4-6 horas'),
        MedicamentoHioscina._textoObs('Meia-vida: 4-6 horas'),
        MedicamentoHioscina._textoObs(
            'Antagonista receptores muscarínicos (M1, M2, M3)'),
        MedicamentoHioscina._textoObs('Bloqueia acetilcolina'),
        MedicamentoHioscina._textoObs(
            'Reduz motilidade e secreção gastrointestinal'),
        MedicamentoHioscina._textoObs('Alivia espasmos e cólicas'),
        MedicamentoHioscina._textoObs('Efeito antiemético (área postrema)'),
        MedicamentoHioscina._textoObs('Efeito sedativo e amnésico leve'),
        MedicamentoHioscina._textoObs('Dose máxima oral: 80mg/dia'),
        MedicamentoHioscina._textoObs('Dose máxima parenteral: 60mg/dia'),
        MedicamentoHioscina._textoObs(
            'Efeitos anticolinérgicos: boca seca, visão turva'),
        MedicamentoHioscina._textoObs('Pode causar retenção urinária'),
        MedicamentoHioscina._textoObs('Pode causar sonolência, tontura'),
        MedicamentoHioscina._textoObs('Pode causar taquicardia'),
        MedicamentoHioscina._textoObs(
            'Risco em idosos: confusão, alucinações, delírio'),
        MedicamentoHioscina._textoObs('Monitorar função renal e hepática'),
        MedicamentoHioscina._textoObs('Compatível com SF 0,9% e SG 5%'),
        MedicamentoHioscina._textoObs(
            'Contraindicado em glaucoma de ângulo fechado'),
        MedicamentoHioscina._textoObs(
            'Contraindicado em hipertrofia prostática'),
        MedicamentoHioscina._textoObs('Contraindicado em miastenia gravis'),
        MedicamentoHioscina._textoObs('Contraindicado em obstrução intestinal'),
        MedicamentoHioscina._textoObs(
            'Potencializa com outros anticolinérgicos'),
        MedicamentoHioscina._textoObs('Categoria C na gravidez'),
        MedicamentoHioscina._textoObs('Evitar na lactação'),
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
