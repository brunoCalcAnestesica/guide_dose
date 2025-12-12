import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../drogas.dart';
import '../../shared_data.dart';

class MedicamentoNaloxona {
  static const String nome = 'Naloxona';
  static const String idBulario = 'naloxona';

  static Future<Map<String, dynamic>> carregarBulario() async {
    final String jsonStr =
        await rootBundle.loadString('assets/medicamentos/naloxona.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    return jsonMap['PT']['bulario'];
  }

  static Widget buildCard(BuildContext context, Set<String> favoritos,
      void Function(String) onToggleFavorito) {
    final peso = SharedData.peso ?? 70;
    final isAdulto =
        SharedData.faixaEtaria == 'Adulto' || SharedData.faixaEtaria == 'Idoso';
    final isFavorito = favoritos.contains(nome);

    return buildMedicamentoExpansivel(
      context: context,
      nome: nome,
      idBulario: idBulario,
      isFavorito: isFavorito,
      onToggleFavorito: () => onToggleFavorito(nome),
      conteudo: _buildCardNaloxona(
        context,
        peso,
        isAdulto,
        isFavorito,
        () => onToggleFavorito(nome),
      ),
    );
  }

  static Widget _buildCardNaloxona(BuildContext context, double peso,
      bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Classe
        const Text('Classe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNaloxona._textoObs('Antagonista opioide - Reversor'),

        const SizedBox(height: 16),

        // Apresentações
        const Text('Apresentações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNaloxona._linhaPreparo(
            'Ampola 0,4mg/mL (1mL)', 'Solução injetável'),
        MedicamentoNaloxona._linhaPreparo(
            'Ampola 0,04mg/mL (2mL)', 'Neonatal (quando disponível)'),

        const SizedBox(height: 16),

        // Preparo
        const Text('Preparo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNaloxona._linhaPreparo(
            '0,4mg (1 ampola) puro', 'Bolus IV direto'),
        MedicamentoNaloxona._linhaPreparo(
            '0,4mg em 9mL SF 0,9%', '0,04mg/mL (diluição 1:10)'),
        MedicamentoNaloxona._linhaPreparo(
            '2mg em 100mL SF 0,9%', '20 mcg/mL para infusão'),

        const SizedBox(height: 16),

        // Indicações Clínicas
        const Text('Indicações Clínicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (isAdulto) ...[
          MedicamentoNaloxona._linhaIndicacaoDoseFixa(
            titulo: 'Intoxicação/depressão respiratória por opioides',
            descricaoDose: '0,4-2mg IV (repetir a cada 2-3min até resposta)',
            doseFixa: '0,4-2 mg',
          ),
          MedicamentoNaloxona._linhaIndicacaoDoseCalculada(
            titulo: 'Titulação cuidadosa (evitar abstinência)',
            descricaoDose: '0,04-0,08mg IV a cada 2min',
            unidade: 'mg',
            dosePorKgMinima: 0.0005,
            dosePorKgMaxima: 0.001,
            peso: peso,
          ),
          MedicamentoNaloxona._linhaIndicacaoDoseFixa(
            titulo: 'Parada cardiorrespiratória por opioides',
            descricaoDose: '2mg IV bolus',
            doseFixa: '2 mg',
          ),
        ] else ...[
          MedicamentoNaloxona._linhaIndicacaoDoseCalculada(
            titulo: 'Depressão respiratória pediátrica',
            descricaoDose: '0,01mg/kg IV (máx 0,4mg), repetir se necessário',
            unidade: 'mg',
            dosePorKg: 0.01,
            doseMaxima: 0.4,
            peso: peso,
          ),
          MedicamentoNaloxona._linhaIndicacaoDoseCalculada(
            titulo: 'Neonatos (<28 dias)',
            descricaoDose: '0,01mg/kg IV/IM/SC (máx 0,2mg)',
            unidade: 'mg',
            dosePorKg: 0.01,
            doseMaxima: 0.2,
            peso: peso,
          ),
          MedicamentoNaloxona._linhaIndicacaoDoseFixa(
            titulo: 'Parada cardiorrespiratória pediátrica',
            descricaoDose: '0,1mg/kg IV (máx 2mg)',
            doseFixa: '0,1 mg/kg',
          ),
        ],

        const SizedBox(height: 16),

        // Infusão Contínua
        const Text('Infusão Contínua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNaloxona._buildConversorInfusao(peso, isAdulto),

        const SizedBox(height: 16),

        // Observações
        const Text('Observações',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        MedicamentoNaloxona._textoObs(
            'Início de ação: 1-2 minutos IV, 2-5 minutos IM'),
        MedicamentoNaloxona._textoObs(
            'Duração: 30-60 minutos (menor que maioria dos opioides)'),
        MedicamentoNaloxona._textoObs(
            'Monitorar depressão respiratória recorrente'),
        MedicamentoNaloxona._textoObs(
            'Pode precipitar síndrome de abstinência em dependentes'),
        MedicamentoNaloxona._textoObs(
            'Titular dose para evitar agitação e dor súbita'),
        MedicamentoNaloxona._textoObs(
            'Repetir doses ou infusão contínua se necessário'),
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

  static Widget _buildConversorInfusao(double peso, bool isAdulto) {
    final opcoesConcentracoes = {
      '2mg em 100mL SF 0,9% (20 mcg/mL)': 20.0, // mcg/mL
      '4mg em 100mL SF 0,9% (40 mcg/mL)': 40.0, // mcg/mL
      '2mg em 50mL SF 0,9% (40 mcg/mL)': 40.0, // mcg/mL
    };

    if (isAdulto) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoNaloxona._textoObs(
              'Dose: 2/3 da dose de reversão por hora'),
          MedicamentoNaloxona._textoObs(
              'Faixa típica: 0,25-6,25 mcg/kg/h IV contínua'),
          const SizedBox(height: 8),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mcg/kg/h',
            doseMin: 0.25,
            doseMax: 6.25,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicamentoNaloxona._textoObs(
              'Dose: 2/3 da dose de reversão por hora'),
          MedicamentoNaloxona._textoObs(
              'Faixa típica: 0,25-4 mcg/kg/h IV contínua'),
          const SizedBox(height: 8),
          ConversaoInfusaoSlider(
            peso: peso,
            opcoesConcentracoes: opcoesConcentracoes,
            unidade: 'mcg/kg/h',
            doseMin: 0.25,
            doseMax: 4.0,
          ),
        ],
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
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
