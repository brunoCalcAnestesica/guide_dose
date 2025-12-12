import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoAlfentanil {
  static const String nome = 'Alfentanil';
  static const String idBulario = 'alfentanil';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr = await rootBundle.loadString('assets/medicamentos/alfentanil.json');
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
      conteudo: _buildCardAlfentanil(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardAlfentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Classe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlfentanil._textoObs('• Analgésico Opioide - Agonista μ-opioide'),
        const SizedBox(height: 16),
        const Text('Apresentações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlfentanil._linhaPreparo('Ampola 0,5mg/mL (5mL)', 'Solução injetável'),
        MedicamentoAlfentanil._linhaPreparo('Ampola 1mg/mL (2mL)', 'Solução injetável concentrada'),
        const SizedBox(height: 16),
        const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlfentanil._linhaPreparo('Pode ser administrado sem diluição', 'Direto da ampola'),
        MedicamentoAlfentanil._linhaPreparo('Para infusão: diluir em SF 0,9% ou SG 5%', 'Concentração conforme necessidade'),
        MedicamentoAlfentanil._linhaPreparo('Para UTI: 5mg em 50mL SF 0,9%', '100 mcg/mL para infusão contínua'),
        const SizedBox(height: 16),
        const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoAlfentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Procedimentos de curta duração',
            descricaoDose: '7–15 mcg/kg IV bolus (incrementos de 3,5 mcg/kg)',
            unidade: 'mcg',
            dosePorKgMinima: 7,
            dosePorKgMaxima: 15,
            peso: peso,
          ),
          MedicamentoAlfentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Indução anestésica',
            descricaoDose: '120 mcg/kg IV lento (3 minutos)',
            unidade: 'mcg',
            dosePorKg: 120,
            peso: peso,
          ),
          MedicamentoAlfentanil._linhaIndicacaoDoseFixa(
            titulo: 'Infusão contínua',
            descricaoDose: '1 mcg/kg/min IV contínua',
            doseFixa: '1 mcg/kg/min',
          ),
          MedicamentoAlfentanil._linhaIndicacaoDoseFixa(
            titulo: 'UTI - Sedação',
            descricaoDose: '2 mg/h IV (≈30 mcg/kg/h para 70kg)',
            doseFixa: '2 mg/h',
          ),
        ] else ...[
          MedicamentoAlfentanil._linhaIndicacaoDoseCalculada(
            titulo: 'Procedimentos pediátricos',
            descricaoDose: '5–10 mcg/kg IV bolus',
            unidade: 'mcg',
            dosePorKgMinima: 5,
            dosePorKgMaxima: 10,
            peso: peso,
          ),
          MedicamentoAlfentanil._linhaIndicacaoDoseFixa(
            titulo: 'Infusão pediátrica',
            descricaoDose: '0,5–1 mcg/kg/min IV contínua',
            doseFixa: '0,5–1 mcg/kg/min',
          ),
        ],
        const SizedBox(height: 16),
        const Text('Infusão Contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlfentanil._buildConversorInfusao(peso, isAdulto),
        const SizedBox(height: 16),
        const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoAlfentanil._textoObs('• Opioide de ação rápida e curta duração'),
        MedicamentoAlfentanil._textoObs('• Meia-vida de 1-2 horas'),
        MedicamentoAlfentanil._textoObs('• Monitorar função respiratória continuamente'),
        MedicamentoAlfentanil._textoObs('• Reduzir dose em idosos e insuficiência hepática'),
        MedicamentoAlfentanil._textoObs('• Interage com inibidores CYP3A4'),
        MedicamentoAlfentanil._textoObs('• Duração máxima de infusão: 4 dias'),
        MedicamentoAlfentanil._textoObs('• Contraindicado em hipersensibilidade a opioides'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '5mg em 50mL SF 0,9% (100 mcg/mL)': 100.0, // mcg/mL
      '2mg em 50mL SF 0,9% (40 mcg/mL)': 40.0, // mcg/mL
      '1mg em 50mL SF 0,9% (20 mcg/mL)': 20.0, // mcg/mL
    };

    if (isAdulto) {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.5,
        doseMax: 1.0,
      );
    } else {
      return ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: opcoesConcentracoes,
        unidade: 'mcg/kg/min',
        doseMin: 0.5,
        doseMax: 1.0,
      );
    }
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
